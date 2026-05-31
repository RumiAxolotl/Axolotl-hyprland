import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
  id: root
  property var pluginApi: null

  // Shared state accessible from other components via pluginApi.mainInstance
  property bool isActive: false

  // IPC handler for CLI control (qs ipc call plugin:my-plugin commandName)
  IpcHandler {
    target: "plugin:hyprland-visual-editor"

    function toggle() {
      if (pluginApi) {
        pluginApi.withCurrentScreen(screen => {
          pluginApi.togglePanel(screen);
        });
      }
    }
  }
}