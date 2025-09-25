import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Qt.labs.settings 1.1
import "pages" as Pages
import QtMultimedia

/* ============================================================================
   KeyDash — Main.qml (cleaned & commented)
   - Intro overlay with optional tach sweep (0→100%→0) and lamp self-test
   - Centered speed, gear, date/odo/trip
   - Shift indicator with hysteresis + optional blink
   - Over-rev flash
   - Turn signal lamps with gentle “thump” on show
   - 0–60 toast with “NEW BEST!” and persisted best time
   - Service panel (press “S”) with persisted knobs
   ==========================================================================*/

Window {
    id: root
    width: 2560; height: 720
    visible: true
    color: "#081418"
    visibility: Window.Windowed
    flags: Qt.FramelessWindowHint

    // Shared settings
    Settings {
        id: appSettings
        category: "KeyDash"

        // Existing…
        property bool useMph: true
        property real brightness: 1.0
        property bool introEnable: true
        property real introFactor: 5.0
        property int rpmMax: 8000
        property int shiftShowThreshold: 5500
        property int shiftBlinkThreshold: 6500
        property int overRevThreshold: 7200
        property bool ovEnable: true

        // ===== Device / BT =====
        property int  autoReconnectTries: 5          // 0 disables
        property int  autoReconnectBackoffMs: 2000
        property bool reconnectOnWake: true

        // ===== Display schedule =====
        property string nightStart: "19:00"
        property string nightEnd:   "06:30"
        property real   brightnessNight: 0.35        // 0..1
        property bool   clock24: false

        // ===== Smoothing (0..1, higher = faster/less smooth) =====
        property real smoothRpm:   0.35
        property real smoothBoost: 0.25
        property real smoothClt:   0.25
        property real smoothIat:   0.25
        property real smoothVbat:  0.30
        property real smoothAfr:   0.30
        property real smoothSpeed: 0.35

        // ===== 0–60 =====
        property real z60Best: 0   // already persisted elsewhere, mirroring here ok

        // ===== Logging =====
        property bool  logEnabled: false
        property int   logHz: 10                   // samples per second (1..50)
        property string logDir: ""                 // leave empty → default app data dir

        // ===== Anti burn-in =====
        property bool antiBurnIn: true
        property int  nudgePx: 1
        property int  nudgePeriodMin: 2

        // Gauges smoothing
        property bool nudgeAntiBurn: false

        // Performance
        property bool keepZ60: true
        property bool loggingEnabled: false
    }

    StackView {
        id: nav
        anchors.fill: parent
        initialItem: dashboardComponent

        // Nice slide transition
        pushEnter: Transition { NumberAnimation { properties: "x"; from: width; to: 0; duration: 180; easing.type: Easing.OutCubic } }
        pushExit:  Transition { NumberAnimation { properties: "x"; from: 0; to: -width; duration: 180; easing.type: Easing.OutCubic } }
        popEnter:  Transition { NumberAnimation { properties: "x"; from: -width; to: 0; duration: 180; easing.type: Easing.OutCubic } }
        popExit:   Transition { NumberAnimation { properties: "x"; from: 0; to: width; duration: 180; easing.type: Easing.OutCubic } }
    }

    Component {
        id: dashboardComponent
        Pages.DashboardPage {
            id: dashboardPage
            prefs: appSettings
            dashController: dash    // <- pass your C++ object if you have one
            onOpenService: nav.push(servicePage);
        }
    }

    // Create the Service page as a component to push
    Component {
        id: servicePage
        Pages.ServicePage { prefs: appSettings; dashController: dash; onDone: nav.pop() }
    }

    // Global back (Esc) to pop pages
    Shortcut {
        sequences: ["Escape", "Back"]
        onActivated: if (nav.depth > 1) nav.pop()
    }
}
