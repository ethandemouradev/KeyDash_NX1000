import QtQuick
import QtQuick.Controls.Basic as Basic

Basic.Button {
    id: control

    // simple theme knobs
           // Themed style tokens (colors / radius) for app-wide button styling
    property color bgNormal:   "#ededed"
    property color bgHover:    "#0ea5e9"
    property color bgPressed:  "#0b74a3"
    property color bgDisabled: "#6b7280"

    property color textNormal: "#141414"
    property color textDisabled: "#cbd5e1"

    // radius only, no implicit size
    property int radius: 8

    background: Rectangle {
        radius: control.radius
        property color base: !control.enabled ? control.bgDisabled
                            : control.down    ? control.bgPressed
                            : control.hovered ? control.bgHover
                                               : control.bgNormal
        color: base
        border.width: 1
        border.color: Qt.darker(base, 1.35)
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    // ✅ text color is here
    contentItem: Text {
        text: control.text
        color: control.enabled ? control.textNormal : control.textDisabled
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
