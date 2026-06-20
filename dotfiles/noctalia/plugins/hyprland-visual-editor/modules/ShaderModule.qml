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
    
    property string activeShaderFile: cfg.activeShaderFile ?? defaults.activeShaderFile ?? ""

    Layout.fillWidth: true
    Layout.fillHeight: true
    contentHeight: mainLayout.implicitHeight + Style.marginXL
    clip: true

    Process {
        id: scanner
        running: root.pluginDir !== ""
        command: root.pluginDir !== "" ? ["bash", root.pluginDir + "/assets/scripts/scan.sh", "shaders"] : []
        property string outputData: ""
        stdout: SplitParser { onRead: function(data) { scanner.outputData += data; } }
        onExited: (code) => {
            if (code === 0) {
                try {
                    var data = JSON.parse(scanner.outputData);
                    shaderModel.clear();
                    for (var i = 0; i < data.length; i++) { shaderModel.append(data[i]); }
                } catch (e) { 
                    Logger.e("HVE", "JSON Parsing Error in Shaders: " + e); 
                }
            }
            scanner.outputData = ""
        }
    }

    Component {
        id: shaderDelegate
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
            property string cIcon: model.icon || "help"

            property bool isActive: root.activeShaderFile === cFile

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

                        if (runScript) {
                            runScript("shader.sh", scriptArg)
                        }
                        
                        if (pluginApi) {
                            pluginApi.pluginSettings.activeShaderFile = settingArg
                            pluginApi.saveSettings()
                            
                            root.activeShaderFile = settingArg
                        }
                    }
                }
            }
        }
    }

    ListModel { id: shaderModel }

    ColumnLayout {
        id: mainLayout
        width: root.availableWidth
        spacing: Style.marginS
        Layout.margins: Style.marginM

        ColumnLayout {
            Layout.fillWidth: true; spacing: Style.marginS; Layout.margins: Style.marginL
            NText {
                text: pluginApi?.tr("shaders.header_title")
                font.weight: Font.Bold; pointSize: Style.fontSizeL; color: Color.mPrimary
            }
            NText {
                text: pluginApi?.tr("shaders.header_subtitle")
                pointSize: Style.fontSizeS; color: Color.mOnSurfaceVariant
            }
        }

        NDivider { Layout.fillWidth: true; opacity: 0.5 }

        Repeater {
            model: shaderModel
            delegate: shaderDelegate
        }
    }
}