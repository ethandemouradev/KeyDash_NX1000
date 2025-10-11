import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Qt.labs.settings 1.1
import "pages" as Pages
import "theme" as LocalTheme
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

    LocalTheme.Theme { id: appTheme }

    //flags: Qt.FramelessWindowHint

    // Application settings (persisted)
    Settings {
        id: appSettings
        category: "KeyDash"
        fileName: "appsettings.ini"

        property string badgeText: "KEYDASH"

        property bool firstStart: true

        // Core preferences
        property bool useMph: true
        property real brightness: 1.0
        property bool introEnable: true
        property real introFactor: 3.0
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
        property real smoothRpm: 0.0
        property real smoothBoost: 0.0
        property real smoothClt: 0.0
        property real smoothIat: 0.0
        property real smoothVbat: 0.0
        property real smoothAfr: 0.0
        property real smoothSpeed: 0.0

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
        property bool nudgeAntiBurn: true

        // Performance settings
        property bool keepZ60: true
        property bool loggingEnabled: false
    }

    StackView {
        id: nav
        anchors.fill: parent
        //initialItem: appSettings.firstStart ? introWizardComponent : dashboardComponent

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

    function startApp() {
        // Safety: clear any existing stack content if hot-reloading
        while (nav.depth > 0) nav.pop(null)
        if (appSettings.firstStart) {
            nav.push(introWizardComponent)
        } else {
            nav.push(dashboardComponent)
        }
    }

    Component {
        id: dashboardComponent
        Pages.DashboardPage {
            id: dashboardPage
            prefs: appSettings
            dashController: dash      // live binding straight to the C++ 'dash'
            theme: appTheme
            onOpenService: nav.push(servicePage)
        }
    }

    // Create the Service page as a component to push
    Component {
        id: servicePage
        Pages.ServicePage {
            prefs: appSettings
            dashController: dash
            theme: appTheme
            onDone: nav.pop()
            onOpenReplay: (fileUrl, autoPlay) => {
                function toUrlString(u) {
                    if (!u) return "";
                    if (typeof u === "string") return u;
                    // QUrl from dialogs etc.
                    if (u.toString) {
                        const s = u.toString();
                        // Reject random QML objects like Theme_QMLTYPE_...
                        if (s.startsWith("file:") || s.startsWith("qrc:")) return s;
                        return "";  // <- drop anything else
                    }
                    if (u.url) {
                        const s = String(u.url);
                        return (s.startsWith("file:") || s.startsWith("qrc:")) ? s : "";
                    }
                    return "";
                }

                const s = toUrlString(fileUrl);
                if (!s.length) {
                    console.warn("openReplay: invalid fileUrl:", fileUrl);
                    return;  // don’t push ReplayPage with junk
                }

                nav.push(
                    Qt.resolvedUrl("qrc:/KeyDash_NX1000/pages/ReplayPage.qml"),
                    {
                        dashController: dash,
                        prefs: appSettings,
                        reTheme: appTheme,
                        initialSource: s,
                        autoPlay: !!autoPlay
                    }
                );
            }
        }
    }

    Component {
        id: introWizardComponent
        Pages.IntroWizard {
            id: introWizard
            prefs: appSettings
            theme: appTheme
            onFinished: {
                appSettings.firstStart = false
                if (appSettings.sync) appSettings.sync()
                nav.replace(dashboardComponent) // replace Intro with Dashboard
            }
        }
    }

    Component.onCompleted: {
        Qt.callLater(startApp)
    }

    Connections {
        target: Qt.application
        onAboutToQuit: {
            try { appSettings.sync(); } catch(e) {}
        }
    }
}
