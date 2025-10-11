import QtQuick
import QtQuick.Controls.Basic as Basic

Basic.Slider {
    id: control
    from: 0; to: 100; value: 50

    property var palette: null

    // Style tokens for the slider track/fill; knob is hidden in this theme.
    property color trackColor: "#444"
    property color fillColor: (palette && palette.primaryColor   !== undefined) ? palette.primaryColor   : "#0b74a3"
    property color disabledColor: "#777"

    background: Rectangle {
        implicitHeight: 6; radius: 3
        color: control.enabled ? control.trackColor : control.disabledColor

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: 3
            color: control.enabled ? control.fillColor : control.disabledColor
        }
    }

    // completely hide the knob
    handle: Item { visible: false; width: 0; height: 0 }
}
