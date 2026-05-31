.pragma library
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
//   buildApplyCommand(outputs, cfg, defaults) -> { script } | { error }
//     Build a shell script string that applies the given draft outputs.
//     Return { error: string } if the command cannot be built.
//
//   buildConfigFileContent(outputs) -> { content } | { error }
//     Build a config file snippet for the given outputs (for copy-to-config).
//     Return { error: string } if the config cannot be built.
// ---

function extractSettings(cfg, defaults) {
  return {
    "hyprctlCommand": (cfg && cfg.hyprctlCommand) || (defaults && defaults.hyprctlCommand) || "hyprctl"
  };
}

function buildFetchCommand(cfg, defaults) {
  var settings = extractSettings(cfg, defaults);
  return [settings.hyprctlCommand, "monitors", "-j"];
}

function parseOutputs(rawText) {
  try {
    var parsed = JSON.parse(rawText || "[]");
    var outputs = [];

    for (var index = 0; index < parsed.length; index++) {
      var monitor = parsed[index];
      if (!monitor || monitor.disabled) {
        continue;
      }

      var width = monitor.width || 1920;
      var height = monitor.height || 1080;
      var refresh = normalizeRefreshRate(monitor.refreshRate);
      var scale = monitor.scale || 1;
      var logicalWidth = Math.max(1, Math.round(width / scale));
      var logicalHeight = Math.max(1, Math.round(height / scale));
      var currentModeId = modeIdFromRes(width, height, refresh);
      
      // Hyprland doesn't expose per-output mode lists here, so seed the picker
      // with the current mode plus a deduplicated set of common presets.
      var modes = buildCommonModes(width, height, refresh);

      outputs.push({
        "outputId": monitor.name,
        "name": monitor.name,
        "make": monitor.make || "",
        "model": monitor.model || "",
        "serial": monitor.serial || "",
        "active": !monitor.disabled,
        "focused": !!monitor.focused,
        "x": monitor.x || 0,
        "y": monitor.y || 0,
        "width": width,
        "height": height,
        "logicalWidth": logicalWidth,
        "logicalHeight": logicalHeight,
        "scale": scale,
        "transform": String(monitor.transform || 0),
        "refresh": refresh,
        "modeId": currentModeId,
        "resolutionLabel": modeLabel(width, height, refresh),
        "availableModes": modes,
        "description": describeMonitor(monitor)
      });
    }

    return {
      "outputs": outputs
    };
  } catch (error) {
    return {
      "error": "Failed to parse Hyprland monitor data: " + error
    };
  }
}

function buildApplyCommand(outputs, cfg, defaults) {
  if (!outputs || outputs.length === 0) {
    return {
      "error": "No outputs available to apply."
    };
  }

  var hyprctlCommand = extractSettings(cfg, defaults).hyprctlCommand;
  var commands = [];

  for (var index = 0; index < outputs.length; index++) {
    var output = outputs[index];
    if (!output || output.active === false) {
      continue;
    }

    var resolution = output.width + "x" + output.height;
    var refresh = formatRefreshForCommand(output.refresh);
    if (refresh === null) {
      return {
        "error": "Refusing to apply an invalid refresh rate for output '" + output.name + "'."
      };
    }

    if (refresh !== "") {
      resolution += "@" + refresh;
    }

    var position = Math.round(output.x) + "x" + Math.round(output.y);
    var scale = sanitizeNumber(output.scale || 1);

    // hyprctl keyword monitor NAME,RESOLUTION,POSITION,SCALE
    commands.push(
      shellQuote(hyprctlCommand) +
      " keyword monitor " +
      shellQuote(output.name) + "," +
      shellQuote(resolution) + "," +
      shellQuote(position) + "," +
      shellQuote(scale)
    );
  }

  if (commands.length === 0) {
    return {
      "error": "There are no active outputs to configure."
    };
  }

  return {
    "script": commands.join(" && ")
  };
}

