import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root
  property var pluginApi: null

  // Settings and default values (Official Noctalia pattern)
  readonly property var cfg: pluginApi?.pluginSettings || ({})
  readonly property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  // 1. Local state ('edit' convention to avoid unnecessary disk writes)
  property string editOverlayPath: cfg.overlayPath ?? defaults.overlayPath ?? "~/.cache/noctalia/HVE/overlay.conf"
  property bool editAutoApply: cfg.autoApply ?? defaults.autoApply ?? true
  property string editIcon: cfg.icon ?? defaults.icon ?? "adjustments-horizontal"
  property string editIconColor: cfg.iconColor ?? defaults.iconColor ?? "primary"

  spacing: Style.marginM

  // ── Preview ──────────────────────────────────────────────────────────
  RowLayout {
    spacing: Style.marginM
    Layout.alignment: Qt.AlignHCenter
    Layout.topMargin: Style.marginL
    Layout.bottomMargin: Style.marginL

    NIcon {
      icon: root.editIcon
      pointSize: Style.fontSizeXXL * 2
      color: {
        let res = Color.resolveColorKeyOptional(root.editIconColor);
        return res.a > 0 ? res : Color.mOnSurface;
      }
    }
    
    NText {
      text: pluginApi?.tr("settings.preview_label")
      font.weight: Font.Bold
    }
  }

  // ── Icon Configuration ────────────────────────────────────────────────
  NButton {
    Layout.fillWidth: true
    text: pluginApi?.tr("settings.change_icon_button")
    icon: "search"
    onClicked: iconPicker.open()
  }

  NIconPicker {
    id: iconPicker
    initialIcon: root.editIcon
    onIconSelected: iconName => {
      root.editIcon = iconName
    }
  }

  NColorChoice {
    label: pluginApi?.tr("settings.icon_color_label")
    currentKey: root.editIconColor
    onSelected: key => { root.editIconColor = key }
    defaultValue: defaults.iconColor || "primary"
  }

  NDivider { Layout.fillWidth: true }

  // ── Files and Application Configuration ────────────────────────────────
  NTextInput {
    Layout.fillWidth: true
    label: pluginApi?.tr("settings.path_label")
    description: pluginApi?.tr("settings.path_desc")
    text: root.editOverlayPath
    onTextChanged: root.editOverlayPath = text
    readOnly: true
  }

  NToggle {
    Layout.fillWidth: true
    label: pluginApi?.tr("settings.autoapply_label")
    description: pluginApi?.tr("settings.autoapply_description")
    checked: root.editAutoApply
    onToggled: checked => { root.editAutoApply = checked }
  }

  // ── Save Function (Required by the Shell) ──────────────────────────
  function saveSettings() {
    if (!pluginApi) return
    
    pluginApi.pluginSettings.overlayPath = root.editOverlayPath
    pluginApi.pluginSettings.autoApply = root.editAutoApply
    pluginApi.pluginSettings.icon = root.editIcon
    pluginApi.pluginSettings.iconColor = root.editIconColor
    
    pluginApi.saveSettings()
    Logger.i("HVE", "Settings saved")
  }
}