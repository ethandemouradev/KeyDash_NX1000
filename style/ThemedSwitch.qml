// File: ThemedSwitch.qml
import QtQuick
import QtQuick.Controls.Basic as Basic   // non-native so customization works

Basic.Switch {
    id: control

    property var palette: null

    // Theme tokens (colors & sizes) for the switch control
    property color trackOff:    "#475569"        // slate/off
    property color trackOn:     (palette && palette.primaryColor   !== undefined) ? palette.primaryColor   : "#0b74a3"        // primary/on
    property color thumbColor:  "#ffcc00"        // accent thumb
    property color thumbDown:   Qt.darker(thumbColor, 1.25)
    property color disabledCol: "#7a8691"        // gray when disabled

    // Sizes
    property int trackW: 64
    property int trackH: 34
    property int thumbD: 26
    property int radius: Math.round(trackH / 2)

    implicitWidth:  trackW
    implicitHeight: Math.max(trackH, thumbD)

    // Label (optional): use contentItem to keep default behavior
    // contentItem: Text { text: control.text; color: "white"; font.pixelSize: 18 }

    // Track (background) and animated thumb
    indicator: Rectangle {
        id: track
        implicitWidth: control.trackW
        implicitHeight: control.trackH
        radius: control.radius

        property color baseCol: !control.enabled ? control.disabledCol
                              : control.checked  ? control.trackOn
                              : control.trackOff
        color: control.down     ? Qt.darker(baseCol, 1.1)
             : control.hovered  ? Qt.lighter(baseCol, 1.06)
             : baseCol

        // ✅ animate this rectangle's color
        Behavior on color { ColorAnimation { duration: 100 } }

        Rectangle {
            id: thumb
            width: control.thumbD
            height: control.thumbD
            radius: width / 2
            y: (track.height - height) / 2
            x: control.checked
                 ? (track.width - width - (track.height - height) / 2)
                 : ((track.height - height) / 2)
            color: !control.enabled
                     ? control.disabledCol
                     : control.down
                        ? control.thumbDown
                        : control.thumbColor
            border.color: Qt.darker(color, 1.5)
            border.width: 1

            Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 100 } }
        }
    }
}
