// theme/Theme.qml
import QtQuick
import Qt.labs.settings 1.1

Item {
    id: root

    // Expose the values from Settings as normal properties
    property alias primaryColor:   settings.primaryColor
    property alias secondaryColor: settings.secondaryColor
    property alias bgStart:        settings.bgStart
    property alias bgEnd:          settings.bgEnd

    Settings {
        id: settings
        category: "Theme"
        property color primaryColor:   "#7ee6ff"
        property color secondaryColor: "#ffcc00"
        property color bgStart:        "#052229"
        property color bgEnd:          "#0a0f10"
    }
}
