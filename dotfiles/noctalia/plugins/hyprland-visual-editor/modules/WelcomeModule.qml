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
    
    property bool isSystemActive: cfg.isSystemActive ?? defaults.isSystemActive ?? false

    Layout.fillWidth: true
    Layout.fillHeight: true
    contentHeight: mainLayout.implicitHeight + (Style.marginXL * 2)
    clip: true

    ColumnLayout {
        id: mainLayout
        width: root.availableWidth
        spacing: Style.marginXL
        Layout.margins: Style.marginL

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: Style.marginXL
            Layout.bottomMargin: Style.marginM
            Layout.alignment: Qt.AlignHCenter

            Image {
                source: "../assets/owl_neon.png"
                fillMode: Image.PreserveAspectFit
                Layout.preferredHeight: 400 * Style.uiScaleRatio
                Layout.preferredWidth: 600 * Style.uiScaleRatio
                Layout.alignment: Qt.AlignHCenter
                smooth: true
            }
        }

        NDivider { Layout.fillWidth: true }

        ProCard {
            title: pluginApi?.tr("welcome.activation_title")
            iconName: "power"
            accentColor: root.isSystemActive ? Color.mPrimary : Color.mError
            description: root.isSystemActive
                ? (pluginApi?.tr("welcome.system_active"))
                : (pluginApi?.tr("welcome.system_inactive"))

            extraContent: ColumnLayout {
                spacing: Style.marginM
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: Style.marginM
                    NText {
                        text: pluginApi?.tr("welcome.enable_label")
                        font.weight: Font.Bold
                        pointSize: Style.fontSizeL
                        color: Color.mOnSurface
                    }
                    Item { Layout.fillWidth: true }
                    
                    NToggle {
                        checked: root.isSystemActive
                        onToggled: {
                            var newState = !root.isSystemActive
                            
                            if (pluginApi) {
                                pluginApi.pluginSettings.isSystemActive = newState
                                pluginApi.saveSettings()
                                var statusMsg = newState ? pluginApi?.tr("welcome.toast.enabled") : pluginApi?.tr("welcome.toast.disabled")
                                ToastService.showNotice(statusMsg)
                            }

                            if (runScript) {
                                runScript("init.sh", newState ? "enable" : "disable")
                            }
                            
                            root.isSystemActive = newState
                        }
                    }
                }

                NBox {
                    visible: !root.isSystemActive
                    Layout.fillWidth: true
                    implicitHeight: warnCol.implicitHeight + (Style.marginM * 2)
                    color: Qt.alpha(Color.mError, 0.08)
                    radius: Style.radiusM
                    border.color: Qt.alpha(Color.mError, 0.3)
                    border.width: Style.borderS
                    RowLayout {
                        id: warnCol
                        anchors.fill: parent; anchors.margins: Style.marginM; spacing: Style.marginM
                        NIcon { icon: "alert-circle"; color: Color.mError; pointSize: Style.fontSizeXL; Layout.alignment: Qt.AlignTop }
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: Style.marginXS
                            NText {
                                text: pluginApi?.tr("welcome.warning.title")
                                font.weight: Font.Bold; color: Color.mError; pointSize: Style.fontSizeS
                            }
                            NText {
                                text: pluginApi?.tr("welcome.warning.text")
                                color: Color.mOnSurfaceVariant; wrapMode: Text.WordWrap; textFormat: Text.RichText; Layout.fillWidth: true; pointSize: Style.fontSizeS
                            }
                        }
                    }
                }
            }
        }

        ProCard {
            title: pluginApi?.tr("welcome.features.title")
            iconName: "star"; accentColor: Color.mTertiary
            description: pluginApi?.tr("welcome.features.description")
            extraContent: ColumnLayout {
                spacing: Style.marginXS
                Repeater {
                    model: [
                        "welcome.features.list.fluid_anim",
                        "welcome.features.list.smart_borders",
                        "welcome.features.list.realtime_shaders",
                        "welcome.features.list.non_destructive"
                    ]
                    delegate: RowLayout {
                        spacing: Style.marginS
                        NIcon { icon: "check"; color: Color.mPrimary; pointSize: Style.fontSizeM }
                        NText { text: pluginApi?.tr(modelData); color: Color.mOnSurfaceVariant; pointSize: Style.fontSizeS; textFormat: Text.RichText }
                    }
                }
            }
        }
        
        ProCard {
            title: pluginApi?.tr("welcome.docs.title")
            iconName: "book"; accentColor: Color.mSecondary
            description: pluginApi?.tr("welcome.docs.description")
            extraContent: ColumnLayout {
                spacing: Style.marginL
                NText {
                    Layout.fillWidth: true; wrapMode: Text.Wrap; color: Color.mOnSurfaceVariant; font.pointSize: Style.fontSizeS; textFormat: Text.RichText
                    text: pluginApi?.tr("welcome.docs.summary")
                }
                RowLayout {
                    spacing: Style.marginM; Layout.fillWidth: true
                    NButton {
                        text: pluginApi?.tr("welcome.docs.btn_readme")
                        icon: "external-link"; Layout.fillWidth: true
                        onClicked: Qt.openUrlExternally("file://" + pluginDir + "/README.md")
                    }
                    NButton {
                        text: pluginApi?.tr("welcome.docs.btn_folder")
                        icon: "folder"; Layout.fillWidth: true
                        onClicked: Qt.openUrlExternally("file://" + pluginDir + "/")
                    }
                }
            }
        }

        ProCard {
            title: pluginApi?.tr("welcome.credits.title")
            iconName: "heart"; accentColor: Color.mOutline
            description: pluginApi?.tr("welcome.credits.description")
            extraContent: ColumnLayout {
                spacing: Style.marginM
                NButton {
                    text: pluginApi?.tr("welcome.credits.btn_hyde")
                    icon: "brand-github"; Layout.fillWidth: true
                    onClicked: Qt.openUrlExternally("https://github.com/HyDE-Project/")
                }
                NDivider { Layout.fillWidth: true }
                RowLayout {
                    spacing: Style.marginM
                    NIcon { icon: "code"; color: Color.mOnSurfaceVariant; pointSize: Style.fontSizeL }
                    ColumnLayout {
                        spacing: Style.marginXS
                        NText { text: pluginApi?.tr("welcome.credits.ai_title"); font.weight: Font.Bold }
                        NText {
                            text: pluginApi?.tr("welcome.credits.ai_desc")
                            color: Color.mOnSurfaceVariant; wrapMode: Text.Wrap; Layout.fillWidth: true; pointSize: Style.fontSizeS
                        }
                    }
                }
            }
        }
    }

    component ProCard : NBox {
        id: cardRoot
        property string title; property string iconName; property string description
        property color accentColor; property Component extraContent: null
        Layout.fillWidth: true; Layout.leftMargin: Style.marginL; Layout.rightMargin: Style.marginL
        implicitHeight: cardCol.implicitHeight + (Style.marginL * 2)
        radius: Style.radiusM
        border.color: Qt.alpha(accentColor, 0.3); border.width: Style.borderM
        color: Qt.alpha(accentColor, 0.03)
        ColumnLayout {
            id: cardCol; anchors.fill: parent; anchors.margins: Style.marginL; spacing: Style.marginM
            RowLayout {
                spacing: Style.marginM
                NIcon { icon: iconName; color: accentColor; pointSize: Style.fontSizeL }
                NText { text: cardRoot.title; font.weight: Font.Bold; pointSize: Style.fontSizeL }
            }
            NDivider { Layout.fillWidth: true; opacity: 0.2 }
            NText { text: cardRoot.description; color: Color.mOnSurface; wrapMode: Text.WordWrap; Layout.fillWidth: true; textFormat: Text.RichText }
            Loader { active: extraContent !== null; sourceComponent: extraContent; Layout.fillWidth: true }
        }
    }
}