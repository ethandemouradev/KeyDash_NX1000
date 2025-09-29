import QtQuick
import QtQuick.Controls
import Qt.labs.settings 1.1
import QtMultimedia
//import KeyDash_NX1000 1.0

Page {
    id: dashPage
    focus: true
    required property var prefs
    property var dashController: dash
    property var theme: null

    property alias stageItem: stage

    // Distance helpers — device reports KM; convert to user units (km/mi)
    function kmToUi(km) {
        const v = Number(km) || 0
        return (prefs && prefs.useMph === true) ? (v * 0.621371) : v
    }
    function distUnitLabel() {
        return (prefs && prefs.useMph === true) ? "mi" : "km"
    }

    function kmToMiles(km) { return Number(km) * 0.621371 }
    function numFmt(n, decimals) { return Number(n).toLocaleString(Qt.locale(), 'f', decimals) }

    signal openService()

    // Persistent global settings
    property bool useMph: true
    property real brightness: 1.0

    // Intro animation controls
    property bool introEnable: true
    property bool skipIntro: true
    property real introFactor: 1.8   // scales intro animation durations

    // Over-rev flash settings
    property bool overRevEnable: true
    property int  overRevThreshold: 6500
    property int  overRevHysteresis: 150
    property real overRevIntensity: 0.35  // 0..1
    property real overRevHz: 3.0          // flashes per second

    // Tachometer placement and scaling
    property int tachBarX: 813
    property int tachBarY: 60
    property int rpmMax:   8000
    property int rpmMin: 450    // 500 rpm = 0%

    // 0–60 timing options
    property bool  z60Enable: true
    property real  z60ShowSecs: 5.0
    property real  z60TargetMph: 60.0
    property real  z60StartThresholdMph: 1.0
    property real  z60Best: 0
    property bool  z60IsNewBest: false

    // 0–60 runtime state (volatile)
    property bool z60Armed:  false
    property bool z60Timing: false
    property real z60T0ms:   0
    property real z60Time:   0
    property bool z60Popup:  false

    // Alert flags
    property bool cltWarn: false

    // Over-rev oscillator phase (smooth flash control)
    property real overRevPhase: 0

    // Turn signal fade phase
    property real turnPhase: 1.0

    // Hide mouse cursor overlay
    property bool hideCursor: false

    // Lamp self-test flag
    property bool selfTest: false

    // Over-rev phase animation
    NumberAnimation on overRevPhase {
        from: 0
        to:   2 * Math.PI
        duration: Math.round(1000 / Math.max(0.1, overRevHz))
        loops: Animation.Infinite
        running: overRevEnable && overRevActive
        onRunningChanged: if (!running) overRevPhase = 0
    }

    // Over-rev flash hysteresis and RPM monitoring
    property bool overRevActive: false
    Connections {
        target: dashController ? dashController : null
        function onRpmChanged() {
            const rpm = dashController.rpm
            if (overRevActive) {
                if (rpm < overRevThreshold - overRevHysteresis) overRevActive = false
            } else {
                if (rpm >= overRevThreshold + overRevHysteresis) overRevActive = true
            }
        }
    }

    // Turn indicator fade animation
    SequentialAnimation on turnPhase {
        id: turnBlink
        running: !!(dashController && (dashController.leftSignal || dashController.rightSignal))
        loops: Animation.Infinite
        NumberAnimation { from: 0.25; to: 1.0; duration: 250; easing.type: Easing.InOutSine }
        NumberAnimation { from: 1.0;  to: 0.25; duration: 250; easing.type: Easing.InOutSine }
    }

    // Cursor-hider overlay
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        cursorShape: Qt.BlankCursor
        visible: hideCursor
        z: 10000
    }

    // Night-time helper: returns true if 'now' falls within configured night window
    function isNight(now = new Date()) {
        function toMins(s) {
            const m = /^(\d{1,2}):(\d{2})$/.exec(s || "")
            if (!m)
                return null
            const h = +m[1], mi = +m[2]
            if (h < 0 || h > 23 || mi < 0 || mi > 59)
                return null
            return h * 60 + mi
        }
        const start = toMins(dashPage.prefs.nightStart)
        const end = toMins(dashPage.prefs.nightEnd)
        if (start === null || end === null)
        return false
        const nowMin = now.getHours() * 60 + now.getMinutes()
        return (start <= end) ? (nowMin >= start
        && nowMin < end) : (nowMin >= start || nowMin < end)
    }

        // Stage: scaled coordinate system
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

        // Global dimmer overlay for night brightness adjustments
        Rectangle {
            anchors.fill: parent
            color: "black"
            property real targetB: isNight() ? (dashPage.prefs.brightnessNight
                                                ?? 0.35) : (dashPage.prefs.brightness ?? 1.0)
            opacity: Math.max(0, Math.min(1, 1.0 - targetB))
            z: 99999
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

        Loader { active: true; sourceComponent: Component { Image { source: "qrc:/KeyDash_Assets/assets/Tachometer_Full.png"; cache: true; visible: false } } }
        FontLoader { id: neu;        source: "qrc:/KeyDash_Assets/fonts/NeuropolX_Lite.ttf" }
        FontLoader { id: neu_italic; source: "qrc:/KeyDash_Assets/fonts/NeuropolX_Italic.ttf" }
        FontLoader { id: brandFont; source: "qrc:/KeyDash_Assets/fonts/NissanOpti.otf" }

        // 1) Gradient background (left→right: start → end → start)
        Canvas {
            id: mainBg
            anchors.fill: parent
            z: 0
            onPaint: {
                const ctx = getContext("2d")
                const w = width, h = height
                const g = ctx.createLinearGradient(0, 0, w, 0) // left→right
                g.addColorStop(0.00, theme.bgStart)
                g.addColorStop(0.40, theme.bgEnd)
                g.addColorStop(0.60, theme.bgEnd)
                g.addColorStop(1.00, theme.bgStart)
                ctx.fillStyle = g
                ctx.fillRect(0, 0, w, h)
            }
            Component.onCompleted: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()

            Connections {
                target: theme
                function onBgStartChanged() { mainBg.requestPaint() }
                function onBgEndChanged()   { mainBg.requestPaint() }
            }
        }

        // Fine-tunable hex watermark + centered gear text
        Canvas {
            id: hexMark
            width: 150
            height: 150
            z: 2
            opacity: 1

            // --- positioning knobs (unchanged) ---
            property alias corner: _pos.corner
            property alias margin: _pos.margin
            property alias dx: _pos.dx
            property alias dy: _pos.dy
            QtObject {
                id: _pos
                property string corner: "bottomRight"
                property int margin: 90
                property int dx: -764
                property int dy: 17
            }
            x: (function() {
                switch (_pos.corner) {
                case "topLeft":
                case "bottomLeft":  return _pos.margin + _pos.dx
                default:            return parent.width - width - _pos.margin + _pos.dx
                }
            })()
            y: (function() {
                switch (_pos.corner) {
                case "topLeft":
                case "topRight":    return _pos.margin + _pos.dy
                default:            return parent.height - height - _pos.margin + _pos.dy
                }
            })()

            // --- drawing knobs ---
            property int  sides: 6
            property real thickness: 10
            property color ringColor: theme.secondaryColor
            property color fillColor: theme.bgStart      // inner fill
            property real rotationDeg: -30

            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                const cx = width * 0.5
                const cy = height * 0.5
                const R  = Math.min(width, height) * 0.46         // outer radius
                const r  = Math.max(0, R - thickness)              // inner radius
                const rot = rotationDeg * Math.PI / 180

                function pathNgon(radius) {
                    ctx.beginPath()
                    for (let i = 0; i < sides; ++i) {
                        const a = rot + i * 2*Math.PI / sides
                        const x = cx + radius * Math.cos(a)
                        const y = cy + radius * Math.sin(a)
                        if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y)
                    }
                    ctx.closePath()
                }

                // 1) draw the outer hex (ring base)
                ctx.fillStyle = ringColor
                pathNgon(R); ctx.fill()

                // 2) fill the inner hex with bgStart, creating a clean ring
                ctx.fillStyle = fillColor
                pathNgon(r); ctx.fill()

                // 3) optional crisp border around the outer hex
                ctx.lineWidth = 1.5
                ctx.strokeStyle = ringColor
                pathNgon(R); ctx.stroke()
            }

            // repaint when theme/size changes
            onRingColorChanged: requestPaint()
            onFillColorChanged: requestPaint()
            onWidthChanged:     requestPaint()
            onHeightChanged:    requestPaint()
            Component.onCompleted: requestPaint()

            Connections {
                target: theme
                function onBgStartChanged() { mainBg.requestPaint() }
                function onSecondaryColorChanged()   { mainBg.requestPaint() }
            }
        }

        // 3) Frame (lines, tach scale, etc.) — tint with secondaryColor, keep PNG alpha
        Canvas {
            id: frameTint
            anchors.fill: parent
            anchors.topMargin: -32
            anchors.bottomMargin: 32
            z: 3

            property string src: "qrc:/KeyDash_Assets/assets/DashFrame.png"
            property color  tint: theme.secondaryColor

            renderTarget: Canvas.FramebufferObject

            Component.onCompleted: loadImage(src)
            onSrcChanged: { loadImage(src); requestPaint() }
            onWidthChanged:  requestPaint()
            onHeightChanged: requestPaint()
            onTintChanged:   requestPaint()

            onPaint: {
                const ctx = getContext("2d")
                const w = width, h = height
                ctx.clearRect(0, 0, w, h)

                if (!isImageLoaded(src)) {      // <- no getImage()
                    requestPaint()              // try again next frame
                    return
                }

                // 1) draw original (with alpha)
                ctx.drawImage(src, 0, 0, w, h)  // <- pass URL

                // 2) colorize only non-transparent pixels
                ctx.globalCompositeOperation = "source-in"
                ctx.fillStyle = tint
                ctx.fillRect(0, 0, w, h)

                ctx.globalCompositeOperation = "source-over"
            }
        }

        // --- remove the baked-in "NISSAN" with a transparent patch ---
        Canvas {
            id: frameBadgePatch
            x: 1144; y: 645; width: 270; height: 70
            z: 4.5   // above the frame (z:3), below our new text

            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                // Nothing else drawn → this area will remain transparent
            }

            Component.onCompleted: requestPaint()
            onWidthChanged:  requestPaint()
            onHeightChanged: requestPaint()
        }

        // --- auto-fit text component (scales to fit its box) ---
        component AutoFitText: Item {
            id: aft
            property string text: ""
            property string family: (brandFont.status === FontLoader.Ready ? brandFont.name : Qt.application.font.family)
            property color  color: "#ffffff"
            property int    minPx: 10
            property int    maxPx: 120
            property int    padding: 4   // inner padding when fitting
            // optional letter spacing (can help with tall text)
            property real   letterSpacing: 0

            // measured text
            Text {
                id: t
                anchors.centerIn: parent
                text: aft.text
                color: aft.color
                font.family: aft.family
                font.pixelSize: aft.maxPx
                font.letterSpacing: aft.letterSpacing
                renderType: Text.NativeRendering
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideNone
            }

            function refit() {
                if (!width || !height || !t.text.length) return
                // Binary search for best pixelSize that fits
                var lo = minPx, hi = maxPx, best = minPx
                for (let i = 0; i < 12; ++i) {
                    const mid = Math.floor((lo + hi) / 2)
                    t.font.pixelSize = mid
                    // Use implicitWidth/implicitHeight for a single-line Text
                    const wOk = (t.implicitWidth  + 2*padding) <= width
                    const hOk = (t.implicitHeight + 2*padding) <= height
                    if (wOk && hOk) { best = mid; lo = mid + 1 } else { hi = mid - 1 }
                }
                t.font.pixelSize = best
            }

            onWidthChanged:  refit()
            onHeightChanged: refit()
            onTextChanged:   refit()
            Component.onCompleted: refit()
        }

        // --- place the auto-fit text on top of the patch ---
        AutoFitText {
            id: brandBadge
            x: frameBadgePatch.x
            y: frameBadgePatch.y
            width: frameBadgePatch.width
            height: frameBadgePatch.height
            z: frameBadgePatch.z + 0.5
            text: prefs.badgeText            // live
            family: brandFont.status === FontLoader.Ready ? brandFont.name : Qt.application.font.family
            color: theme.secondaryColor      // or theme.primaryColor
            minPx: 18
            maxPx: 80
            padding: 6
            letterSpacing: 1
        }

        Image {
            id: tachometerempty;
            anchors.fill: parent
            source: "qrc:/KeyDash_Assets/assets/TachometerEmpty.png"
            fillMode: Image.Stretch
            smooth: true
            z: 3
        }

        // Lamp self-test timer
        Timer {
            id: selfTestTimer
            interval: 1000
            repeat: false
            running: false
            onTriggered: dashPage.selfTest = false
        }


    // Reusable UI components: RightNum, HoldButton, Lamp

    // Right-anchored numeric display (boost, coolant, IAT, voltage, AFR)
        component RightNum: Text {
            property real value: 0
            property int  decimals: 0
            property int  rightX: 0
            property int  yPos: 0
            property int  px: 100
            property int  dx: 0
            property int  dy: 0
            property color col: theme.primaryColor
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

    // Generic lamp component with optional blink
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

        // Display Data
        Item {
            id: leftCol
            x: 0
            y: 15
            z: 100
            opacity: 1

            property real stoichAfr: 14.7
            // ---- lane & columns (edit these) ----
            property int laneLeft:   24
            property int laneRight:  585
            property int rightEdge:  550    // digits' RIGHT edge alignment
            property int unitLeft:   600    // <- adjust
            property int unitRight:  765    // <- adjust
            property int unitCenter: Math.round((unitLeft + unitRight) / 2)
            property int startY:     20
            property int px: 100
            property int unitPx: 100
            // Your original visual grid spacing between thick yellow lines:
            property int bigRowGap: 130
            // Content actually sits on the half-step between those lines:
            property int rowStep: Math.round(bigRowGap / 2)
            // optional icon column (if you add icons)
            property int iconLeft:   54
            property int iconRight:  160
            property int iconCenter: Math.round((iconLeft + iconRight) / 2)

            function metricValue(name) {
                if (!dashController) return NaN
                switch (name) {
                case "Boost": return Number(dashController.boost)
                case "CLT":   return Number(dashController.clt)
                case "IAT":   return Number(dashController.iat)
                case "VBat":  return Number(dashController.vbat)
                case "AFR":   return Number(dashController.afr)
                case "TPS":   return Number(dashController.tps)
                default:      return NaN
                }
            }
            function metricUnit(name) {
                switch (name) {
                case "Boost": return "psi"
                case "CLT":
                case "IAT":   return "°C"
                case "VBat":  return "V"
                case "AFR":   return "AFR"
                case "TPS":   return "%"
                default:      return ""
                }
            }
            function metricIcon(name) {
                switch (name) {
                case "Boost": return "qrc:/KeyDash_Assets/assets/icons/boost.png"
                case "AFR":   return "qrc:/KeyDash_Assets/assets/icons/lambda.png"
                case "TPS":   return "qrc:/KeyDash_Assets/assets/icons/tps.png"
                case "CLT":   return "qrc:/KeyDash_Assets/assets/icons/coolant.png"
                case "IAT":   return "qrc:/KeyDash_Assets/assets/icons/therm.png"
                case "VBat":  return "qrc:/KeyDash_Assets/assets/icons/battery.png"
                default:      return ""
                }
            }
            function metricSpec(name) {
                switch (name) {
                case "Boost": return ({dec:1})
                case "CLT":   return ({dec:0, errorHigh:100})
                case "IAT":   return ({dec:0, errorHigh:50})
                case "VBat":  return ({dec:1, dy:0, errorLow:14.0, errorHigh:16.0})
                case "AFR":   return ({dec:1, dy:0, warnLow:11.5, warnHigh:15.1, errorLow:11.0, errorHigh:16.0})
                case "TPS":   return ({dec:0})
                default:      return ({dec:0})
                }
            }

            // --- tiny helper: PNG tint that preserves alpha ---
            component TintedIcon: Canvas {
                id: tint
                property string src: ""
                property color  tintColor: theme.secondaryColor

                renderTarget: Canvas.FramebufferObject

                Component.onCompleted: if (src) loadImage(src)
                onSrcChanged: { if (src) loadImage(src); requestPaint() }
                onTintColorChanged: requestPaint()
                onWidthChanged:  requestPaint()
                onHeightChanged: requestPaint()

                onPaint: {
                    const ctx = getContext("2d")
                    const w = width, h = height
                    ctx.clearRect(0, 0, w, h)

                    if (!src || !isImageLoaded(src)) {
                        requestPaint() // try again next frame once loaded
                        return
                    }

                    // 1) draw the original (with its alpha)
                    ctx.drawImage(src, 0, 0, w, h)

                    // 2) fill only where the icon is opaque
                    ctx.globalCompositeOperation = "source-in"
                    ctx.fillStyle = tintColor
                    ctx.fillRect(0, 0, w, h)

                    ctx.globalCompositeOperation = "source-over"
                }

                // repaint live when theme changes
                Connections {
                    target: theme
                    function onSecondaryColorChanged() { tint.requestPaint() }
                }
            }

            component MetricRow: Item {
                property int rowIndex: 0
                property var choices: []
                property int px: leftCol.px

                // row midline (between thick bars)
                readonly property int centerY:
                    leftCol.startY + (rowIndex * leftCol.bigRowGap) + leftCol.rowStep

                width: 1; height: 1

                // state
                property int    choiceIndex: 0
                property string metric: (choices.length ? choices[choiceIndex] : "")
                readonly property var  spec: leftCol.metricSpec(metric)
                readonly property real rawValue: leftCol.metricValue(metric)

                // unit modes + selection
                property var unitModes: []   // array of { label, decimals, convert(v) }
                property int unitIndex: 0

                // computed (no bindings → avoids loops)
                property string currentUnitLabel: ""
                property int    currentDecimals: 0
                property real   convertedValue: 0

                function buildUnitModes(name) {
                    const s = leftCol.metricSpec(name) || { dec: 0 }
                    switch (name) {
                    case "AFR":
                        return [
                            { label: "AFR", decimals: 1, convert: function(v){ return v } },
                            { label: "λ",   decimals: 2, convert: function(v){ return (v > 0 ? v / (leftCol.stoichAfr || 14.7) : 0) } }
                        ]
                    case "CLT":
                    case "IAT":
                        return [
                            { label: "°C", decimals: 0, convert: function(v){ return v } },
                            { label: "°F", decimals: 0, convert: function(v){ return (v * 9/5 + 32) } }
                        ]
                    case "Boost":
                        return [
                            { label: "psi", decimals: 1, convert: function(v){ return v } },
                            { label: "kPa", decimals: 0, convert: function(v){ return v * 6.89476 } }
                        ]
                    default:
                        return [
                            { label: leftCol.metricUnit(name), decimals: s.dec, convert: function(v){ return v } }
                        ]
                    }
                }

                function recompute() {
                    if (!unitModes || unitModes.length === 0) {
                        unitModes = buildUnitModes(metric)
                        unitIndex = 0
                    }
                    const mode = unitModes[unitIndex % unitModes.length]
                    currentUnitLabel = mode.label
                    currentDecimals  = (mode.decimals !== undefined ? mode.decimals : (spec && spec.dec) || 0)
                    convertedValue   = mode.convert(Number(rawValue) || 0)
                }

                // initialize + react
                Component.onCompleted: { unitModes = buildUnitModes(metric); unitIndex = 0; recompute() }
                onMetricChanged:       { unitModes = buildUnitModes(metric); unitIndex = 0; recompute() }
                onUnitIndexChanged:    recompute()
                onUnitModesChanged:    recompute()
                onRawValueChanged:     recompute()

                // ICON — centered, tinted with theme.secondaryColor
                TintedIcon {
                    width: 96; height: 96
                    x: leftCol.iconCenter - width/2
                    y: parent.centerY - height/2
                    z: 2
                    src: leftCol.metricIcon(parent.metric)
                }

                // VALUE — centered on midline
                RightNum {
                    id: num
                    rightX: leftCol.rightEdge
                    yPos: parent.centerY - Math.round(implicitHeight / 2)
                    px: px
                    value: parent.convertedValue
                    decimals: parent.currentDecimals
                    dy: parent.spec.dy || 0
                    warnLow:  ("warnLow"  in parent.spec ? parent.spec.warnLow  : NaN)
                    warnHigh: ("warnHigh" in parent.spec ? parent.spec.warnHigh : NaN)
                    errorLow: ("errorLow" in parent.spec ? parent.spec.errorLow : NaN)
                    errorHigh:("errorHigh"in parent.spec ? parent.spec.errorHigh: NaN)
                    z: 10
                }

                // UNIT — centered; click to toggle units (AFR↔λ, °C↔°F, etc.)
                Text {
                    id: unitText
                    text: parent.currentUnitLabel
                    x:  leftCol.unitCenter - Math.round(implicitWidth / 2)
                    y:  parent.centerY - Math.round(implicitHeight / 2)
                    color: theme.secondaryColor
                    font.family: (neu.status === FontLoader.Ready ? neu.name : Qt.application.font.family)
                    font.pixelSize: leftCol.unitPx
                    z: 10
                }
                MouseArea {
                    anchors.fill: unitText
                    onClicked: if (parent.unitModes.length > 1) parent.unitIndex = (parent.unitIndex + 1) % parent.unitModes.length
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                }

                // NEW: click the value (or the whole lane) to cycle metric AFR→CLT→VBat…
                MouseArea {
                    x: leftCol.laneLeft
                    y: parent.centerY - Math.round(leftCol.bigRowGap / 2)
                    width: leftCol.laneRight - leftCol.laneLeft
                    height: leftCol.bigRowGap
                    onClicked: if (parent.choices.length) { parent.choiceIndex = (parent.choiceIndex + 1) % parent.choices.length }
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    // keep under the unit-click area so unit taps still toggle units
                    z: 5
                }
            }

            MetricRow { rowIndex: 0; choices: ["Boost","TPS","AFR"] }
            MetricRow { rowIndex: 1; choices: ["CLT","IAT","TPS"] }
            MetricRow { rowIndex: 2; choices: ["IAT","CLT","TPS"] }
            MetricRow { rowIndex: 3; choices: ["VBat","TPS","AFR"] }
            MetricRow { rowIndex: 4; choices: ["AFR","TPS","Boost"] }
        }

    // 0–60 timing logic and result toast
        Item {
            // logic only
            Connections {
                target: dashController ? dashController : null
                function onSpeedChanged() {
                    if (!dashController) return
                    const s = (prefs.useMph ? dashController.speed : dashController.speed * 1.60934)
                    const target = (prefs.useMph ? 60.0 : 100.0)
                    const startThresh = (prefs.useMph ? dashPage.z60StartThresholdMph
                                                      : dashPage.z60StartThresholdMph * 1.60934)

                    if (!dashPage.z60Timing) {
                        if (s <= startThresh) dashPage.z60Armed = true
                        if (dashPage.z60Armed && s > startThresh) {
                            dashPage.z60Timing = true
                            dashPage.z60T0ms = Date.now()
                        }
                    } else {
                        if (s >= target) {
                            const t = (Date.now() - dashPage.z60T0ms) / 1000.0
                            dashPage.z60Time   = t
                            dashPage.z60Timing = false
                            dashPage.z60Armed  = false

                            if (dashPage.z60Enable && t < 10.0) {
                                const isNew = (dashPage.z60Best === 0 || t < dashPage.z60Best)
                                if (isNew) dashPage.z60Best = t
                                dashPage.z60IsNewBest = isNew
                                dashPage.z60Popup = true
                                z60Dismiss.stop(); z60Dismiss.start()
                            }
                        } else if (s <= startThresh) {
                            // aborted → re-arm
                            dashPage.z60Timing = false
                            dashPage.z60Armed  = true
                        }
                    }
                }
            }

            // Auto-dismiss timer for 0–60 toast
            Timer {
                id: z60Dismiss
                interval: Math.round(dashPage.z60ShowSecs * 1000)
                onTriggered: { dashPage.z60Popup = false; dashPage.z60IsNewBest = false }
            }
        }

    // 0–60 result toast
        Rectangle {
            id: z60Toast
            x: 835; y: 300
            width: content.implicitWidth + 40
            height: content.implicitHeight + 20
            radius: 12
            color: theme.bgStart
            border.color: theme.secondaryColor; border.width: 2
            z: 9500

            opacity: dashPage.z60Popup ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            // subtle pop
            transform: Scale { id: z60Scale; origin.x: width/2; origin.y: height/2; xScale: 1; yScale: 1 }
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
                    text: (prefs.useMph ? "0–60 mph" : "0–100 km/h")
                    color: theme.secondaryColor; font.family: neu.name; font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: dashPage.z60Time.toFixed(2) + " s"
                    color: theme.primaryColor; font.family: neu.name; font.pixelSize: 48
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "NEW BEST!"
                    visible: dashPage.z60IsNewBest && dashPage.z60Popup
                    color: theme.secondaryColor; font.family: neu.name; font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: "Best: " + (dashPage.z60Best > 0 ? dashPage.z60Best.toFixed(2) + " s" : "—")
                    color: theme.primaryColor; font.family: neu.name; font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: { dashPage.z60Popup = false; dashPage.z60IsNewBest = false }
            }
        }

    // Centered speed block
        Item {
            id: speedBox
            x: 925; y: 265; width: 720; height: 380

            // Size properties
            property int fontPx: 240
            property int mphPx:  64
            property int gap:    10

            // Main speed number
            Text {
                id: speedText
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                text: Math.round(
                    prefs.useMph
                        ? (dashController ? (Number(dashController.speed)       || 0) : 0)             // mph direct
                        : (dashController ? (Number(dashController.speed)*1.60934 || 0) : 0)           // km/h
                )
                color: theme.primaryColor
                font.family: neu.name                 // common family
                font.italic: neu_italic.status === FontLoader.Ready
                font.pixelSize: speedBox.fontPx
                style: Text.Outline
                styleColor: "#00000099"

                // Last speed used for bump calculations
                property real lastSpeed: Math.round(dashController ? dashController.speed : 0)

                // Scale transform for bump effect
                transform: Scale { id: speedScale; origin.x: speedText.width/2; origin.y: 0; xScale: 1; yScale: 1 }
            }

            // Speed bump effect when above configured limit
            Connections {
                target: dashController ? dashController : null
                function onSpeedChanged() {
                    if (!dashController) return
                    const shown = dashController.useMph ? dashController.speed : (dashController.speed * 1.60934)
                    const limit = dashController.useMph ? 60 : 100
                    if (shown < limit) return

                    const delta = Math.abs(dashController.speed - speedText.lastSpeed)
                    const bump  = Math.min(0.10, 0.04 + delta * 0.002)
                    speedText.lastSpeed = dashController.speed

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

            // Unit label (mph / km/h)
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: speedText.bottom
                anchors.topMargin: speedBox.gap
                text: (prefs.useMph ? "mph" : "km/h")
                color: theme.secondaryColor
                font.family: neu.name
                font.pixelSize: speedBox.mphPx
            }

            // Tap the big speed number
            MouseArea {
                anchors.fill: speedText
                onClicked: {
                    prefs.useMph = !prefs.useMph
                    if (dashController && dashController.setUseMph) dashController.setUseMph(prefs.useMph)
                }
                hoverEnabled: false
                acceptedButtons: Qt.LeftButton
            }

            // Tap the unit label
            MouseArea {
                anchors.fill: parent // or anchors.fill: previous unit Text if you prefer
                anchors.top: speedText.bottom
                anchors.bottom: parent.bottom
                onClicked: {
                    prefs.useMph = !prefs.useMph
                    if (dashController && dashController.setUseMph) dashController.setUseMph(prefs.useMph)
                }
                hoverEnabled: false
                acceptedButtons: Qt.LeftButton
            }
        }

    // Tach highlight box (visible above idle)
        Rectangle {
            id: rpmYellowBox
            x: 817; y: 61; width: 18; height: 74
            color: theme.secondaryColor
            radius: 0
            visible: !!(dashController && (dashController.rpm > 50))
            opacity: visible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }
            z: 50
        }

    // Tach bar (intro sweep + live follow)
        Item {
            id: rpmBar
            x: tachBarX; y: tachBarY
            width: 907; height: 121
            z: tachometerempty.z + 1

                // Map ECU RPM to fraction [0..1] across image width; idle-to-1k has a shorter span, then uniform 1k segments.
            property real measuredFrac: {
                const raw = dashController ? (dashController.rpm || 0) : 0
                if (raw <= rpmMin) return 0         // <-- force 0 at idle/off

                const r = Math.min(rpmMax, raw)
                const blocksAfter = Math.max(0, Math.floor((rpmMax - 1000) / 1000))
                const totalBlocks = 1 + blocksAfter

                if (r <= 1000) {
                    const span = Math.max(1, 1000 - rpmMin) // e.g. 500
                    return ((r - rpmMin) / span) / totalBlocks
                } else {
                    const span = Math.max(1, rpmMax - 1000) // e.g. 7000
                    return (1 + (r - 1000) / span * blocksAfter) / totalBlocks
                }
            }

            // Display fraction used for clipping the tach image
            property real displayFrac: 0
            // Sweeping flag disables live binding during intro
            property bool sweeping: true

            // Live binding for display fraction when not sweeping
            Binding { target: rpmBar; property: "displayFrac"; value: rpmBar.measuredFrac; when: !rpmBar.sweeping }

            // Smooth display updates
            Behavior on displayFrac { NumberAnimation { duration: 120 } }

            // Start intro sweep (0 → 1 → 0)
            function startSweep() {
                if (dashPage.skipIntro || !prefs.introEnable) {
                    rpmBar.sweeping = false
                    return
                }
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

            // Clipping window that reveals the tach image based on displayFrac
            Item {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Math.round(rpmBar.width * rpmBar.displayFrac)  // clip width only
                clip: true

                // Draw at full size, let the parent clip reveal it
                Item {
                    x: 16                    // keep your original x offset
                    y: 0
                    width: rpmBar.width
                    height: rpmBar.height

                    Canvas {
                        id: tachTint
                        anchors.fill: parent
                        renderTarget: Canvas.FramebufferObject

                        property string src: "qrc:/KeyDash_Assets/assets/Tachometer_Full.png"
                        property color  startColor: theme.secondaryColor
                        property color  endColor:   "#ff0000"

                        Component.onCompleted: loadImage(src)
                        onSrcChanged: { loadImage(src); requestPaint() }
                        onWidthChanged:  requestPaint()
                        onHeightChanged: requestPaint()
                        onStartColorChanged: requestPaint()
                        onEndColorChanged:   requestPaint()

                        Connections {
                            target: theme
                            function onSecondaryColorChanged() { tachTint.requestPaint() }
                        }

                        onPaint: {
                            const ctx = getContext("2d")
                            const w = width, h = height
                            ctx.clearRect(0, 0, w, h)

                            if (!isImageLoaded(src)) { requestPaint(); return }

                            // Draw full-size image (no stretch with the clip)
                            ctx.drawImage(src, 0, 0, w, h)

                            // Gradient tint while preserving alpha
                            ctx.globalCompositeOperation = "source-in"
                            const g = ctx.createLinearGradient(0, 0, w, 0)
                            g.addColorStop(0.0, startColor)
                            g.addColorStop(1.0, endColor)
                            ctx.fillStyle = g
                            ctx.fillRect(0, 0, w, h)
                            ctx.globalCompositeOperation = "source-over"
                        }
                    }
                }
            }
        }

    // Gear block (center)
        Item {
            id: gearBox
            x: 1552; y: 500; width: 160; height: 140; z: hexMark.z + 1

            Text {
                id: gearText
                anchors.centerIn: parent
                text: (!dashController || dashController.gear <= 0 ? "N" : dashController.gear)
                color: theme.primaryColor
                font.family: neu.name
                font.pixelSize: 96
                transform: Scale { id: gearScale; origin.x: gearText.width/2; origin.y: gearText.height/2; xScale: 1; yScale: 1 }
                Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
            }
            Connections {
                target: dashController ? dashController : null
                function onGearChanged() {
                    if (!dashController) return
                    gearPulseAnim.start()
                    gearText.color = theme.secondaryColor
                    Qt.callLater(() => gearText.color = theme.primaryColor)
                }
            }
            SequentialAnimation {
                id: gearPulseAnim
                NumberAnimation { target: gearScale; property: "xScale"; to: 1.18; duration: 90;  easing.type: Easing.OutQuad }
                NumberAnimation { target: gearScale; property: "xScale"; to: 1.00; duration: 120; easing.type: Easing.InQuad }
                onRunningChanged: if (running) gearScale.yScale = gearScale.xScale
            }
        }

    // SHIFT icon (image)
        Item {
            id: shiftBox
            x: 1150; y: 215; width: 260; height: 77; z: 30

            // behavior knobs
            property int  showThreshold: 4000
            property int  blinkThreshold: 6000
            property int  hysteresis: 100
            property bool blink: true
            property real blinkHz: 2.0
            property string src: "qrc:/KeyDash_Assets/assets/ShiftIcon.png"

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
                target: dashController ? dashController : null
                function onRpmChanged() {
                    if (!dashController) return
                    const rpm = dashController.rpm
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
                visible: !!((dashController && dashController.rpm >= shiftBox.showThreshold) || blinkAnim.running)
                opacity: (dashController && dashController.rpm >= shiftBox.showThreshold ? 1 : 0)
                smooth: true
            }

            property int periodMs: Math.max(60, Math.round(1000 / Math.max(0.1, blinkHz)))
            SequentialAnimation {
                id: blinkAnim
                running: shiftBox.blink && shiftBox.blinkActive
                loops: Animation.Infinite
                NumberAnimation { target: shiftImg; property: "opacity"; from: 0.25; to: 1.0; duration: shiftBox.periodMs/2; easing.type: Easing.InOutSine }
                NumberAnimation { target: shiftImg; property: "opacity"; from: 1.0;  to: 0.25; duration: shiftBox.periodMs/2; easing.type: Easing.InOutSine }
                onRunningChanged: if (!running) shiftImg.opacity = (dashController && dashController.rpm >= shiftBox.showThreshold ? 1 : 0)
            }
        }

    // Date / Odometer / Trip
        Item {
            id: dateBox
            x: 1940; y: 90; width: 420; height: 120

            // Format helper (depends on clock24 via parameter)
            function fmt(clock24) {
                return Qt.formatDateTime(new Date(),
                                         clock24 ? "dddd, MMM d\nHH:mm"
                                                 : "dddd, MMM d\nh:mma")
            }

            Text {
                id: clockText
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                textFormat: Text.PlainText
                wrapMode: Text.NoWrap
                font.family: (neu && neu.status === FontLoader.Ready && neu.name.length) ? neu.name : Qt.application.font.family
                font.pixelSize: 65
                color: theme.secondaryColor

                // Binding depends on prefs.clock24; updates when preference changes
                text: dateBox.fmt(prefs.clock24)
            }

            // Tick the minutes/seconds
            Timer {
                interval: 1000    // use 60000 if you only want minute updates
                running: true
                repeat: true
                onTriggered: clockText.text = dateBox.fmt(prefs.clock24)
            }
        }

        Item {
            id: odoBox; x: 1985; y: 320; width: 300; height: 60
            // Prefer live ECU (km), else fallback to persisted km
            readonly property real _odoKm:
                (dashController && dashController.odo !== undefined && dashController.odo !== null)
                    ? Number(dashController.odo)
                    : Number(prefs ? prefs.odoBackupKm : 0)

            Text {
                anchors.centerIn: parent

                // live value in KM if available; otherwise NaN
                property real __odoKmLive: (dashController && isFinite(Number(dashController.odo)))
                                           ? Number(dashController.odo) : NaN
                // choose live if valid, else backup (km)
                property real __odoKm: isNaN(__odoKmLive) ? Number(prefs.odoBackupKm || 0) : __odoKmLive

                text: prefs.useMph
                      ? (numFmt(kmToMiles(__odoKm), 0) + " mi")
                      : (numFmt(__odoKm, 0)          + " km")

                color: theme.primaryColor; font.family: neu.name; font.pixelSize: 50
            }
        }
        Item {
            id: tripBox; x: 1995; y: 470; width: 300; height: 60
            // Prefer live ECU (km), else fallback to persisted km
            readonly property real _tripKm:
                (dashController && dashController.trip !== undefined && dashController.trip !== null)
                    ? Number(dashController.trip)
                    : Number(prefs ? prefs.tripBackupKm : 0)

            Text {
                anchors.centerIn: parent

                // live value in KM if available; otherwise NaN
                property real __tripKmLive: (dashController && isFinite(Number(dashController.trip)))
                                            ? Number(dashController.trip) : NaN
                // choose live if valid, else backup (km)
                property real __tripKm: isNaN(__tripKmLive) ? Number(prefs.tripBackupKm || 0) : __tripKmLive

                text: prefs.useMph
                      ? (numFmt(kmToMiles(__tripKm), 1) + " mi.")
                      : (numFmt(__tripKm, 1)           + " km")

                color: theme.primaryColor; font.family: neu.name; font.pixelSize: 50
            }
        }

        // Keep persisted backups fresh (stored in KM)
        Connections {
            target: dashController ? dashController : null
            function onOdoChanged() {
                if (!prefs) return
                const km = Number(dashController.odo || 0)
                if (km >= 0) prefs.odoBackupKm = km
            }
            function onTripChanged() {
                if (!prefs) return
                const km = Number(dashController.trip || 0)
                if (km >= 0) prefs.tripBackupKm = km
            }
        }

        Component.onCompleted: {
            // seed backups once on load if available
            if (dashController && prefs) {
                if (dashController.odo  !== undefined && dashController.odo  !== null)
                    prefs.odoBackupKm  = Number(dashController.odo)
                if (dashController.trip !== undefined && dashController.trip !== null)
                    prefs.tripBackupKm = Number(dashController.trip)
            }
        }

          // Turn signals and status lamps
          // Left turn indicator with thump animation
        Item {
            id: leftTurn
            x: 1793; y: 592; width: 81; height: 68
            visible: (((dashController && dashController.leftSignal) || dashPage.selfTest) ? dashPage.turnPhase : 0) > 0
            opacity: ((dashController && dashController.leftSignal) || dashPage.selfTest) ? dashPage.turnPhase : 0
            transformOrigin: Item.Center
            scale: 1
            Image { anchors.fill: parent; source: "qrc:/KeyDash_Assets/assets/LeftTurnSignal_On.png"; smooth: true }
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

    // Right turn indicator with thump animation
        Item {
            id: rightTurn
            x: 2393; y: 592; width: 81; height: 69
            visible: (((dashController && dashController.rightSignal) || dashPage.selfTest) ? dashPage.turnPhase : 0) > 0
            opacity: ((dashController && dashController.rightSignal) || dashPage.selfTest) ? dashPage.turnPhase : 0
            transformOrigin: Item.Center
            scale: 1
            Image { anchors.fill: parent; source: "qrc:/KeyDash_Assets/assets/RightTurnSignal_On.png"; smooth: true }
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

    // Status lamps: TCS, CEL, Headlights
        Lamp { id: tcsLamp;  x: 1998; y: 587; width: 53; height: 60;  source: "qrc:/KeyDash_Assets/assets/TractionControl_On.png"; on: (dashController && dashController.tcsOn)  || dashPage.selfTest }
        Lamp { id: celLamp;  x: 2088; y: 583; width: 96; height: 64;  source: "qrc:/KeyDash_Assets/assets/CEL_On.png";             on: (dashController && dashController.celOn)  || dashPage.selfTest }
        Lamp { id: headLamp; x: 2208; y: 585; width: 96; height: 62;  source: "qrc:/KeyDash_Assets/assets/Headlight_On.png";       on: (dashController && dashController.headlightsOn) || dashPage.selfTest }

          // Coolant warning toast
        Connections {
            target: dashController ? dashController : null
            function onCltChanged() {
                if (dashController && dashController.clt >= 105 && !dashPage.cltWarn) { dashPage.cltWarn = true; Qt.callLater(()=>warnHide.start()) }
            }
        }
        Timer { id: warnHide; interval: 3000; onTriggered: dashPage.cltWarn = false }
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 90; width: 420; height: 56; radius: 12
            color: "#cc3333"
            opacity: dashPage.cltWarn ? 1 : 0
            visible: opacity > 0
            z: 9500
            Behavior on opacity { NumberAnimation { duration: 180 } }
            Text {
                anchors.centerIn: parent
                text: "Coolant High: " + (dashController ? Math.round(dashController.clt) : 0) + "°"
                color: "white"; font.family: neu.name; font.pixelSize: 22
            }
        }

        // Initialize DashModel defaults at startup
        Item {
            id: modelInit

            Component.onCompleted: {
                if (!dashController) return
                // Ensure DashModel configuration is loaded before showing this page. In C++ call dashController.loadVehicleConfig() as appropriate.

                // Mirror prefs -> model on first load
                dashController.setUseMph(prefs.useMph)
                dashController.setRpmMax(prefs.rpmMax)

                // If you don't have an INI yet, set your drivetrain here:
                dashController.setFinalDrive(4.080)
                dashController.setGearRatio(1, 3.321)
                dashController.setGearRatio(2, 1.902)
                dashController.setGearRatio(3, 1.308)
                dashController.setGearRatio(4, 1.000)
                dashController.setGearRatio(5, 0.891)
            }

            // Keep model in sync if the user changes prefs later
            Connections {
              target: prefs
              function onUseMphChanged() { if (dashController && dashController.setUseMph) dashController.setUseMph(prefs.useMph) }
              function onRpmMaxChanged() { if (dashController && dashController.setRpmMax) dashController.setRpmMax(prefs.rpmMax) }
            }

            // Keep prefs updated if the model changes units elsewhere (e.g., C++)
            Connections {
              target: dashController ? dashController : null
              function onUseMphChanged() {
                if (dashController && prefs.useMph !== dashController.useMph) prefs.useMph = dashController.useMph
              }
            }
        }

          // ECU connection banner
        Rectangle {
            id: statusBar
            anchors.top: parent.top
            width: parent.width; height: 28
            color: (dashController && dashController.connected) ? "#0b2a0b" : "#2a0b0b"
            opacity: (dashController && dashController.connected) ? 0 : 0.9
            visible: opacity > 0
            z: 9999
            Text { anchors.centerIn: parent; text: (dashController && dashController.connected) ? "" : "ECU DISCONNECTED"; color: theme.secondaryColor; font.family: neu.name; font.pixelSize: 20 }
        }

          // Intro overlay (curtain, title, sweep, reveal)
        Item {
            id: introOverlay
            anchors.fill: parent
            z: 10002
            visible: (prefs.introEnable && !dashPage.skipIntro)

            onVisibleChanged: {
                if (!visible) {
                    // If it gets hidden later, still ensure we are fully revealed and not sweeping
                    setGroupOpacity(1)
                    rpmBar.sweeping = false
                    introAnim.stop()
                }
            }

            // Animation durations scaled by persisted factor
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
                color: theme.secondaryColor
                font.family: neu.name                 // common family
                font.italic: neu_italic.status === FontLoader.Ready
                font.pixelSize: 130
                transform: Scale { id: titleScale; origin.x: introTitle.width / 2; origin.y: introTitle.height / 2; xScale: 1; yScale: 1 }
            }

            // Utility to set initial UI opacity for main groups
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

            // If intro disabled, reveal UI immediately
            Component.onCompleted: {
                // If intro is disabled OR we're in replay skip mode → reveal instantly
                if (!prefs.introEnable || dashPage.skipIntro) {
                    setGroupOpacity(1)     // show all UI
                    rpmBar.sweeping = false
                    introAnim.stop()
                    introOverlay.visible = false
                    return
                }

                // Otherwise run the normal intro sequence
                setGroupOpacity(0)
                introAnim.start()
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
                        dashPage.selfTest = true
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
    }

    // Temporary button/hotkey to open the new page
    Rectangle {
        id: settingsHotspot
        x: 1130; y: 635; width: 300; height: 80; radius: 12
        z: 10001
        color: theme.secondaryColor; opacity: 0
        border.color: theme.secondaryColor; border.width: 1
        MouseArea { anchors.fill: parent; hoverEnabled: true; onClicked: dashPage.openService() }
    }
}

