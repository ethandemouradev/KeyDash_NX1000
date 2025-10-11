// theme/Theme.qml
import QtQuick
import Qt.labs.settings 1.1

Item {
    id: root

    // Expose the values from Settings as normal properties
    property alias primaryColor:   themeSettings.primaryColor
    property alias secondaryColor: themeSettings.secondaryColor
    property alias bgStart:        themeSettings.bgStart
    property alias bgEnd:          themeSettings.bgEnd

    Settings {
        id: themeSettings
        category: "Theme"
        fileName: "theme.ini"
        property color primaryColor:   "#7ee6ff"
        property color secondaryColor: "#ffcc00"
        property color bgStart:        "#052229"
        property color bgEnd:          "#0a0f10"
    }
}
