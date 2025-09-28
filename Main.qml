import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Qt.labs.settings 1.1
import "pages" as Pages
import QtMultimedia


/*
    KeyDash — Main.qml
    - Top-level window and application settings
    - Navigation StackView and components (Dashboard, Service, Replay)
    - Persisted application preferences (display, device, logging, performance)
*/
Window {
    id: root
    width: 2560
    height: 720
    visible: true
    color: "#081418"
    visibility: Window.Windowed

    //flags: Qt.FramelessWindowHint

    // Application settings (persisted)
    Settings {
        id: appSettings
        category: "KeyDash"
        // Core preferences
        property bool useMph: true
        property real brightness: 1.0
        property bool introEnable: true
        property real introFactor: 5.0
        property int rpmMax: 8000
        property int shiftShowThreshold: 4500
        property int shiftBlinkThreshold: 5500
        property int overRevThreshold: 7000
        property bool ovEnable: true
        property real odoBackupKm: 0
        property real tripBackupKm: 0

    // Device / Bluetooth settings
        property int autoReconnectTries: 5 // 0 disables
        property int autoReconnectBackoffMs: 2000
        property bool reconnectOnWake: true

    // Display schedule
        property string nightStart: "19:00"
        property string nightEnd: "06:30"
        property real brightnessNight: 0.35 // 0..1
        property bool clock24: false

    // Smoothing settings (0..1)
        property real smoothRpm: 0.35
        property real smoothBoost: 0.25
        property real smoothClt: 0.25
        property real smoothIat: 0.25
        property real smoothVbat: 0.30
        property real smoothAfr: 0.30
        property real smoothSpeed: 0.35

    // 0–60 timing
        property real z60Best: 0 // already persisted elsewhere, mirroring here ok

    // Logging
        property bool logEnabled: false
        property int logHz: 10 // samples per second (1..50)
        property string logDir: "" // leave empty → default app data dir

    // Anti burn-in
        property bool antiBurnIn: true
        property int nudgePx: 1
        property int nudgePeriodMin: 2

        // Gauges smoothing
        property bool nudgeAntiBurn: false

        // Performance settings
        property bool keepZ60: true
        property bool loggingEnabled: false
    }

    StackView {
        id: nav
        anchors.fill: parent
        initialItem: dashboardComponent

    // Navigation transitions (slide)
        pushEnter: Transition {
            NumberAnimation {
                properties: "x"
                from: width
                to: 0
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
        pushExit: Transition {
            NumberAnimation {
                properties: "x"
                from: 0
                to: -width
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
        popEnter: Transition {
            NumberAnimation {
                properties: "x"
                from: -width
                to: 0
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
        popExit: Transition {
            NumberAnimation {
                properties: "x"
                from: 0
                to: width
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
    }

    Component {
        id: dashboardComponent
        Pages.DashboardPage {
            id: dashboardPage
            prefs: appSettings
            dashController: dash      // live binding straight to the C++ 'dash'
            onOpenService: nav.push(servicePage)
        }
    }

    // Create the Service page as a component to push
    Component {
        id: servicePage
        Pages.ServicePage {
            prefs: appSettings
            dashController: dash
            onDone: nav.pop()
            onOpenReplay: (fileUrl, autoPlay) => {
                nav.push(
                    Qt.resolvedUrl("qrc:/KeyDash_NX1000/pages/ReplayPage.qml"),
                    { dashController: dash, prefs: appSettings, initialSource: fileUrl, autoPlay }
                )
            }
        }
    }
}
