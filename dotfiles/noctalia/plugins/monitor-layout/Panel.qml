import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Widgets

Item {
  id: root

  property var pluginApi: null

  readonly property var geometryPlaceholder: panelContainer
  property real contentPreferredWidth: 1320 * Style.uiScaleRatio
  property real contentPreferredHeight: 660 * Style.uiScaleRatio
  readonly property bool allowAttach: true

  readonly property var mainInstance: pluginApi?.mainInstance
  readonly property var outputs: mainInstance ? mainInstance.draftOutputs : []
  readonly property var selectedOutput: mainInstance ? mainInstance.getSelectedOutput() : null
  readonly property string selectedOutputId: mainInstance ? mainInstance.selectedOutputId : ""

  property int activeTab: 0 // 0 = Control, 1 = Configuration
  property real scenePadding: 28 * Style.uiScaleRatio
  readonly property var sceneBounds: computeSceneBounds(outputs)
  readonly property real sceneScale: computeSceneScale()
  property string editPosX: ""
  property string editPosY: ""
  property string editScale: ""

  anchors.fill: parent



  function computeSceneBounds(list) {
    if (!list || list.length === 0) {
      return {
        "minX": 0,
        "minY": 0,
        "maxX": 1920,
        "maxY": 1080,
        "width": 1920,
        "height": 1080
      };
    }

    var minX = list[0].x;
    var minY = list[0].y;
    var maxX = list[0].x + layoutOutputWidth(list[0]);
    var maxY = list[0].y + layoutOutputHeight(list[0]);

    for (var index = 1; index < list.length; index++) {
      var output = list[index];
      minX = Math.min(minX, output.x);
      minY = Math.min(minY, output.y);
      maxX = Math.max(maxX, output.x + layoutOutputWidth(output));
      maxY = Math.max(maxY, output.y + layoutOutputHeight(output));
    }

    return {
      "minX": minX,
      "minY": minY,
      "maxX": maxX,
      "maxY": maxY,
      "width": Math.max(1, maxX - minX),
      "height": Math.max(1, maxY - minY)
    };
  }

  function computeSceneScale() {
    var availableWidth = sceneCanvas.width - (scenePadding * 2);
    var availableHeight = sceneCanvas.height - (scenePadding * 2);
    if (availableWidth <= 0 || availableHeight <= 0) {
      return 1;
    }

    return Math.max(0.02, Math.min(availableWidth / sceneBounds.width, availableHeight / sceneBounds.height));
  }

  function layoutToCanvasX(value) {
    return scenePadding + ((value - sceneBounds.minX) * sceneScale);
  }

  function layoutToCanvasY(value) {
    return scenePadding + ((value - sceneBounds.minY) * sceneScale);
  }

  function canvasToLayoutX(value) {
    return sceneBounds.minX + ((value - scenePadding) / sceneScale);
  }

  function canvasToLayoutY(value) {
    return sceneBounds.minY + ((value - scenePadding) / sceneScale);
  }

  function outputWidth(output) {
    return Math.max(24 * Style.uiScaleRatio, layoutOutputWidth(output) * sceneScale);
  }

  function outputHeight(output) {
    return Math.max(16 * Style.uiScaleRatio, layoutOutputHeight(output) * sceneScale);
  }

  function layoutOutputWidth(output) {
    return output && output.logicalWidth ? output.logicalWidth : output.width;
  }

  function layoutOutputHeight(output) {
    return output && output.logicalHeight ? output.logicalHeight : output.height;
  }

  function resolutionSummary(output) {
    if (!output) {
      return "";
    }

    var scaleText = output.scale && output.scale !== 1 ? "  |  " + pluginApi?.tr("panel.scale") + ": " + output.scale : "";
    return output.resolutionLabel + scaleText;
  }

  function syncPositionInputs() {
    if (!selectedOutput) {
      editPosX = "";
      editPosY = "";
      editScale = "";
      return;
    }

    editPosX = String(selectedOutput.x);
    editPosY = String(selectedOutput.y);
    editScale = String(selectedOutput.scale);
  }

  function parseCoordinate(text, fallbackValue) {
    var parsed = parseInt((text || "").trim());
    return isFinite(parsed) ? parsed : fallbackValue;
  }

  function applyTypedPosition() {
    if (!mainInstance || !selectedOutput) {
      return;
    }

    var nextX = parseCoordinate(editPosX, selectedOutput.x);
    var nextY = parseCoordinate(editPosY, selectedOutput.y);
    mainInstance.setOutputPosition(selectedOutput.outputId, nextX, nextY, true);
    editPosX = String(nextX);
    editPosY = String(nextY);
  }

  function parseScaleValue(text, fallbackValue) {
    var parsed = Number((text || "").trim());
    return isFinite(parsed) && parsed > 0 ? parsed : fallbackValue;
  }

  function applyTypedScale() {
    if (!mainInstance || !selectedOutput) {
      return;
    }

    var nextScale = parseScaleValue(editScale, selectedOutput.scale);
    mainInstance.setOutputScale(selectedOutput.outputId, nextScale);
    editScale = String(nextScale);
  }

  onSelectedOutputChanged: {
    syncPositionInputs();
  }

  function resolutionModel(output) {
    if (!output) {
      return [];
    }

    var model = [];
    var modes = output.availableModes || [];
    for (var index = 0; index < modes.length; index++) {
      var hz = Number(modes[index].refresh || 0).toFixed(2).replace(/\.00$/, "");
      var compactLabel = modes[index].width + "x" + modes[index].height + (hz === "0" ? "" : "@" + hz);
      model.push({
        "key": modes[index].id,
        "name": compactLabel
      });
    }
    return model;
  }

  function escapeForShell(text) {
    return String(text || "").replace(/'/g, "'\\''");
  }

  function copyToClipboard(text) {
    var escaped = escapeForShell(text);
    var cmd = `printf '%s' '${escaped}' | wl-copy || printf '%s' '${escaped}' | xclip -selection clipboard || printf '%s' '${escaped}' | xsel --clipboard --input`;
    Quickshell.execDetached(["sh", "-c", cmd]);
  }

  Item {
    id: panelContainer
    anchors.fill: parent

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Style.marginL
      spacing: Style.marginL

      // Tab bar
      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        NButton {
          text: pluginApi?.tr("panel.tabControl")
          onClicked: root.activeTab = 0
        }

        NButton {
          text: pluginApi?.tr("panel.tabConfiguration")
          onClicked: root.activeTab = 1
        }

        Item {
          Layout.fillWidth: true
        }
      }

      // Control tab content
      Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: root.activeTab === 0

        RowLayout {
          anchors.fill: parent
          spacing: Style.marginL

          NBox {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
              anchors.fill: parent
              anchors.margins: Style.marginM
              spacing: Style.marginM

              NText {
                text: pluginApi?.tr("panel.canvasTitle")
                pointSize: Style.fontSizeL
                font.weight: Style.fontWeightBold
                color: Color.mOnSurface
              }

              NText {
                text: pluginApi?.tr("panel.dragHint")
                pointSize: Style.fontSizeS
                color: Color.mOnSurfaceVariant
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                maximumLineCount: 2
                elide: Text.ElideRight
              }

              Item {
                id: sceneCanvas
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                NBox {
                  id: sceneFrame
                  anchors.fill: parent
                  border.color: Color.mOutline
                  border.width: Style.borderS
                }

                Canvas {
                  id: sceneBackground
                  anchors.fill: parent
                  anchors.margins: Style.borderS
                  onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();

                    var width = sceneBackground.width;
                    var height = sceneBackground.height;
                    var innerX = root.scenePadding;
                    var innerY = root.scenePadding;
                    var innerWidth = width - (root.scenePadding * 2);
                    var innerHeight = height - (root.scenePadding * 2);

                    ctx.fillStyle = Qt.alpha(Color.mSurfaceVariant, 0.45);
                    ctx.fillRect(0, 0, width, height);

                    ctx.strokeStyle = Qt.alpha(Color.mOutline, 0.16);
                    ctx.lineWidth = 1;

                    var columnCount = 16;
                    var columnStep = Math.max(40 * Style.uiScaleRatio, innerWidth / columnCount);
                    for (var column = 0; column < columnCount; column++) {
                      var columnX = innerX + (column * columnStep);
                      ctx.beginPath();
                      ctx.moveTo(columnX, innerY);
                      ctx.lineTo(columnX, innerY + innerHeight);
                      ctx.stroke();
                    }

                    var rowCount = 10;
                    var rowStep = Math.max(32 * Style.uiScaleRatio, innerHeight / rowCount);
                    for (var row = 0; row < rowCount; row++) {
                      var rowY = innerY + (row * rowStep);
                      ctx.beginPath();
                      ctx.moveTo(innerX, rowY);
                      ctx.lineTo(innerX + innerWidth, rowY);
                      ctx.stroke();
                    }
                  }
                }

                Connections {
                  target: root

                  function onScenePaddingChanged() {
                    sceneBackground.requestPaint();
                  }
                }

                Connections {
                  target: sceneCanvas

                  function onWidthChanged() {
                    sceneBackground.requestPaint();
                  }

                  function onHeightChanged() {
                    sceneBackground.requestPaint();
                  }
                }

                NText {
                  anchors.centerIn: parent
                  visible: outputs.length === 0
                  text: pluginApi?.tr("panel.empty")
                  pointSize: Style.fontSizeM
                  color: Color.mOnSurfaceVariant
                }

                Repeater {
                  model: outputs

                  delegate: Item {
                    id: outputTile

                    property var outputData: modelData
                    property real pressSceneX: 0
                    property real pressSceneY: 0
                    property real pressOutputX: 0
                    property real pressOutputY: 0
                    property bool dragging: false
                    property real dragOffsetSceneX: 0
                    property real dragOffsetSceneY: 0
                    property real badgeHeight: Math.max(26 * Style.uiScaleRatio, height * 0.18)

                    x: root.layoutToCanvasX(outputData.x) + dragOffsetSceneX
                    y: root.layoutToCanvasY(outputData.y) + dragOffsetSceneY
                    width: root.outputWidth(outputData)
                    height: root.outputHeight(outputData)
                    z: outputData.outputId === root.selectedOutputId ? 2 : 1
                    clip: true

                    NBox {
                      anchors.fill: parent
                      border.color: outputData.outputId === root.selectedOutputId ? Color.mPrimary : Color.mOutline
                      border.width: outputData.outputId === root.selectedOutputId ? 2 : 1

                      NBox {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Style.marginXS
                        height: outputTile.badgeHeight
                        border.color: outputData.outputId === root.selectedOutputId ? Color.mPrimary : Qt.alpha(Color.mOutline, 0.55)
                        border.width: Style.borderS
                      }
                    }

                    NText {
                      anchors.left: parent.left
                      anchors.right: parent.right
                      anchors.top: parent.top
                      anchors.topMargin: Style.marginXS
                      anchors.leftMargin: Style.marginS
                      anchors.rightMargin: Style.marginS
                      height: outputTile.badgeHeight
                      text: outputData.name
                      pointSize: Style.fontSizeXS
                      font.weight: Style.fontWeightBold
                      color: Color.mOnSurface
                      horizontalAlignment: Text.AlignHCenter
                      verticalAlignment: Text.AlignVCenter
                      elide: Text.ElideRight
                    }

                    NText {
                      anchors.left: parent.left
                      anchors.right: parent.right
                      anchors.top: parent.top
                      anchors.topMargin: outputTile.badgeHeight + (Style.marginS * 2)
                      anchors.leftMargin: Style.marginS
                      anchors.rightMargin: Style.marginS
                      text: outputData.resolutionLabel
                      pointSize: Style.fontSizeXXS
                      color: Color.mOnSurfaceVariant
                      horizontalAlignment: Text.AlignHCenter
                      elide: Text.ElideRight
                      visible: outputTile.height > (outputTile.badgeHeight + (Style.marginL * 2))
                    }

                    NText {
                      anchors.left: parent.left
                      anchors.right: parent.right
                      anchors.bottom: parent.bottom
                      anchors.bottomMargin: Style.marginXS
                      anchors.leftMargin: Style.marginS
                      anchors.rightMargin: Style.marginS
                      text: outputData.x + ", " + outputData.y
                      pointSize: Style.fontSizeXXS
                      color: Color.mOnSurfaceVariant
                      horizontalAlignment: Text.AlignHCenter
                      elide: Text.ElideRight
                      visible: outputTile.height > (outputTile.badgeHeight + (Style.marginL * 3))
                    }

                    MouseArea {
                      id: dragArea
                      anchors.fill: parent
                      acceptedButtons: Qt.LeftButton
                      hoverEnabled: true
                      preventStealing: true
                      cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

                      onPressed: mouse => {
                        var scenePoint = dragArea.mapToItem(sceneCanvas, mouse.x, mouse.y);
                        outputTile.pressSceneX = scenePoint.x;
                        outputTile.pressSceneY = scenePoint.y;
                        outputTile.pressOutputX = outputData.x;
                        outputTile.pressOutputY = outputData.y;
                        outputTile.dragging = true;
                        outputTile.dragOffsetSceneX = 0;
                        outputTile.dragOffsetSceneY = 0;
                        if (mainInstance) {
                          mainInstance.selectOutput(outputData.outputId);
                        }
                      }

                      onPositionChanged: mouse => {
                        if (!(mouse.buttons & Qt.LeftButton) || !outputTile.dragging || root.sceneScale <= 0) {
                          return;
                        }

                        var scenePoint = dragArea.mapToItem(sceneCanvas, mouse.x, mouse.y);
                        outputTile.dragOffsetSceneX = scenePoint.x - outputTile.pressSceneX;
                        outputTile.dragOffsetSceneY = scenePoint.y - outputTile.pressSceneY;
                      }

                      onReleased: mouse => {
                        if (!outputTile.dragging) {
                          return;
                        }

                        outputTile.dragging = false;

                        if (!mainInstance || root.sceneScale <= 0) {
                          outputTile.dragOffsetSceneX = 0;
                          outputTile.dragOffsetSceneY = 0;
                          return;
                        }

                        var scenePoint = dragArea.mapToItem(sceneCanvas, mouse.x, mouse.y);
                        var deltaX = (scenePoint.x - outputTile.pressSceneX) / root.sceneScale;
                        var deltaY = (scenePoint.y - outputTile.pressSceneY) / root.sceneScale;
                        mainInstance.setOutputPosition(outputData.outputId, outputTile.pressOutputX + deltaX, outputTile.pressOutputY + deltaY, true);

                        outputTile.dragOffsetSceneX = 0;
                        outputTile.dragOffsetSceneY = 0;
                      }

                      onCanceled: {
                        outputTile.dragging = false;
                        outputTile.dragOffsetSceneX = 0;
                        outputTile.dragOffsetSceneY = 0;
                      }
                    }
                  }
                }
              }
            }
          }

          NBox {
            Layout.preferredWidth: 320 * Style.uiScaleRatio
            Layout.minimumWidth: 320 * Style.uiScaleRatio
            Layout.maximumWidth: 320 * Style.uiScaleRatio
            Layout.fillHeight: true

            ColumnLayout {
              anchors.fill: parent
              anchors.margins: Style.marginM
              spacing: Style.marginM

              NText {
                text: pluginApi?.tr("panel.inspectorTitle")
                pointSize: Style.fontSizeL
                font.weight: Style.fontWeightBold
                color: Color.mOnSurface
              }

              NText {
                visible: !selectedOutput
                text: pluginApi?.tr("panel.selectionHint")
                pointSize: Style.fontSizeS
                color: Color.mOnSurfaceVariant
                wrapMode: Text.WordWrap
              }

              NScrollView {
                id: inspectorScroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalPolicy: ScrollBar.AlwaysOff
                verticalPolicy: ScrollBar.AsNeeded
                reserveScrollbarSpace: true
                visible: !!selectedOutput

                ColumnLayout {
                  width: parent.width
                  spacing: Style.marginM

                  NText {
                    text: selectedOutput ? selectedOutput.name : ""
                    pointSize: Style.fontSizeM
                    font.weight: Style.fontWeightBold
                    color: Color.mOnSurface
                  }

                  NText {
                    Layout.fillWidth: true
                    text: selectedOutput && selectedOutput.description !== "" ? selectedOutput.description : "-"
                    pointSize: Style.fontSizeS
                    color: Color.mOnSurfaceVariant
                    wrapMode: Text.NoWrap
                    elide: Text.ElideRight
                  }

                  NText {
                    text: pluginApi?.tr("panel.resolution")
                    pointSize: Style.fontSizeS
                    color: Color.mOnSurfaceVariant
                  }

                  Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: resolutionCombo.implicitHeight

                    NComboBox {
                      id: resolutionCombo
                      anchors.left: parent.left
                      anchors.right: parent.right
                      width: parent.width
                      model: root.resolutionModel(selectedOutput)
                      currentKey: selectedOutput ? selectedOutput.modeId : ""
                      onSelected: key => {
                        if (selectedOutput && mainInstance) {
                          mainInstance.setOutputResolution(selectedOutput.outputId, key);
                        }
                      }
                    }
                  }

                  NText {
                    text: root.resolutionSummary(selectedOutput)
                    pointSize: Style.fontSizeS
                    color: Color.mOnSurfaceVariant
                    wrapMode: Text.WordWrap
                  }

                  NText {
                    text: pluginApi?.tr("panel.position")
                    pointSize: Style.fontSizeS
                    color: Color.mOnSurfaceVariant
                  }

                  RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginS

                    NTextInput {
                      Layout.fillWidth: true
                      label: pluginApi?.tr("panel.positionX")
                      text: root.editPosX
                      onTextChanged: root.editPosX = text
                      onEditingFinished: root.applyTypedPosition()
                    }

                    NTextInput {
                      Layout.fillWidth: true
                      label: pluginApi?.tr("panel.positionY")
                      text: root.editPosY
                      onTextChanged: root.editPosY = text
                      onEditingFinished: root.applyTypedPosition()
                    }
                  }

                  NButton {
                    text: pluginApi?.tr("panel.setPosition")
                    enabled: !!selectedOutput && !!mainInstance
                    onClicked: root.applyTypedPosition()
                  }

                  NText {
                    text: pluginApi?.tr("panel.scale")
                    pointSize: Style.fontSizeS
                    color: Color.mOnSurfaceVariant
                  }

                  RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginS

                    NTextInput {
                      id: scaleInput
                      Layout.fillWidth: true
                      text: root.editScale
                      onTextChanged: root.editScale = text
                      onEditingFinished: root.applyTypedScale()
                    }

                    NButton {
                      text: pluginApi?.tr("panel.setScale")
                      enabled: !!selectedOutput && !!mainInstance
                      onClicked: root.applyTypedScale()
                    }
                  }

                  NText {
                    text: pluginApi?.tr("panel.scaleDesc")
                    pointSize: Style.fontSizeS
                    color: Color.mOnSurfaceVariant
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                  }

                  NText {
                    text: pluginApi?.tr("panel.transform") + ": " + (selectedOutput ? selectedOutput.transform : "")
                    pointSize: Style.fontSizeS
                    color: Color.mOnSurfaceVariant
                  }

                  NText {
                    text: pluginApi?.tr("panel.backend") + ": " + (mainInstance ? mainInstance.backendId : "")
                    pointSize: Style.fontSizeS
                    color: Color.mOnSurfaceVariant
                  }

                }
              }

              NText {
                visible: mainInstance && mainInstance.statusText !== ""
                text: mainInstance ? mainInstance.statusText : ""
                pointSize: Style.fontSizeS
                color: Color.mPrimary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
              }

              NText {
                visible: mainInstance && mainInstance.errorText !== ""
                text: mainInstance ? mainInstance.errorText : ""
                pointSize: Style.fontSizeS
                color: Color.mError
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
              }

              NText {
                visible: mainInstance && mainInstance.hasPendingChanges
                text: pluginApi?.tr("panel.pendingChanges")
                pointSize: Style.fontSizeS
                color: Color.mPrimary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
              }

              NButton {
                Layout.fillWidth: true
                text: pluginApi?.tr("actions.refresh")
                enabled: mainInstance && !mainInstance.isRefreshing && !mainInstance.isApplying
                onClicked: mainInstance.refreshOutputs()
              }

              NButton {
                Layout.fillWidth: true
                text: pluginApi?.tr("actions.reset")
                enabled: mainInstance && mainInstance.hasPendingChanges && !mainInstance.isApplying
                onClicked: mainInstance.resetDraftOutputs()
              }

              NButton {
                Layout.fillWidth: true
                text: pluginApi?.tr("actions.apply")
                enabled: mainInstance && mainInstance.hasPendingChanges && !mainInstance.isApplying
                onClicked: mainInstance.applyLayout()
              }
            }
          }
        }
      }

      // Configuration tab content
      Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: root.activeTab === 1

        NBox {
          anchors.fill: parent

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: Style.marginM
            spacing: Style.marginM

            NText {
              text: pluginApi?.tr("panel.configTitle")
              pointSize: Style.fontSizeL
              font.weight: Style.fontWeightBold
              color: Color.mOnSurface
            }

            NText {
              text: pluginApi?.tr("panel.configDescription")
              pointSize: Style.fontSizeS
              color: Color.mOnSurfaceVariant
              wrapMode: Text.WordWrap
              Layout.fillWidth: true
            }

            NText {
              visible: mainInstance && mainInstance.errorText !== ""
              text: mainInstance ? mainInstance.errorText : ""
              pointSize: Style.fontSizeS
              color: Color.mError
              wrapMode: Text.WordWrap
              Layout.fillWidth: true
            }

            Item {
              Layout.fillWidth: true
              Layout.fillHeight: true

              NScrollView {
                anchors.fill: parent
                horizontalPolicy: ScrollBar.AsNeeded
                verticalPolicy: ScrollBar.AsNeeded

                NBox {
                  width: parent.width - 12 * Style.uiScaleRatio
                  border.color: Color.mOutline
                  border.width: Style.borderS

                  ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginS

                    NText {
                      text: {
                        if (!mainInstance) return "";
                        var cfg = mainInstance.getConfigurationScript();
                        if (cfg.error) return cfg.error;
                        return cfg.content || "";
                      }
                      pointSize: Style.fontSizeS
                      font.family: "Monospace"
                      color: Color.mOnSurfaceVariant
                      wrapMode: Text.Wrap
                      textFormat: Text.PlainText
                      Layout.fillWidth: true
                      Layout.fillHeight: true
                    }
                  }
                }
              }
            }

            RowLayout {
              Layout.fillWidth: true
              spacing: Style.marginM

              NButton {
                Layout.fillWidth: true
                text: pluginApi?.tr("actions.copyConfig")
                enabled: mainInstance && !mainInstance.getConfigurationScript().error
                onClicked: {
                  var cfg = mainInstance.getConfigurationScript();
                  if (!cfg.error) {
                    var backend = cfg.backend || "unknown";
                    var header = "# " + backend + " monitor configuration\n";
                    var fullText = header + cfg.content;

                    copyToClipboard(fullText);
                    mainInstance.statusText = pluginApi?.tr("status.configCopied");
                  }
                }
              }

              NButton {
                text: pluginApi?.tr("actions.refresh")
                enabled: mainInstance && !mainInstance.isRefreshing && !mainInstance.isApplying
                onClicked: mainInstance.refreshOutputs()
              }
            }
          }
        }
      }
    }
  }
}
