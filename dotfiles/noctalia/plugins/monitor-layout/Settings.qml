import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root

  property var pluginApi: null

  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  property string editBackend: cfg.backend ?? defaults.backend ?? "auto"
  property string editSwayCommand: cfg.swayCommand ?? defaults.swayCommand ?? "swaymsg"
  property string editHyprctlCommand: cfg.hyprctlCommand ?? defaults.hyprctlCommand ?? "hyprctl"
  property bool editSnapToGrid: cfg.snapToGrid ?? defaults.snapToGrid ?? true
  property string editGridSize: String(cfg.gridSize ?? defaults.gridSize ?? 40)
  property string editIconColor: cfg.iconColor ?? defaults.iconColor ?? "primary"

  spacing: Style.marginL

  ColumnLayout {
    spacing: Style.marginM
    Layout.fillWidth: true

    NComboBox {
      Layout.fillWidth: true
      label: pluginApi?.tr("settings.backend.label")
      description: pluginApi?.tr("settings.backend.desc")
      model: [
        { "key": "auto", "name": pluginApi?.tr("settings.backend.auto") },
        { "key": "sway", "name": pluginApi?.tr("settings.backend.sway") },
        { "key": "hyprland", "name": pluginApi?.tr("settings.backend.hyprland") }
      ]
      currentKey: root.editBackend
      onSelected: key => root.editBackend = key
    }

    NTextInput {
      Layout.fillWidth: true
      label: pluginApi?.tr("settings.swayCommand.label")
      description: pluginApi?.tr("settings.swayCommand.desc")
      text: root.editSwayCommand
      onTextChanged: root.editSwayCommand = text
    }

    NTextInput {
      Layout.fillWidth: true
      label: pluginApi?.tr("settings.hyprctlCommand.label")
      description: pluginApi?.tr("settings.hyprctlCommand.desc")
      text: root.editHyprctlCommand
      onTextChanged: root.editHyprctlCommand = text
    }

    NToggle {
      Layout.fillWidth: true
      label: pluginApi?.tr("settings.snapToGrid.label")
      checked: root.editSnapToGrid
      onToggled: checked => root.editSnapToGrid = checked
    }

    NTextInput {
      Layout.fillWidth: true
      label: pluginApi?.tr("settings.gridSize.label")
      description: pluginApi?.tr("settings.gridSize.desc")
      text: root.editGridSize
      onTextChanged: root.editGridSize = text
    }

    NComboBox {
      Layout.fillWidth: true
      label: pluginApi?.tr("settings.iconColor.label")
      description: pluginApi?.tr("settings.iconColor.desc")
      model: Color.colorKeyModel
      currentKey: root.editIconColor
      onSelected: key => root.editIconColor = key
    }
  }

  function saveSettings() {
    if (!pluginApi) {
      return;
    }

    pluginApi.pluginSettings.backend = root.editBackend;
    pluginApi.pluginSettings.swayCommand = root.editSwayCommand;
    pluginApi.pluginSettings.hyprctlCommand = root.editHyprctlCommand;
    pluginApi.pluginSettings.snapToGrid = root.editSnapToGrid;
    pluginApi.pluginSettings.gridSize = Math.max(1, parseInt(root.editGridSize) || 40);
    pluginApi.pluginSettings.iconColor = root.editIconColor;
    pluginApi.saveSettings();
  }
}