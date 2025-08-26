import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Qt.labs.settings 1.1
//import QtCore
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

    /* =============================
       Global knobs (persisted below)
       ============================= */
    property bool useMph: true
    property real brightness: 1.0

    // Intro
    property bool introEnable: true
    property real introFactor: 1.8   // scales intro animation durations

    // Over-rev flash
    property bool overRevEnable: true
    property int  overRevThreshold: 6500
    property int  overRevHysteresis: 150
    property real overRevIntensity: 0.35  // 0..1
    property real overRevHz: 3.0          // flashes per second

    // Tach placement / scaling
    property int tachBarX: 813
    property int tachBarY: 60
    property int rpmMax:   8000
    property int rpmMin: 450    // 500 rpm = 0%

    // 0–60 options
    property bool  z60Enable: true
    property real  z60ShowSecs: 5.0
    property real  z60TargetMph: 60.0
    property real  z60StartThresholdMph: 1.0
    property real  z60Best: 0
    property bool  z60IsNewBest: false

    // 0–60 runtime state (not persisted)
    property bool z60Armed:  false
    property bool z60Timing: false
    property real z60T0ms:   0
    property real z60Time:   0
    property bool z60Popup:  false

    // Alerts
    property bool cltWarn: false

    // Over-rev oscillator phase (drives smooth flash)
    property real overRevPhase: 0

    // Turn-signal shared phase (for fade up/down)
    property real turnPhase: 1.0

    // Hide mouse cursor (overlay layer)
    property bool hideCursor: true

    // For lamp self-test on boot
    property bool selfTest: false

    /* =============================
       Over-rev oscillator animation
       ============================= */
    NumberAnimation on overRevPhase {
        from: 0
        to:   2 * Math.PI
        duration: Math.round(1000 / Math.max(0.1, overRevHz))
        loops: Animation.Infinite
        running: overRevEnable && overRevActive
        onRunningChanged: if (!running) overRevPhase = 0
    }

    // Over-rev flash hysteresis
    property bool overRevActive: false
    Connections {
        target: dash
        function onRpmChanged() {
            const rpm = dash.rpm
            if (overRevActive) {
                if (rpm < overRevThreshold - overRevHysteresis) overRevActive = false
            } else {
                if (rpm >= overRevThreshold + overRevHysteresis) overRevActive = true
            }
        }
    }

    /* =========================
       Turn indicator fade phase
       ========================= */
    SequentialAnimation on turnPhase {
        id: turnBlink
        running: dash.leftSignal || dash.rightSignal
        loops: Animation.Infinite
        NumberAnimation { from: 0.25; to: 1.0; duration: 250; easing.type: Easing.InOutSine }
        NumberAnimation { from: 1.0;  to: 0.25; duration: 250; easing.type: Easing.InOutSine }
    }

    /* =========================
       Cursor hider overlay
       ========================= */
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        cursorShape: Qt.BlankCursor
        visible: hideCursor
        z: 10000
    }

    /* =========================
       Stage (scaled coordinate system)
       ========================= */
    Item {
        id: stage
        anchors.centerIn: parent
        width: 2560
        height: 720

        // scale to fit window
        property real uiScale: Math.min(parent.width / width, parent.height / height)

        // IMPORTANT: scale around center, not (0,0)
        transform: Scale {
            xScale: stage.uiScale
            yScale: stage.uiScale
            origin.x: stage.width  / 2
            origin.y: stage.height / 2
        }

        // Global dimmer (based on brightness)
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 1.0 - brightness
            z: 9999
            visible: opacity > 0
        }

        // Over-rev flash overlay (scoped to tach region)
        Rectangle {
            id: overRevFlash
            x: 800; y: 40; width: 947; height: 160
            color: "#ff0000"
            opacity: (overRevEnable && overRevActive)
                     ? (overRevIntensity * (0.5 + 0.5 * Math.sin(overRevPhase)))
                     : 0
            z: 9998
            visible: opacity > 0
        }

        /* ===== Assets & fonts ===== */
        Image { anchors.fill: parent; source: "qrc:/KeyDash_NX1000/assets/DashBlank.png"; fillMode: Image.Stretch }
        Loader { active: true; sourceComponent: Component { Image { source: "qrc:/KeyDash_NX1000/assets/Tachometer_Full.png"; cache: true; visible: false } } }
        FontLoader { id: neu;        source: "qrc:/KeyDash_NX1000/fonts/NeuropolX_Lite.ttf" }
        FontLoader { id: neu_italic; source: "qrc:/KeyDash_NX1000/fonts/NeuropolX_Italic.ttf" }

        // Lamp self-test timer duration
        Timer {
            id: selfTestTimer
            interval: 1000
            repeat: false
            running: false
            onTriggered: root.selfTest = false
        }

        /* ===========================================================
           Reusable components (RightNum / HoldButton / Lamp)
           =========================================================== */

        // Right-anchored big number (boost/coolant/iat/vbat/afr)
        component RightNum: Text {
            property real value: 0
            property int  decimals: 0
            property int  rightX: 0
            property int  yPos: 0
            property int  px: 100
            property int  dx: 0
            property int  dy: 0
            property color col: "#7ee6ff"
            // warn/error thresholds (optional)
            property real warnLow:  NaN
            property real warnHigh: NaN
            property color warnColor:  "#ff6200"
            property real errorLow:  NaN
            property real errorHigh: NaN
            property color errorColor: "#ff4d4d"

            text: (decimals > 0) ? value.toFixed(decimals) : Math.round(value).toString()
            x: (rightX + dx) - implicitWidth
            y: yPos + dy
            color: ((value < warnLow) || (value > warnHigh))
                   ? (((value < errorLow) || (value > errorHigh)) ? errorColor : warnColor)
                   : col
            font.family: neu.name
            font.pixelSize: px
            Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.InOutQuad } }
        }

        // Hold-to-activate rectangular button (used in Service panel)
        component HoldButton: Item {
            id: hb
            width: 160; height: 48
            property string label: "Hold to Reset"
            property int holdMs: 1200
            signal activated()
            property bool pressed: false
            property real fillOpacity: 0.0

            Rectangle {
                id: bg; anchors.fill: parent; radius: 12
                border.width: 2; border.color: "#ffcc00"
                color: (mouse.hovered && !hb.pressed) ? "#ffcc0030" : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
            }
            Rectangle {
                anchors.fill: parent; radius: bg.radius
                color: "#ff4d4d"; opacity: hb.fillOpacity
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }
            Text {
                anchors.centerIn: parent
                text: hb.pressed ? "Keep holding…" : hb.label
                font.family: neu.name; font.pixelSize: 20
                color: hb.fillOpacity > 0.7 ? "black" : "#ffcc00"
                Behavior on color { ColorAnimation { duration: 90 } }
            }
            MouseArea {
                id: mouse; anchors.fill: parent; hoverEnabled: true
                onPressed:  { hb.pressed = true;  hb.fillOpacity = 0; tick.start() }
                onReleased: { hb.pressed = false; tick.stop();       hb.fillOpacity = 0 }
                onCanceled: { hb.pressed = false; tick.stop();       hb.fillOpacity = 0 }
            }
            Timer {
                id: tick; interval: 16; repeat: true
                property int elapsed: 0
                onTriggered: {
                    elapsed += interval
                    hb.fillOpacity = Math.min(1, elapsed / hb.holdMs)
                    if (elapsed >= hb.holdMs) {
                        stop(); elapsed = 0; hb.pressed = false
                        hb.activated(); hb.fillOpacity = 0
                    }
                }
                onRunningChanged: if (!running) elapsed = 0
            }
        }

        // Generic lamp with optional blink (not used for turn signals)
        component Lamp: Item {
            property bool on: false
            property bool blink: false
            property real blinkHz: 2.0
            property alias source: img.source
            width: 64; height: 64

            Image { id: img; anchors.fill: parent; source: ""; fillMode: Image.PreserveAspectFit; smooth: true }

            visible: on || blinkAnim2.running
            opacity: blink && on ? img.opacity : (on ? 1 : 0)

            property int periodMs: Math.max(60, Math.round(1000 / Math.max(0.1, blinkHz)))
            SequentialAnimation {
                id: blinkAnim2
                running: blink && on
                loops: Animation.Infinite
                NumberAnimation { target: img; property: "opacity"; from: 0.25; to: 1.0; duration: periodMs/2; easing.type: Easing.InOutSine }
                NumberAnimation { target: img; property: "opacity"; from: 1.0;  to: 0.25; duration: periodMs/2; easing.type: Easing.InOutSine }
                onRunningChanged: if (!running) img.opacity = on ? 1 : 0
            }
        }

        /* ===============================
           Left column numeric gauges
           =============================== */
        Item {
            id: leftCol
            x: -275
            y: 15
            property int rightEdge: 820
            property int startY: 36
            property int rowGap: 124
            property int px: 100

            RightNum { id: boost;
                rightX: leftCol.rightEdge; yPos: leftCol.startY + 0*leftCol.rowGap;
                value: dash.boost; decimals: 1; px: leftCol.px }

            RightNum { id: coolant;
                rightX: leftCol.rightEdge; yPos: leftCol.startY + 1*leftCol.rowGap;
                value: dash.clt; decimals: 0; px: leftCol.px; dy: -1; errorHigh: 100 }

            RightNum { id: iat;
                rightX: leftCol.rightEdge; yPos: leftCol.startY + 2*leftCol.rowGap;
                value: dash.iat; decimals: 0; px: leftCol.px; errorHigh: 50 }

            RightNum { id: voltage;
                rightX: leftCol.rightEdge; yPos: leftCol.startY + 3*leftCol.rowGap;
                value: dash.vbat; decimals: 1; px: leftCol.px; dy: 10; errorLow: 14.0; errorHigh: 16.0 }

            RightNum { id: afr;
                rightX: leftCol.rightEdge; yPos: leftCol.startY + 4*leftCol.rowGap;
                value: dash.afr; decimals: 1; px: leftCol.px; dy: 30;
                warnLow: 11.5; warnHigh: 15.1; errorLow: 11.0; errorHigh: 16.0 }
        }

        /* ===============================
           0–60 timing logic + toast
           =============================== */
        Item {
            // logic only
            Connections {
                target: dash
                function onSpeedChanged() {
                    const s = dash.useMph ? dash.speed : dash.speed * 1.60934
                    const target = dash.useMph ? 60.0 : 100.0
                    const startThresh = dash.useMph
                        ? root.z60StartThresholdMph
                        : root.z60StartThresholdMph * 1.60934

                    if (!root.z60Timing) {
                        if (s <= startThresh) root.z60Armed = true
                        if (root.z60Armed && s > startThresh) {
                            root.z60Timing = true
                            root.z60T0ms = Date.now()
                        }
                    } else {
                        if (s >= target) {
                            const t = (Date.now() - root.z60T0ms) / 1000.0
                            root.z60Time   = t
                            root.z60Timing = false
                            root.z60Armed  = false

                            if (root.z60Enable && t < 10.0) {
                                const isNew = (root.z60Best === 0 || t < root.z60Best)
                                if (isNew) root.z60Best = t
                                root.z60IsNewBest = isNew
                                root.z60Popup = true
                                z60Dismiss.stop(); z60Dismiss.start()
                            }
                        } else if (s <= startThresh) {
                            // aborted → re-arm
                            root.z60Timing = false
                            root.z60Armed  = true
                        }
                    }
                }
            }

            // toast auto-dismiss
            Timer {
                id: z60Dismiss
                interval: Math.round(root.z60ShowSecs * 1000)
                onTriggered: { root.z60Popup = false; root.z60IsNewBest = false }
            }
        }

        // 0–60 (0–100 km/h) result toast
        Rectangle {
            id: z60Toast
            x: 835; y: 300
            width: content.implicitWidth + 40
            height: content.implicitHeight + 20
            radius: 12
            color: "#101820cc"
            border.color: "#ffcc00"; border.width: 2
            z: 9500

            opacity: root.z60Popup ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            // subtle pop
            transform: Scale { id: z60Scale; origin.x: width/2; origin.y: height/2; xScale: 1; yScale: 1 }
            Connections {
                target: root
                function onZ60PopupChanged() {
                    if (root.z60Popup) {
                        z60Scale.xScale = z60Scale.yScale = 1.18
                        Qt.callLater(() => popAnim.start())
                    }
                }
            }
            NumberAnimation {
                id: popAnim
                target: z60Scale; property: "xScale"; to: 1.0; duration: 140; easing.type: Easing.OutCubic
                onRunningChanged: if (running) z60Scale.yScale = z60Scale.xScale
            }

            Column {
                id: content
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: dash.useMph ? "0–60 mph" : "0–100 km/h"
                    color: "#ffcc00"; font.family: neu.name; font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: root.z60Time.toFixed(2) + " s"
                    color: "#7ee6ff"; font.family: neu.name; font.pixelSize: 48
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "NEW BEST!"
                    visible: root.z60IsNewBest && root.z60Popup
                    color: "#ffcc00"; font.family: neu.name; font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Best: " + (root.z60Best > 0 ? root.z60Best.toFixed(2) + " s" : "—")
                    color: "#7ee6ff"; font.family: neu.name; font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: { root.z60Popup = false; root.z60IsNewBest = false }
            }
        }

        /* ===============================
           Centered SPEED block
           =============================== */
        Item {
            id: speedBox
            x: 925; y: 265; width: 720; height: 380

            // size knobs
            property int fontPx: 240
            property int mphPx:  64
            property int gap:    10

            // main speed number
            Text {
                id: speedText
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                text: Math.round(dash.useMph ? dash.speed : dash.speed * 1.60934)
                color: "#7ee6ff"
                font.family: neu.name                 // common family
                font.italic: neu_italic.status === FontLoader.Ready
                font.pixelSize: speedBox.fontPx
                style: Text.Outline
                styleColor: "#00000099"

                // for bump sizing
                property real lastSpeed: dash.speed

                // scale transform (bump effect)
                transform: Scale { id: speedScale; origin.x: speedText.width/2; origin.y: 0; xScale: 1; yScale: 1 }
            }

            // bump when above 60/100 and speed changes
            Connections {
                target: dash
                function onSpeedChanged() {
                    const shown = root.useMph ? dash.speed : (dash.speed * 1.60934)
                    const limit = root.useMph ? 60 : 100
                    if (shown < limit) return

                    const delta = Math.abs(dash.speed - speedText.lastSpeed)
                    const bump  = Math.min(0.10, 0.04 + delta * 0.002)
                    speedText.lastSpeed = dash.speed

                    speedBump.stop()
                    speedBump.from = 1.0
                    speedBump.to   = 1.0 + bump
                    speedBump.start()
                }
            }
            SequentialAnimation {
                id: speedBump
                property real from: 1.0
                property real to:   1.06
                NumberAnimation { target: speedScale; property: "xScale"; duration: 80;  from: speedBump.from; to: speedBump.to; easing.type: Easing.OutCubic }
                NumberAnimation { target: speedScale; property: "xScale"; duration: 120; from: speedBump.to;   to: 1.0;         easing.type: Easing.InCubic }
                onRunningChanged: if (running) speedScale.yScale = speedScale.xScale
            }

            // mph / km/h label
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: speedText.bottom
                anchors.topMargin: speedBox.gap
                text: dash.useMph ? "mph" : "km/h"
                color: "#ffcc00"
                font.family: neu.name
                font.pixelSize: speedBox.mphPx
            }
        }

        /* ===============================
           Tach yellow box (rpm > ~50)
           =============================== */
        Rectangle {
            id: rpmYellowBox
            x: 817; y: 61; width: 18; height: 74
            color: "#ffcc00"
            radius: 0
            visible: dash.rpm > 50
            opacity: visible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }
            z: 50
        }

        /* ===============================
           Tach bar (sweep + live follow)
           =============================== */
        Item {
            id: rpmBar
            x: tachBarX; y: tachBarY
            width: 907; height: 121

            // Map ECU rpm -> [0..1] across the image width with a short first segment (500 rpm),
            // then equal 1000-rpm segments afterwards.
            property real measuredFrac: {
                const r = Math.max(rpmMin, Math.min(rpmMax, dash.rpm))

                // number of 1000-rpm blocks after the first short 500-rpm block
                const blocksAfter = Math.floor((rpmMax - 1000) / 1000)    // e.g. 8000 -> 7
                const totalBlocks = 1 + blocksAfter                       // first short + the rest

                if (r <= 1000) {
                    // 500..1000 spans exactly one "block" of width
                    const span = 1000 - rpmMin;                           // 500
                    return ((r - rpmMin) / span) / totalBlocks;
                } else {
                    // 1000..rpmMax spans 'blocksAfter' equal-width blocks
                    const span = rpmMax - 1000;                           // e.g. 7000
                    return (1 + (r - 1000) / span * blocksAfter) / totalBlocks;
                }
            }
            // what we draw
            property real displayFrac: 0
            // True while intro sweep is running (disables live binding)
            property bool sweeping: true

            // Follow live when NOT sweeping
            Binding { target: rpmBar; property: "displayFrac"; value: rpmBar.measuredFrac; when: !rpmBar.sweeping }

            // smooth updates
            Behavior on displayFrac { NumberAnimation { duration: 120 } }

            // helper: start intro sweep 0 → 1 → 0
            function startSweep() {
                rpmBar.sweeping = true
                rpmBar.displayFrac = 0
                sweepAnim.stop()
                sweepAnim.start()
            }

            // 0 → 1 → 0, then release to live
            SequentialAnimation {
                id: sweepAnim
                ScriptAction { script: rpmBar.sweeping = true }
                PropertyAction { target: rpmBar; property: "displayFrac"; value: 0 }
                NumberAnimation { target: rpmBar; property: "displayFrac"; to: 1; duration: 500; easing.type: Easing.OutCubic }
                NumberAnimation { target: rpmBar; property: "displayFrac"; to: 0; duration: 400; easing.type: Easing.InCubic }
                ScriptAction { script: rpmBar.sweeping = false }   // Binding reattaches
            }

            // clipping window revealing full tach image
            Item {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Math.round(parent.width * rpmBar.displayFrac)
                clip: true

                Image {
                    x: 16; y: 0
                    width: rpmBar.width
                    height: rpmBar.height
                    source: "qrc:/KeyDash_NX1000/assets/Tachometer_Full.png"
                    fillMode: Image.Stretch
                    smooth: true
                }
            }
        }

        /* ===============================
           Gear block (center)
           =============================== */
        Item {
            id: gearBox
            x: 1552; y: 500; width: 160; height: 140; z: 20

            Text {
                id: gearText
                anchors.centerIn: parent
                text: (dash.gear <= 0 ? "N" : dash.gear)
                color: "#7ee6ff"
                font.family: neu.name
                font.pixelSize: 96
                transform: Scale { id: gearScale; origin.x: gearText.width/2; origin.y: gearText.height/2; xScale: 1; yScale: 1 }
                Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
            }
            Connections {
                target: dash
                function onGearChanged() {
                    gearPulseAnim.start()
                    gearText.color = "#ffcc00"
                    Qt.callLater(() => gearText.color = "#7ee6ff")
                }
            }
            SequentialAnimation {
                id: gearPulseAnim
                NumberAnimation { target: gearScale; property: "xScale"; to: 1.18; duration: 90;  easing.type: Easing.OutQuad }
                NumberAnimation { target: gearScale; property: "xScale"; to: 1.00; duration: 120; easing.type: Easing.InQuad }
                onRunningChanged: if (running) gearScale.yScale = gearScale.xScale
            }
        }

        /* ===============================
           SHIFT icon (image)
           =============================== */
        Item {
            id: shiftBox
            x: 1150; y: 215; width: 260; height: 77; z: 30

            // behavior knobs
            property int  showThreshold: 4000
            property int  blinkThreshold: 6000
            property int  hysteresis: 100
            property bool blink: true
            property real blinkHz: 2.0
            property string src: "qrc:/KeyDash_NX1000/assets/ShiftIcon.png"

            // nudging with arrows (focus first)
            focus: true
            Keys.onPressed: (e) => {
                const step = (e.modifiers & Qt.ShiftModifier) ? 10 : 1
                if (e.key === Qt.Key_Left)  { x -= step; e.accepted = true }
                if (e.key === Qt.Key_Right) { x += step; e.accepted = true }
                if (e.key === Qt.Key_Up)    { y -= step; e.accepted = true }
                if (e.key === Qt.Key_Down)  { y += step; e.accepted = true }
            }

            // blink state with hysteresis
            property bool blinkActive: false
            Connections {
                target: dash
                function onRpmChanged() {
                    const rpm = dash.rpm
                    if (shiftBox.blinkActive) {
                        if (rpm < shiftBox.blinkThreshold - shiftBox.hysteresis) shiftBox.blinkActive = false
                    } else {
                        if (rpm >= shiftBox.blinkThreshold + shiftBox.hysteresis) shiftBox.blinkActive = true
                    }
                    if (!blinkAnim.running) shiftImg.opacity = (rpm >= shiftBox.showThreshold ? 1 : 0)
                }
            }

            Image {
                id: shiftImg
                anchors.fill: parent
                source: shiftBox.src
                visible: (dash.rpm >= shiftBox.showThreshold) || blinkAnim.running
                opacity: (dash.rpm >= shiftBox.showThreshold ? 1 : 0)
                smooth: true
            }

            property int periodMs: Math.max(60, Math.round(1000 / Math.max(0.1, blinkHz)))
            SequentialAnimation {
                id: blinkAnim
                running: shiftBox.blink && shiftBox.blinkActive
                loops: Animation.Infinite
                NumberAnimation { target: shiftImg; property: "opacity"; from: 0.25; to: 1.0; duration: shiftBox.periodMs/2; easing.type: Easing.InOutSine }
                NumberAnimation { target: shiftImg; property: "opacity"; from: 1.0;  to: 0.25; duration: shiftBox.periodMs/2; easing.type: Easing.InOutSine }
                onRunningChanged: if (!running) shiftImg.opacity = (dash.rpm >= shiftBox.showThreshold ? 1 : 0)
            }
        }

        /* ===============================
           Date / Odo / Trip
           =============================== */
        Item {
            id: dateBox; x: 1940; y: 90; width: 420; height: 60
            Text {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                textFormat: Text.PlainText
                wrapMode: Text.NoWrap
                text: dash.dateTimeString
                color: "#ffcc00"; font.family: neu.name; font.pixelSize: 65
            }
        }
        Item {
            id: odoBox; x: 1985; y: 320; width: 300; height: 60
            Text {
                anchors.centerIn: parent
                text: Math.round(dash.useMph ? dash.odo : dash.odo * 1.60934) + (dash.useMph ? " mi." : " km")
                color: "#7ee6ff"; font.family: neu.name; font.pixelSize: 50
            }
        }
        Item {
            id: tripBox; x: 1995; y: 470; width: 300; height: 60
            Text {
                anchors.centerIn: parent
                text: (dash.useMph ? dash.trip : dash.trip * 1.60934).toFixed(1) + (dash.useMph ? " mi." : " km")
                color: "#7ee6ff"; font.family: neu.name; font.pixelSize: 50
            }
        }

        /* ===============================
           Turn Signals + Status Lamps
           =============================== */
        // Left turn with gentle “thump”
        Item {
            id: leftTurn
            x: 1793; y: 592; width: 81; height: 68
            visible: ((dash.leftSignal || root.selfTest) ? root.turnPhase : 0) > 0
            opacity: (dash.leftSignal || root.selfTest) ? root.turnPhase : 0
            transformOrigin: Item.Center
            scale: 1
            Image { anchors.fill: parent; source: "qrc:/KeyDash_NX1000/assets/LeftTurnSignal_On.png"; smooth: true }
            Connections {
                target: leftTurn
                function onVisibleChanged() {
                    if (leftTurn.visible) {
                        thumpAnimL.stop()
                        leftTurn.scale = 1.25
                        thumpAnimL.start()
                    } else leftTurn.scale = 1
                }
            }
            NumberAnimation { id: thumpAnimL; target: leftTurn; property: "scale"; to: 1.0; duration: 140; easing.type: Easing.OutCubic }
        }

        // Right turn with gentle “thump”
        Item {
            id: rightTurn
            x: 2393; y: 592; width: 81; height: 69
            visible: ((dash.rightSignal || root.selfTest) ? root.turnPhase : 0) > 0
            opacity: (dash.rightSignal || root.selfTest) ? root.turnPhase : 0
            transformOrigin: Item.Center
            scale: 1
            Image { anchors.fill: parent; source: "qrc:/KeyDash_NX1000/assets/RightTurnSignal_On.png"; smooth: true }
            Connections {
                target: rightTurn
                function onVisibleChanged() {
                    if (rightTurn.visible) {
                        thumpAnimR.stop()
                        rightTurn.scale = 1.25
                        thumpAnimR.start()
                    } else rightTurn.scale = 1
                }
            }
            NumberAnimation { id: thumpAnimR; target: rightTurn; property: "scale"; to: 1.0; duration: 140; easing.type: Easing.OutCubic }
        }

        // TCS / CEL / Headlights
        Lamp { id: tcsLamp;  x: 1998; y: 587; width: 53; height: 60;  source: "qrc:/KeyDash_NX1000/assets/TractionControl_On.png"; on: dash.tcsOn  || root.selfTest }
        Lamp { id: celLamp;  x: 2088; y: 583; width: 96; height: 64;  source: "qrc:/KeyDash_NX1000/assets/CEL_On.png";             on: dash.celOn  || root.selfTest }
        Lamp { id: headLamp; x: 2208; y: 585; width: 96; height: 62;  source: "qrc:/KeyDash_NX1000/assets/Headlight_On.png";       on: dash.headlightsOn || root.selfTest }

        /* ===============================
           Coolant warning toast
           =============================== */
        Connections {
            target: dash
            function onCltChanged() {
                if (dash.clt >= 105 && !root.cltWarn) { root.cltWarn = true; Qt.callLater(()=>warnHide.start()) }
            }
        }
        Timer { id: warnHide; interval: 3000; onTriggered: root.cltWarn = false }
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 90; width: 420; height: 56; radius: 12
            color: "#cc3333"
            opacity: root.cltWarn ? 1 : 0
            visible: opacity > 0
            z: 9500
            Behavior on opacity { NumberAnimation { duration: 180 } }
            Text {
                anchors.centerIn: parent
                text: "Coolant High: " + Math.round(dash.clt) + "°"
                color: "white"; font.family: neu.name; font.pixelSize: 22
            }
        }

        /* ===============================
           Settings persistence
           =============================== */
        Settings {
            id: prefs
            // globals
            property alias brightness: root.brightness
            property alias useMph:     root.useMph
            // positions / layout
            property alias leftColX:       leftCol.x
            property alias leftColY:       leftCol.y
            property alias leftRightEdge:  leftCol.rightEdge
            property alias speedX:         speedBox.x
            property alias speedY:         speedBox.y
            property alias gearX:          gearBox.x
            property alias gearY:          gearBox.y
            property alias tachX:          root.tachBarX
            property alias tachY:          root.tachBarY
            property alias rpmMax:         root.rpmMax
            property alias shiftShow:      shiftBox.showThreshold
            property alias shiftBlink:     shiftBox.blinkThreshold
            // indicator positions
            property alias leftTurnX:  leftTurn.x
            property alias leftTurnY:  leftTurn.y
            property alias rightTurnX: rightTurn.x
            property alias rightTurnY: rightTurn.y
            property alias tcsX:       tcsLamp.x
            property alias tcsY:       tcsLamp.y
            property alias celX:       celLamp.x
            property alias celY:       celLamp.y
            property alias headX:      headLamp.x
            property alias headY:      headLamp.y
            // misc knobs
            property alias ovEnable:     root.overRevEnable
            property alias ovThreshold:  root.overRevThreshold
            property alias ovHysteresis: root.overRevHysteresis
            property alias ovIntensity:  root.overRevIntensity
            property alias ovHz:         root.overRevHz
            property alias introEnable:  root.introEnable
            property alias introFactor:  root.introFactor
            property alias z60Best:      root.z60Best
            property alias hideCursor:   root.hideCursor
        }

        // --- wire DashModel defaults at startup ---
        Item {
            id: modelInit

            Component.onCompleted: {
                // If you did NOT call dash.loadVehicleConfig() in C++:
                // dash.loadVehicleConfig()

                // Mirror prefs -> model on first load
                dash.setUseMph(prefs.useMph)
                dash.setRpmMax(prefs.rpmMax)

                // If you don't have an INI yet, set your drivetrain here:
                dash.setFinalDrive(4.080)
                dash.setGearRatio(1, 3.321)
                dash.setGearRatio(2, 1.902)
                dash.setGearRatio(3, 1.308)
                dash.setGearRatio(4, 1.000)
                dash.setGearRatio(5, 0.891)
            }

            // Keep model in sync if the user changes prefs later
            Connections {
                target: prefs
                function onUseMphChanged() { dash.setUseMph(prefs.useMph) }
                function onRpmMaxChanged() { dash.setRpmMax(prefs.rpmMax) }
            }

            // Keep prefs updated if the model changes units elsewhere (e.g., C++)
            Connections {
                target: dash
                function onUseMphChanged() {
                    if (prefs.useMph !== dash.useMph)
                        prefs.useMph = dash.useMph
                }
            }
        }

        /* ===============================
           Service panel (toggle with “S”)
           =============================== */
        property bool serviceOpen: false
        Shortcut { sequence: "S"; context: Qt.ApplicationShortcut; onActivated: serviceOpen = !serviceOpen }

        Item {
          id: servicePanel
          x: 2320; y: 110
          width: 380; height: parent.height
          z: 9000
          visible: stage.serviceOpen || opacity > 0.01
          enabled: stage.serviceOpen
          clip: true

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                Text { text: "Service Panel"; font.family: neu.name; font.pixelSize: 26; color: "#ffcc00" }

                // Units
                Row {
                    spacing: 12
                    Text { text: "Units:"; color: "white"; font.family: neu.name; font.pixelSize: 18; verticalAlignment: Text.AlignVCenter }
                    Switch {
                        id: units
                        checked: prefs.useMph
                        onToggled: {
                            prefs.useMph = checked
                            dash.setUseMph(checked)
                        }
                    }
                    Text {
                        text: units.checked ? "mph" : "km/h"
                        color: "white"; font.family: neu.name; font.pixelSize: 14
                        anchors.verticalCenter: units.verticalCenter
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                }

                // Over-rev enable
                Row {
                    spacing: 12
                    Text { text: "Rev flash"; color: "white"; font.family: neu.name; font.pixelSize: 18 }
                    Switch { id: ovSwitch; checked: prefs.ovEnable; onToggled: prefs.ovEnable = checked }
                }

                // Intro toggle
                Row {
                    spacing: 12
                    Text { text: "Intro on boot"; color: "white"; font.family: neu.name; font.pixelSize: 18 }
                    Switch { checked: prefs.introEnable; onToggled: prefs.introEnable = checked }
                }

                // Brightness
                Text { text: "Brightness: " + Math.round(root.brightness * 100); color: "white"; font.family: neu.name; font.pixelSize: 18 }
                Slider { from: 0.05; to: 1; value: root.brightness; stepSize: 0.05; onValueChanged: root.brightness = value }

                // Shift thresholds
                Text { text: "Shift Light: " + shiftBox.showThreshold; color: "white"; font.family: neu.name; font.pixelSize: 18 }
                Slider { from: 2000; to: rpmMax; stepSize: 100; value: shiftBox.showThreshold; onValueChanged: shiftBox.showThreshold = Math.round(value) }
                Text { text: "Shift Blink: " + shiftBox.blinkThreshold; color: "white"; font.family: neu.name; font.pixelSize: 18 }
                Slider { from: 2000; to: rpmMax; stepSize: 100; value: shiftBox.blinkThreshold; onValueChanged: shiftBox.blinkThreshold = Math.round(value) }

                // Over-rev threshold
                Text { text: "Over Rev Flash: " + overRevThreshold; color: "white"; font.family: neu.name; font.pixelSize: 16 }
                Slider { from: 4000; to: rpmMax; stepSize: 100; value: overRevThreshold; onValueChanged: overRevThreshold = Math.round(value) }

                // Intro length
                Text { text: "Intro length: " + prefs.introFactor.toFixed(1) + "s"; color: "white"; font.family: neu.name; font.pixelSize: 18 }
                Slider {
                    id: introLen
                    from: 3.0; to: 8.0; stepSize: 1.0
                    value: prefs.introFactor
                    width: 160
                    onValueChanged: prefs.introFactor = Math.round(value * 10) / 10
                }

                // Trip reset
                HoldButton { label: "Reset Trip"; holdMs: 1200; onActivated: dash.resetTrip() }

                // Slide-in/out
                states: [
                    State { name: "panelOpen";   when: stage.serviceOpen;  PropertyChanges { target: servicePanel; x: 2330;       opacity: 1 } },
                    State { name: "panelClosed"; when: !stage.serviceOpen; PropertyChanges { target: servicePanel; x: 2330 + 300; opacity: 0 } }
                ]
                transitions: [ Transition { NumberAnimation { properties: "x,opacity"; duration: 300; easing.type: Easing.OutCubic } } ]
            }
        }

        /* ===============================
           ECU connection banner
           =============================== */
        Rectangle {
            id: statusBar
            anchors.top: parent.top
            width: parent.width; height: 28
            color: dash.connected ? "#0b2a0b" : "#2a0b0b"
            opacity: dash.connected ? 0 : 0.9
            visible: opacity > 0
            Text { anchors.centerIn: parent; text: dash.connected ? "" : "ECU DISCONNECTED"; color: "#ffcc00"; font.family: neu.name; font.pixelSize: 20 }
        }

        /* ===============================
           Settings hot area (dev)
           =============================== */
        Rectangle {
            id: settingsHotspot
            x: 1130; y: 635; width: 300; height: 80; radius: 12
            z: 10001
            color: "#ffcc00"; opacity: 0
            border.color: "#ffcc00"; border.width: 1
            MouseArea { anchors.fill: parent; hoverEnabled: true; onClicked: stage.serviceOpen = !stage.serviceOpen }
        }

        /* ===============================
           Intro overlay (curtain + title + sweep + reveal)
           =============================== */
        Item {
            id: introOverlay
            anchors.fill: parent
            z: 10002
            visible: true

            // durations scaled by persisted factor
            property real factor: prefs.introFactor

            // curtain
            Rectangle { id: curtain; anchors.fill: parent; color: "black"; opacity: 1 }

            // title
            Text {
                id: introTitle
                text: "KeyDash"
                anchors.horizontalCenter: parent.horizontalCenter
                y: 330
                opacity: 0
                color: "#ffcc00"
                font.family: neu.name                 // common family
                font.italic: neu_italic.status === FontLoader.Ready
                font.pixelSize: 130
                transform: Scale { id: titleScale; origin.x: introTitle.width / 2; origin.y: introTitle.height / 2; xScale: 1; yScale: 1 }
            }

            // utility to set initial UI opacity
            function setGroupOpacity(o) {
                leftCol.opacity = o
                rpmYellowBox.opacity = o
                rpmBar.opacity  = o
                speedBox.opacity= o
                gearBox.opacity = o
                dateBox.opacity = o
                odoBox.opacity  = o
                tripBox.opacity = o
            }

            // If intro disabled, skip everything
            Component.onCompleted: {
                if (prefs.introEnable) {
                    setGroupOpacity(0)
                    introAnim.start()
                } else {
                    setGroupOpacity(1)
                    visible = false
                }
            }

            SequentialAnimation {
                id: introAnim

                // Curtain & title
                ParallelAnimation {
                    NumberAnimation { target: curtain;   property: "opacity"; from: 1;   to: 0;   duration: Math.round(420 * introOverlay.factor); easing.type: Easing.OutCubic }
                    NumberAnimation { target: introTitle; property: "opacity"; from: 0;   to: 1;   duration: Math.round(220 * introOverlay.factor) }
                    NumberAnimation {
                        target: titleScale; property: "xScale"; from: 0.92; to: 1.02
                        duration: Math.round(260 * introOverlay.factor); easing.type: Easing.OutCubic
                        onRunningChanged: if (running) titleScale.yScale = titleScale.xScale
                    }
                }
                NumberAnimation { target: introTitle; property: "opacity"; to: 0; duration: Math.round(200 * introOverlay.factor) }

                // Kick visuals right before reveal
                ScriptAction {
                    script: {
                        // Tach sweep 0→1→0 (live reattaches after)
                        rpmBar.startSweep()

                        // Lamps self-test
                        root.selfTest = true
                        selfTestTimer.stop(); selfTestTimer.start()
                    }
                }

                // Staggered reveal of main UI
                NumberAnimation { target: leftCol;      property: "opacity"; from: 0; to: 1; duration: Math.round(120 * introOverlay.factor); easing.type: Easing.OutCubic }
                ParallelAnimation {
                    NumberAnimation { target: rpmYellowBox; property: "opacity"; from: 0; to: 1; duration: Math.round(120 * introOverlay.factor); easing.type: Easing.OutCubic }
                    NumberAnimation { target: rpmBar;       property: "opacity"; from: 0; to: 1; duration: Math.round(120 * introOverlay.factor); easing.type: Easing.OutCubic }
                }
                NumberAnimation { target: speedBox;    property: "opacity"; from: 0; to: 1; duration: Math.round(160 * introOverlay.factor); easing.type: Easing.OutCubic }
                NumberAnimation { target: gearBox;     property: "opacity"; from: 0; to: 1; duration: Math.round(180 * introOverlay.factor); easing.type: Easing.OutCubic }
                ParallelAnimation {
                    NumberAnimation { target: dateBox;  property: "opacity"; from: 0; to: 1; duration: Math.round(180 * introOverlay.factor); easing.type: Easing.OutCubic }
                    NumberAnimation { target: odoBox;   property: "opacity"; from: 0; to: 1; duration: Math.round(180 * introOverlay.factor); easing.type: Easing.OutCubic }
                    NumberAnimation { target: tripBox;  property: "opacity"; from: 0; to: 1; duration: Math.round(180 * introOverlay.factor); easing.type: Easing.OutCubic }
                }

                // Remove overlay
                ScriptAction { script: introOverlay.visible = false }
            }
        }
    } // stage
}
