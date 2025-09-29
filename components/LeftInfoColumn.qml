import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    // size to match your left panel area
    property alias row1Choices: r1.choices
    property alias row2Choices: r2.choices
    property alias row3Choices: r3.choices
    property alias row4Choices: r4.choices
    property alias row5Choices: r5.choices

    // (optional) typography
    property string fontName: Qt.application.font.family

    // access to your data source (set this from the parent)
    property var dashController: null

    // light border lines to match your theme (set to 0 to hide)
    property color stroke: "#FFC300"    // your yellow
    property int   strokeW: 4

    // --- helpers ---
    function metricValue(metric) {
        if (!dashController) return "--"
        switch (metric) {
        case "Boost":   return (dashController.mapKpa - 100).toFixed(1)   // example psi converter if you want
        case "AFR":     return dashController.afr?.toFixed(1)
        case "Lambda":  return dashController.lambda?.toFixed(2)
        case "TPS":     return dashController.tps?.toFixed(0)
        case "CLT":     return dashController.coolantC?.toFixed(0)
        case "IAT":     return dashController.iatC?.toFixed(0)
        case "VBatt":   return dashController.vbatt?.toFixed(1)
        default:        return "--"
        }
    }

    function metricUnit(metric) {
        switch (metric) {
        case "Boost":   return "psi"
        case "AFR":     return "AFR"
        case "Lambda":  return "λ"
        case "TPS":     return "%"
        case "CLT":     return "°C"
        case "IAT":     return "°C"
        case "VBatt":   return "V"
        default:        return ""
        }
    }

    function metricIcon(metric) {
        // point these to your qrc icons (placeholders below)
        switch (metric) {
        case "Boost":   return "qrc:/KeyDash_NX1000/assets/icons/boost.png"
        case "AFR":     return "qrc:/KeyDash_NX1000/assets/icons/lambda.png"
        case "Lambda":  return "qrc:/KeyDash_NX1000/assets/icons/lambda.png"
        case "TPS":     return "qrc:/KeyDash_NX1000/assets/icons/tps.png"
        case "CLT":     return "qrc:/KeyDash_NX1000/assets/icons/coolant.png"
        case "IAT":     return "qrc:/KeyDash_NX1000/assets/icons/therm.png"
        case "VBatt":   return "qrc:/KeyDash_NX1000/assets/icons/battery.png"
        default:        return ""
        }
    }

    // grid
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: [r1, r2, r3, r4, r5]
            delegate: Rectangle {
                required property RowWidget rowRef
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height/5
                color: "transparent"
                border.color: root.stroke
                border.width: root.strokeW
                radius: 0

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 18

                    Image {
                        source: root.metricIcon(rowRef.currentMetric)
                        fillMode: Image.PreserveAspectFit
                        Layout.preferredWidth: 64
                        Layout.fillHeight: true
                        antialiasing: true
                    }

                    Item { Layout.fillWidth: true }

                    // value + unit
                    RowLayout {
                        spacing: 14
                        Text {
                            text: root.metricValue(rowRef.currentMetric) ?? "--"
                            font.family: root.fontName
                            font.pixelSize: Math.round(height*0.45)
                            color: "#FFC300"
                            verticalAlignment: Text.AlignVCenter
                        }
                        Text {
                            text: root.metricUnit(rowRef.currentMetric)
                            font.family: root.fontName
                            font.pixelSize: Math.round(height*0.28)
                            color: "#FFC300"
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                TapHandler {
                    onTapped: rowRef.next()
                }
            }
        }
    }

    // --- five row state machines ---
    RowWidget { id: r1 }
    RowWidget { id: r2 }
    RowWidget { id: r3 }
    RowWidget { id: r4 }
    RowWidget { id: r5 }

    // small internal “row” object
    component RowWidget: QtObject {
        id: rw
        property var choices: []          // e.g. ["Boost","AFR","TPS"]
        property int index: 0
        property string currentMetric: choices.length ? choices[index] : ""
        function next() { if (choices.length) { index = (index + 1) % choices.length; } }
    }
}
