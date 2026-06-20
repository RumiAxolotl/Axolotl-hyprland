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
    "swayCommand": (cfg && cfg.swayCommand) || (defaults && defaults.swayCommand) || "swaymsg"
  };
}

function buildFetchCommand(cfg, defaults) {
  var settings = extractSettings(cfg, defaults);
  return [settings.swayCommand, "-t", "get_outputs", "-r"];
}

function parseOutputs(rawText) {
  try {
    var parsed = JSON.parse(rawText || "[]");
    var outputs = [];

    for (var index = 0; index < parsed.length; index++) {
      var output = parsed[index];
      if (!output || output.non_desktop) {
        continue;
      }

      var currentMode = output.current_mode || {};
      var rect = output.rect || {};
      var scale = output.scale || 1;
      var modeWidth = currentMode.width || rect.width || 1920;
      var modeHeight = currentMode.height || rect.height || 1080;
      var logicalWidth = rect.width || Math.max(1, Math.round(modeWidth / scale));
      var logicalHeight = rect.height || Math.max(1, Math.round(modeHeight / scale));
      var refresh = (currentMode.refresh || 0) / 1000;
      var currentModeId = modeIdFromMode(currentMode, modeWidth, modeHeight, refresh);
      var modes = [];

      for (var modeIndex = 0; modeIndex < (output.modes || []).length; modeIndex++) {
        var mode = output.modes[modeIndex];
        var modeRefresh = (mode.refresh || 0) / 1000;
        var modeId = modeIdFromMode(mode, mode.width, mode.height, modeRefresh);
        modes.push({
          "id": modeId,
          "width": mode.width,
          "height": mode.height,
          "refresh": modeRefresh,
          "label": modeLabel(mode.width, mode.height, modeRefresh),
          "preferred": !!mode.preferred
        });
      }

      if (modes.length === 0) {
        modes.push({
          "id": currentModeId,
          "width": modeWidth,
          "height": modeHeight,
          "refresh": refresh,
          "label": modeLabel(modeWidth, modeHeight, refresh),
          "preferred": true
        });
      }

      outputs.push({
        "outputId": output.name,
        "name": output.name,
        "make": output.make || "",
        "model": output.model || "",
        "serial": output.serial || "",
        "active": output.active !== false,
        "focused": !!output.focused,
        "x": rect.x || 0,
        "y": rect.y || 0,
        "width": modeWidth,
        "height": modeHeight,
        "logicalWidth": logicalWidth,
        "logicalHeight": logicalHeight,
        "scale": scale,
        "transform": output.transform || "normal",
        "refresh": refresh,
        "modeId": currentModeId,
        "resolutionLabel": modeLabel(modeWidth, modeHeight, refresh),
        "availableModes": modes,
        "description": describeOutput(output)
      });
    }

    outputs.sort(function (left, right) {
      if (left.active !== right.active) {
        return left.active ? -1 : 1;
      }
      if (left.x !== right.x) {
        return left.x - right.x;
      }
      if (left.y !== right.y) {
        return left.y - right.y;
      }
      return left.name.localeCompare(right.name);
    });

    return {
      "outputs": outputs
    };
  } catch (error) {
    return {
      "error": "Failed to parse Sway output data: " + error
    };
  }
}

function buildApplyCommand(outputs, cfg, defaults) {
  var swayCommand = extractSettings(cfg, defaults).swayCommand;
  if (!outputs || outputs.length === 0) {
    return {
      "error": "No outputs available to apply."
    };
  }

  var commands = [];
  for (var index = 0; index < outputs.length; index++) {
    var output = outputs[index];
    if (!output || output.active === false) {
      continue;
    }

    var resolution = output.width + "x" + output.height;
    if (output.refresh && output.refresh > 0) {
      resolution += "@" + refreshToHzString(output.refresh) + "Hz";
    }

    commands.push(
      shellQuote(swayCommand) +
      " --" +
      " output " + shellQuote(output.name) +
      " enable" +
      " pos " + Math.round(output.x) + " " + Math.round(output.y) +
      " res " + shellQuote(resolution) +
      " scale " + sanitizeNumber(output.scale || 1) +
      " transform " + shellQuote(output.transform || "normal")
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
    if (output.refresh && output.refresh > 0) {
      resolution += "@" + refreshToHzString(output.refresh) + "Hz";
    }

    var line = "output " + output.name +
      " mode " + resolution +
      " position " + Math.round(output.x) + "," + Math.round(output.y) +
      " scale " + sanitizeNumber(output.scale || 1);

    if (output.transform && output.transform !== "normal") {
      line += " transform " + output.transform;
    }

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

function modeIdFromMode(mode, width, height, refresh) {
  var modeWidth = width || mode.width || 0;
  var modeHeight = height || mode.height || 0;
  var modeRefresh = refresh || mode.refresh || 0;
  return modeWidth + "x" + modeHeight + "@" + modeRefresh;
}

function modeLabel(width, height, refresh) {
  var text = width + "x" + height;
  if (refresh && refresh > 0) {
    text += " @ " + refreshToHzString(refresh) + " Hz";
  }
  return text;
}

function refreshToHzString(refresh) {
  return Number(refresh).toFixed(2).replace(/\.00$/, "");
}

function sanitizeNumber(value) {
  var numeric = Number(value);
  if (!isFinite(numeric) || numeric <= 0) {
    return "1";
  }
  return numeric.toFixed(2).replace(/0+$/, "").replace(/\.$/, "");
}

function describeOutput(output) {
  var parts = [];
  if (output.make) {
    parts.push(output.make);
  }
  if (output.model) {
    parts.push(output.model);
  }
  if (output.serial) {
    parts.push(output.serial);
  }
  return parts.join(" ").trim();
}

function shellQuote(text) {
  var value = String(text === undefined || text === null ? "" : text);
  return "'" + value.replace(/'/g, "'\\''") + "'";
}