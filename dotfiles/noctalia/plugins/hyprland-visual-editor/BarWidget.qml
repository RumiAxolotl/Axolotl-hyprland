import QtQuick
import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets

NIconButton {
  id: root

  // ── Injected Properties ──────────────────────────────────────────────
  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  // ── Configuration Logic (Fallback Pattern) ──────────────────────────
  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  readonly property string iconKey: cfg.icon ?? defaults.icon ?? "adjustments-horizontal"
  readonly property string iconColorKey: cfg.iconColor ?? defaults.iconColor ?? "primary"
  
  // ── Visual Configuration ─────────────────────────────────────────────────
  icon: iconKey
  
  // NIconButton already manages tooltips automatically with these two properties:
  tooltipText: pluginApi?.tr("widget.tooltip")
  tooltipDirection: BarService.getTooltipDirection(screen?.name)
  
  baseSize: Style.getCapsuleHeightForScreen(screen?.name)
  customRadius: Style.radiusM 

  colorBg: Style.capsuleColor
  
  // Color resolution with transparency protection (Alpha check)
  colorFg: {
    let resolved = Color.resolveColorKeyOptional(iconColorKey);
    if (root.containsMouse) return Color.mOnHover;
    return resolved.a > 0 ? resolved : Color.mOnSurface;
  }

  border.color: Style.capsuleBorderColor
  border.width: Style.borderS

  // Color transition smoothing
  Behavior on colorFg {
    ColorAnimation { 
      duration: Style.animationFast
      easing.type: Easing.InOutQuad 
    }
  }

  // ── Interacciones ────────────────────────────────────────────────────────
  onClicked: {
    if (pluginApi) {
      pluginApi.openPanel(root.screen, this);
    }
  }

  // Context menu (Right click)
  NPopupContextMenu {
    id: contextMenu

    model: [
      {
        "label": pluginApi?.tr("widget.menu_settings"),
        "action": "settings",
        "icon": "settings"
      },
    ]

    onTriggered: function (action) {
      contextMenu.close();
      PanelService.closeContextMenu(screen);
      if (action === "settings") {
        BarService.openPluginSettings(root.screen, pluginApi.manifest);
      }
    }
  }

  onRightClicked: {
    PanelService.showContextMenu(contextMenu, root, screen);
  }
}