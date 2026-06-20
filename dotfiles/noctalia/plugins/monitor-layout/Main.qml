import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.Compositor
import "backends/SwayBackend.js" as SwayBackend
import "backends/HyprlandBackend.js" as HyprlandBackend

Item {
  id: root

  property var pluginApi: null

  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  property var liveOutputs: []
  property var draftOutputs: []
  property string selectedOutputId: ""
  property bool isRefreshing: false
  property bool isApplying: false
  property string errorText: ""
  property string statusText: ""
  property string refreshStderr: ""
  property string applyStderr: ""

  readonly property string backendId: resolveBackendId()
  readonly property bool hasPendingChanges: JSON.stringify(draftOutputs) !== JSON.stringify(liveOutputs)

  Component.onCompleted: {
    refreshOutputs();
  }

  IpcHandler {
    target: "plugin:layout-mon"

    function toggle() {
      if (pluginApi) {
        pluginApi.withCurrentScreen(screen => {
          pluginApi.togglePanel(screen);
        });
      }
    }

    function refresh() {
      root.refreshOutputs();
    }

    function apply() {
      root.applyLayout();
    }
  }

  Process {
    id: fetchProcess

    stdout: StdioCollector {
      onStreamFinished: {
        root.handleFetchOutput(this.text);
      }
    }

    stderr: StdioCollector {
      onStreamFinished: {
        root.refreshStderr = this.text.trim();
      }
    }

    onExited: function (exitCode) {
      root.isRefreshing = false;
      if (exitCode !== 0) {
        root.errorText = root.refreshStderr !== "" ? root.refreshStderr : pluginApi?.tr("errors.fetchFailed");
        root.statusText = "";
        Logger.e("MonitorLayout", root.errorText);
      }
    }
  }

  Process {
    id: applyProcess

    stdout: StdioCollector {}

    stderr: StdioCollector {
      onStreamFinished: {
        root.applyStderr = this.text.trim();
      }
    }

    onExited: function (exitCode) {
      root.isApplying = false;
      if (exitCode === 0) {
        root.statusText = pluginApi?.tr("status.applied");
        root.errorText = "";
        root.refreshOutputs();
      } else {
        root.errorText = root.applyStderr !== "" ? root.applyStderr : pluginApi?.tr("errors.applyFailed");
        root.statusText = "";
        Logger.e("MonitorLayout", root.errorText);
      }
    }
  }



  function resolveBackendId() {
    var preferred = cfg.backend ?? defaults.backend ?? "auto";
    if (preferred !== "auto") {
      return preferred;
    }
    if (CompositorService.isHyprland) {
      return "hyprland";
    }
    if (CompositorService.isSway) {
      return "sway";
    }
    return "unsupported";
  }

  // --- Backend interface ---
  // Every backend module must export the following functions:
  //
  //   buildFetchCommand(cfg, defaults) -> Array<string>
  //     Return the command (as an argv array) that reads the current output state.
  //
  //   parseOutputs(rawText) -> { outputs } | { error }
  //     Parse the raw stdout text from the fetch command into a normalised array
  //     of output objects. Return { error: string } on failure.
  //
  //   outputs: Array of monitor/output objects, each with at least:
  //     {
  //       outputId: string,   // unique identifier for the output/monitor
  //       name: string,       // human-readable name
  //       x: number,          // X position
  //       y: number,          // Y position
  //       width: number,      // width in pixels
  //       height: number,     // height in pixels
  //       scale: number,      // scale factor
  //       modeId: string,     // current mode identifier
  //       availableModes: Array<{ id, width, height, refresh, label }>,
  //       ... (other backend-specific fields)
  //     }
  //
  //   buildApplyCommand(outputs, cfg, defaults) -> { script } | { error }
  //     Build a shell script string that applies the given draft outputs.
  //     Return { error: string } if the command cannot be built.
  //
  //   buildConfigFileContent(outputs) -> { content } | { error }
  //     Build a config file snippet for the given outputs (for copy-to-config).
  //     Return { error: string } if the config cannot be built.
  //
  // To add a new backend:
  //   1. Create backends/MyBackend.js implementing the interface above.
  //   2. Add: import "backends/MyBackend.js" as MyBackend  (top of file)
  //   3. Add a case for your backend id in each function below.
  // ---

  function backendBuildFetchCommand() {
    if (backendId === "sway") return SwayBackend.buildFetchCommand(cfg, defaults);
    if (backendId === "hyprland") return HyprlandBackend.buildFetchCommand(cfg, defaults);
    return null;
  }

  function backendParseOutputs(rawText) {
    if (backendId === "sway") return SwayBackend.parseOutputs(rawText);
    if (backendId === "hyprland") return HyprlandBackend.parseOutputs(rawText);
    return { "error": pluginApi?.tr("errors.unsupportedBackend") };
  }

  function backendBuildApplyCommand() {
    if (backendId === "sway") return SwayBackend.buildApplyCommand(draftOutputs, cfg, defaults);
    if (backendId === "hyprland") return HyprlandBackend.buildApplyCommand(draftOutputs, cfg, defaults);
    return { "error": pluginApi?.tr("errors.unsupportedBackend") };
  }

  function backendBuildConfigFileContent() {
    if (backendId === "sway") return SwayBackend.buildConfigFileContent(draftOutputs);
    if (backendId === "hyprland") return HyprlandBackend.buildConfigFileContent(draftOutputs);
    return { "error": pluginApi?.tr("errors.unsupportedBackend") };
  }


  readonly property bool snapToGridEnabled: cfg.snapToGrid ?? defaults.snapToGrid ?? true

  function gridSize() {
    var parsed = parseInt(cfg.gridSize ?? defaults.gridSize ?? 40);
    return isFinite(parsed) && parsed > 0 ? parsed : 40;
  }

  function cloneValue(value) {
    return JSON.parse(JSON.stringify(value));
  }

  function handleFetchOutput(rawText) {
    var result = backendParseOutputs(rawText);
    if (result.error) {
      errorText = result.error;
      statusText = "";
      Logger.e("MonitorLayout", errorText);
      return;
    }

    liveOutputs = cloneValue(result.outputs);
    draftOutputs = cloneValue(result.outputs);
    errorText = "";
    statusText = pluginApi?.tr("status.ready", {
      "count": draftOutputs.length
    });

    if (!selectedOutputId || findOutputIndex(selectedOutputId) === -1) {
      selectedOutputId = draftOutputs.length > 0 ? draftOutputs[0].outputId : "";
    }
  }

  function findOutputIndex(outputId) {
    for (var index = 0; index < draftOutputs.length; index++) {
      if (draftOutputs[index].outputId === outputId) {
        return index;
      }
    }
    return -1;
  }

  function getSelectedOutput() {
    var index = findOutputIndex(selectedOutputId);
    return index >= 0 ? draftOutputs[index] : null;
  }

  function selectOutput(outputId) {
    selectedOutputId = outputId;
  }

  function roundCoordinate(value, snap) {
    var rounded = Math.round(value);

    if (!snap || !snapToGridEnabled) {
      return rounded;
    }

    var step = gridSize();
    return Math.round(rounded / step) * step;
  }

  function setOutputPosition(outputId, x, y, snap) {
    var index = findOutputIndex(outputId);
    if (index === -1) {
      return;
    }

    var nextOutputs = cloneValue(draftOutputs);
    nextOutputs[index].x = roundCoordinate(x, snap);
    nextOutputs[index].y = roundCoordinate(y, snap);
    draftOutputs = nextOutputs;
    selectedOutputId = outputId;
    statusText = pluginApi?.tr("status.dirty");
  }

  function setOutputResolution(outputId, modeId) {
    var index = findOutputIndex(outputId);
    if (index === -1) {
      return;
    }

    var nextOutputs = cloneValue(draftOutputs);
    var output = nextOutputs[index];
    var modes = output.availableModes || [];

    for (var modeIndex = 0; modeIndex < modes.length; modeIndex++) {
      var mode = modes[modeIndex];
      if (mode.id !== modeId) {
        continue;
      }

      output.modeId = mode.id;
      output.width = mode.width;
      output.height = mode.height;
      output.refresh = mode.refresh;
      output.resolutionLabel = mode.label;
      draftOutputs = nextOutputs;
      selectedOutputId = outputId;
      statusText = pluginApi?.tr("status.dirty");
      return;
    }
  }

  function setOutputScale(outputId, scaleValue) {
    var index = findOutputIndex(outputId);
    if (index === -1) {
      return;
    }

    var parsed = Number(scaleValue);
    if (!isFinite(parsed) || parsed <= 0) {
      return;
    }

    // Keep scale within a practical range for Wayland compositors.
    var clamped = Math.max(0.25, Math.min(8, parsed));

    var nextOutputs = cloneValue(draftOutputs);
    nextOutputs[index].scale = Math.round(clamped * 100) / 100;
    draftOutputs = nextOutputs;
    selectedOutputId = outputId;
    statusText = t("status.dirty");
  }

  function resetDraftOutputs() {
    draftOutputs = cloneValue(liveOutputs);
    statusText = pluginApi?.tr("status.reset");
    errorText = "";
    if (!selectedOutputId || findOutputIndex(selectedOutputId) === -1) {
      selectedOutputId = draftOutputs.length > 0 ? draftOutputs[0].outputId : "";
    }
  }

  function refreshOutputs() {
    if (isRefreshing) {
      return;
    }

    refreshStderr = "";
    errorText = "";
    statusText = pluginApi?.tr("status.refreshing");
    isRefreshing = true;

    var command = backendBuildFetchCommand();
    if (!command) {
      isRefreshing = false;
      errorText = pluginApi?.tr("errors.unsupportedBackend");
      statusText = "";
      return;
    }

    fetchProcess.command = command;
    fetchProcess.running = true;
  }

  function getConfigurationScript() {
    var result = backendBuildConfigFileContent();
    if (result.error) {
      return { "error": result.error };
    }
    return { "content": result.content, "backend": backendId };
  }

  function applyLayout() {
    if (isApplying) {
      return;
    }

    var result = backendBuildApplyCommand();
    if (result.error) {
      errorText = result.error;
      statusText = "";
      return;
    }

    applyStderr = "";
    errorText = "";
    statusText = pluginApi?.tr("status.applying");
    isApplying = true;
    applyProcess.command = ["sh", "-lc", result.script];
    applyProcess.running = true;
  }
}