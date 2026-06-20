import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Widgets
import qs.Commons
import qs.Services.UI 

NScrollView {
    id: root

    property var pluginApi: null
    property var runScript: null

    readonly property string pluginDir: pluginApi?.pluginDir || ""

    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
    
    property string activeAnimFile: cfg.activeAnimFile ?? defaults.activeAnimFile ?? ""

    Layout.fillWidth: true
    Layout.fillHeight: true
    contentHeight: mainLayout.implicitHeight + Style.marginXL
    clip: true

    Process {
        id: scanner
        running: root.pluginDir !== ""
        command: root.pluginDir !== "" ? ["bash", root.pluginDir + "/assets/scripts/scan.sh", "animations"] : []
        property string outputData: ""
        stdout: SplitParser { onRead: function(data) { scanner.outputData += data; } }
        onExited: (code) => {
            if (code === 0) {
                try {
                    var data = JSON.parse(scanner.outputData);
                    animModel.clear();
                    for (var i = 0; i < data.length; i++) { animModel.append(data[i]); }
                } catch (e) { 
                    Logger.e("HVE", "JSON Parsing Error: " + e); 
                }
            }
            scanner.outputData = ""
        }
    }

    Component {
        id: animDelegate
        NBox {
            id: cardRoot
            Layout.fillWidth: true
            radius: Style.radiusM
            implicitHeight: cardRow.implicitHeight + (Style.marginL * 2)

            property string cTitleKey: model.title || ""
            property string cDescKey: model.desc || ""
            property string cFile: model.file || ""
            property string cTag: model.tag || "USER"
            property color cColor: model.color || Color.mPrimary
            property string cIcon: model.icon || "movie"

            property bool isActive: root.activeAnimFile === cFile

            color: isActive ? Qt.alpha(cColor, 0.12) : (hoverArea.containsMouse ? Qt.alpha(cColor, 0.05) : "transparent")
            
            border.width: isActive ? Style.borderL : (hoverArea.containsMouse ? Style.borderM : Style.borderS)
            border.color: isActive ? cColor : (hoverArea.containsMouse ? Qt.alpha(cColor, 0.4) : Color.mOutline)

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            MouseArea {
                id: hoverArea; anchors.fill: parent; hoverEnabled: true
            }
            
            RowLayout {
                id: cardRow
                anchors.fill: parent; anchors.margins: Style.marginM; spacing: Style.marginM
                NIcon {
                    icon: cardRoot.cIcon
                    color: (cardRoot.isActive || hoverArea.containsMouse) ? cardRoot.cColor : Color.mOnSurfaceVariant
                    pointSize: Style.fontSizeL
                }
                ColumnLayout {
                    Layout.fillWidth: true; spacing: Style.marginS
                    RowLayout {
                        spacing: Style.marginS
                        NText {
                            text: pluginApi?.tr(cardRoot.cTitleKey)
                            font.weight: Font.Bold
                            color: cardRoot.isActive ? Color.mOnSurface : Color.mOnSurfaceVariant
                        }
                        NBox {
                            width: tagT.implicitWidth + Style.marginM
                            height: tagT.implicitHeight + Style.marginXS
                            radius: Style.radiusS
                            color: Qt.alpha(cardRoot.cColor, 0.15)
                            NText { 
                                id: tagT
                                text: cardRoot.cTag
                                pointSize: Style.fontSizeS * 0.7
                                color: cardRoot.cColor
                                anchors.centerIn: parent
                                font.weight: Font.Bold 
                            }
                        }
                    }
                    NText {
                        text: pluginApi?.tr(cardRoot.cDescKey)
                        pointSize: Style.fontSizeS; color: Color.mOnSurfaceVariant; elide: Text.ElideRight; Layout.fillWidth: true
                    }
                }
                NToggle {
                    checked: cardRoot.isActive
                    onToggled: {
                        var wasActive = cardRoot.isActive
                        var scriptArg = wasActive ? "none" : cardRoot.cFile
                        var settingArg = wasActive ? "" : cardRoot.cFile

                        if (root.runScript) {
                            root.runScript("apply_animation.sh", scriptArg)
                        }
                        
                        if (pluginApi) {
                            pluginApi.pluginSettings.activeAnimFile = settingArg
                            pluginApi.saveSettings()

                            root.activeAnimFile = settingArg
                        }
                    }
                }
            }
        }
    }

    ListModel { id: animModel }

    ColumnLayout {
        id: mainLayout
        width: root.availableWidth
        spacing: Style.marginS
        Layout.margins: Style.marginM

        ColumnLayout {
            Layout.fillWidth: true; spacing: Style.marginXS; Layout.margins: Style.marginL
            NText {
                text: pluginApi?.tr("animations.header_title")
                font.weight: Font.Bold; pointSize: Style.fontSizeL; color: Color.mPrimary
            }
            NText {
                text: pluginApi?.tr("animations.header_subtitle")
                pointSize: Style.fontSizeS; color: Color.mOnSurfaceVariant
            }
        }

        NDivider { Layout.fillWidth: true; opacity: 0.5 }

        Repeater {
            model: animModel
            delegate: animDelegate
        }
    }
}