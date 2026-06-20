import QtQuick
import Quickshell
import qs.Widgets

NIconButton {
    property ShellScreen screen
    property var pluginApi: null

    icon: "device-desktop"
    tooltipText: pluginApi?.tr("widget.tooltip")

    onClicked: {
        if (pluginApi) {
            pluginApi.togglePanel(screen);
        }
    }
}
