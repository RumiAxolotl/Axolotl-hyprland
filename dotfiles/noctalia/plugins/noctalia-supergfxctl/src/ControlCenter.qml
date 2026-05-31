/*
 * SPDX-FileCopyrightText: 2025 cod3ddot@proton.me
 *
 * SPDX-License-Identifier: MIT
 */

import QtQuick

import Quickshell

import qs.Commons
import qs.Widgets
import qs.Modules.Bar.Extras
import qs.Services.UI
import qs.Services.Noctalia

/**
	Controll center showing the current GPU mode, with an optional badge when a pending
	action is available.

	Left click to open the plugin panel
 */
// https://github.com/noctalia-dev/noctalia-shell/blob/main/Widgets/NIconButton.qml
NIconButton {
    id: root

    property ShellScreen screen

    // Plugin API (injected by PluginPanelSlot)
    property QtObject pluginApi: null
    readonly property QtObject pluginCore: pluginApi?.mainInstance

    readonly property string currentIcon: pluginCore?.getModeIcon(pluginCore.mode) ?? ""

    opacity: root.pluginCore?.available ? 1.0 : 0.5
    icon: root.currentIcon
    tooltipText: root.pluginCore?.getTooltip() ?? ""

    onClicked: root.pluginApi?.openPanel(root.screen, undefined)

    Rectangle {
        id: badge
        visible: root.pluginCore?.hasPendingAction ?? false
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 2
        anchors.topMargin: 1
        z: 2
        height: 8
        width: 8
        radius: Style.radiusXS
        color: Color.mTertiary
        border.color: Color.mSurface
        border.width: Style.borderS
    }
}
