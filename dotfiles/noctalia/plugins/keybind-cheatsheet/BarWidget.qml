import QtQuick
import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets

NIconButton {
  id: root

  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  baseSize: Style.getCapsuleHeightForScreen(screen?.name)
  applyUiScale: false
  icon: "keyboard"
  tooltipText: pluginApi?.tr("barwidget.tooltip")
  tooltipDirection: BarService.getTooltipDirection(screen?.name)
  customRadius: Style.radiusL

  colorBg: Style.capsuleColor
  colorFg: Color.mOnSurface
  colorBgHover: Color.mHover
  colorFgHover: Color.mOnHover
  colorBorder: "transparent"
  colorBorderHover: "transparent"

  border.color: Style.capsuleBorderColor
  border.width: Style.capsuleBorderWidth

  NPopupContextMenu {
    id: contextMenu

    model: [
      {
        "label": pluginApi?.tr("barwidget.open"),
        "action": "open-panel",
        "icon": "keyboard"
      },
      {
        "label": pluginApi?.tr("barwidget.settings"),
        "action": "plugin-settings",
        "icon": "settings"
      },
    ]

    onTriggered: action => {
      contextMenu.close();
      PanelService.closeContextMenu(screen);

      if (action === "open-panel") {
        if (pluginApi) {
          pluginApi.openPanel(screen);
        }
      } else if (action === "plugin-settings") {
        if (pluginApi) {
          BarService.openPluginSettings(screen, pluginApi.manifest);
        }
      }
    }
  }

  onClicked: {
    if (pluginApi) {
      pluginApi.openPanel(screen);
    }
  }

  onRightClicked: {
    PanelService.showContextMenu(contextMenu, root, screen);
  }
}