function buildConfigFileContent(outputs) {
  if (!outputs || outputs.length === 0) {
    return {
      "error": "No outputs available to configure."
    };
  }

  var lines = [];
  for (var index = 0; index < outputs.length; index++) {
    var output = outputs[index];
    if (!output || output.active === false) {
      continue;
    }

    var resolution = output.width + "x" + output.height;
    var refresh = formatRefreshForCommand(output.refresh);
    if (refresh === null) {
      return {
        "error": "Refusing to generate config for invalid refresh rate for output '" + output.name + "'."
      };
    }

    if (refresh !== "") {
      resolution += "@" + refresh;
    }

    var position = Math.round(output.x) + "x" + Math.round(output.y);
    var scale = sanitizeNumber(output.scale || 1);

    // Hyprland config format: monitor=NAME,RESOLUTION,POSITION,SCALE
    var line = "monitor=" + output.name + "," + resolution + "," + position + "," + scale;
    lines.push(line);
  }

  if (lines.length === 0) {
    return {
      "error": "There are no active outputs to configure."
    };
  }

  return {
    "content": lines.join("\n")
  };
}

function buildCommonModes(currentWidth, currentHeight, currentRefresh) {
  var normalizedRefresh = normalizeRefreshRate(currentRefresh);
  var commonRes = [
    { w: 1024, h: 768 },
    { w: 1280, h: 720 },
    { w: 1280, h: 800 },
    { w: 1280, h: 1024 },
    { w: 1366, h: 768 },
    { w: 1600, h: 900 },
    { w: 1680, h: 1050 },
    { w: 1920, h: 1080 },
    { w: 2560, h: 1440 },
    { w: 3440, h: 1440 },
    { w: 3840, h: 2160 },
    { w: 5120, h: 2880 }
  ];
  var commonRefreshRates = [30, 50, 60, 75, 90, 100, 120, 144, 165, 180, 200, 240];

  var modes = [];
  var seen = {};

  function pushMode(width, height, refresh, preferred) {
    var normalized = normalizeRefreshRate(refresh);
    var modeId = modeIdFromRes(width, height, normalized);
    if (seen[modeId]) {
      return;
    }

    seen[modeId] = true;
    modes.push({
      "id": modeId,
      "width": width,
      "height": height,
      "refresh": normalized,
      "label": modeLabel(width, height, normalized),
      "preferred": !!preferred
    });
  }

  pushMode(currentWidth, currentHeight, normalizedRefresh, true);

  for (var i = 0; i < commonRes.length; i++) {
    var res = commonRes[i];
    for (var refreshIndex = 0; refreshIndex < commonRefreshRates.length; refreshIndex++) {
      var hz = commonRefreshRates[refreshIndex];
      pushMode(
        res.w,
        res.h,
        hz,
        res.w === currentWidth && res.h === currentHeight && Math.round(hz) === Math.round(normalizedRefresh)
      );
    }
  }

  return modes;
}

function modeIdFromRes(width, height, refresh) {
  return width + "x" + height + "@" + refresh;
}

function modeLabel(width, height, refresh) {
  var text = width + "x" + height;
  if (refresh && refresh > 0) {
    text += " @ " + refreshToHzString(refresh) + " Hz";
  }
  return text;
}

function refreshToHzString(refresh) {
  return Number(refresh).toFixed(2).replace(/\.00$/, "").replace(/(\.\d*[1-9])0+$/, "$1");
}

function normalizeRefreshRate(refresh) {
  var numeric = Number(refresh);
  if (!isFinite(numeric) || numeric <= 0) {
    return 60;
  }

  if (numeric >= 1000) {
    return numeric / 1000;
  }

  return numeric;
}

function formatRefreshForCommand(refresh) {
  if (refresh === undefined || refresh === null || refresh === "") {
    return "";
  }

  var normalized = normalizeRefreshRate(refresh);
  if (!isFinite(normalized) || normalized < 1 || normalized > 1000) {
    return null;
  }

  return refreshToHzString(normalized);
}

function sanitizeNumber(value) {
  var numeric = Number(value);
  if (!isFinite(numeric) || numeric <= 0) {
    return "1";
  }
  return numeric.toFixed(2).replace(/0+$/, "").replace(/\.$/, "");
}

function describeMonitor(monitor) {
  var parts = [];
  if (monitor.make) {
    parts.push(monitor.make);
  }
  if (monitor.model) {
    parts.push(monitor.model);
  }
  if (monitor.serial) {
    parts.push(monitor.serial);
  }
  return parts.join(" ").trim();
}

function shellQuote(text) {
  var value = String(text === undefined || text === null ? "" : text);
  return "'" + value.replace(/'/g, "'\\''") + "'";
}
