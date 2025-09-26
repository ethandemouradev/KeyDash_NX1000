import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform 1.1
// provides StandardPaths
import Qt.labs.folderlistmodel 2.15
import QtQuick.Dialogs
import "qrc:/KeyDash_NX1000/style"
import "qrc:/KeyDash_NX1000/pages"
import "qrc:/KeyDash_NX1000/errors/Errors.js" as Errors

Page {
    id: svc
    signal done
    signal openReplay(url fileUrl, bool autoPlay)

    // Input properties passed from parent
    required property var prefs
    property var dashController: null

    // Per-tab horizontal offsets (px)
    property real offsetDeviceX: -200
    property real offsetTachX: -27
    property real offsetDisplayX: -75
    property real offsetGaugesX: -100
    property real offsetPerfX: 30

    // Background image and font loaders
    Image {
        anchors.fill: parent
        source: "qrc:/KeyDash_NX1000/assets/BlankBackground.png"
        fillMode: Image.Stretch
    }
    FontLoader {
        id: neu
        source: "qrc:/KeyDash_NX1000/fonts/NeuropolX_Lite.ttf"
    }
    FontLoader {
        id: neuItalic
        source: "qrc:/KeyDash_NX1000/fonts/NeuropolX_Italic.ttf"
    }

    function dashFontName() {
        return (neu.status === FontLoader.Ready
                && neu.name.length) ? neu.name : Qt.application.font.family
    }

    // Convert filesystem path to file:// URL for QML APIs
    function asUrl(path) {
        if (!path || path.length === 0)
            return ""
        const s = String(path)
        if (s.startsWith("file:/"))
            return s
        return "file:///" + s.replace(/\\/g, "/")
    }

    // Diagnostic utilities for unmapped ECU/backend errors (ring buffer)
    property bool debugErrs: true
    property var _unmappedRing: [] // ring buffer (last ~10 entries)

    function logUnmapped(msg, rawCode, note) {
        if (!debugErrs)
            return
        const entry = {
            "msg": (msg || "").toString(),
            "rawCode": (rawCode === undefined
                        || rawCode === null) ? "" : ("" + rawCode),
            "note": note || ""
        }
        _unmappedRing.push(entry)
        if (_unmappedRing.length > 10)
            _unmappedRing.shift()
        console.warn("[ERR-MAP] unmapped →", JSON.stringify(entry))
    }

    // Fallback Errors API when Errors.js is unavailable
    readonly property var errApi: (Errors && Errors.API) ? Errors.API : ({
                                                                             "text": function (code) {
                                                                                 return "Unknown error (" + code + ")"
                                                                             },
                                                                             "key": function (code) {
                                                                                 return "UNKNOWN"
                                                                             },
                                                                             "exists": function () {
                                                                                 return false
                                                                             },
                                                                             "Codes": {
                                                                                 "UNKNOWN": 0x1F01,
                                                                                 "CONNECT_FAILED": 0x1101,
                                                                                 "ADDR_EMPTY": 0x1202,
                                                                                 "ADDR_INVALID": 0x1201,
                                                                                 "NO_DEVICES_FOUND": 0x1003
                                                                             },
                                                                             "describe": function (code) {
                                                                                 return {
                                                                                     "code": code,
                                                                                     "hex": "0x" + Number(code).toString(16).toUpperCase(),
                                                                                     "key": "UNKNOWN",
                                                                                     "msg": ""
                                                                                 }
                                                                             }
                                                                         })


    /**
     * Classify ECU/backend error text into a stable numeric code.
     * Returns an object: { code, params, overrideText }.
     * - code: numeric identifier (rendered as hex)
     * - params: optional parameters for formatting
     * - overrideText: original message to display
     *
     * Contains heuristics for common Windows/WinSock messages.
     */
    function classifyEcuError(msg, rawCode) {
        var txt = (msg || "").toString()
        var code = (rawCode !== undefined && rawCode !== null
                    && ("" + rawCode) !== "") ? rawCode : ""

        // Extract explicit WSA number if present (e.g., "10044")
        var mNum = txt.match(/\b(100\d{2})\b/) // matches 100xx
        var wsa = mNum ? mNum[1] : ""
        // Map known WinSock WSA numbers to internal error codes
        var wsaMap = {
            "10044": 0x1310,
            "10047"// invalid socket type
            : 0x1311,
            "10043"// address family not supported
            : 0x1312,
            "10049"// protocol not supported
            : 0x1313,
            "10013"// address not available
            : 0x1314,
            "10060"// permission denied / access denied
            : 0x1315,
            "10061"// timed out
            : 0x1316,
            "10051"// connection refused
            : 0x1317,
            "10065"// network unreachable
            : 0x1318 // host unreachable
        }
        if (wsa && wsaMap[wsa]) {
            return {
                "code": wsaMap[wsa],
                "params": {
                    "wsa": wsa
                },
                "overrideText": txt
            }
        }

        // Substring/regex heuristics when no explicit WSA number present
        var lower = txt.toLowerCase()
        if (lower.indexOf("invalid socket type") >= 0
                || /sockt?nosupport/i.test(txt)) {
            return {
                "code": 0x1310,
                "params": {},
                "overrideText": txt
            }
        }
        if (lower.indexOf("address family not supported") >= 0) {
            return {
                "code": 0x1311,
                "params": {},
                "overrideText": txt
            }
        }
        if (lower.indexOf("protocol not supported") >= 0) {
            return {
                "code": 0x1312,
                "params": {},
                "overrideText": txt
            }
        }
        if (lower.indexOf("permission denied") >= 0 || lower.indexOf(
                    "access is denied") >= 0) {
            return {
                "code": 0x1314,
                "params": {},
                "overrideText": txt
            }
        }
        if (lower.indexOf("timed out") >= 0) {
            return {
                "code": 0x1315,
                "params": {},
                "overrideText": txt
            }
        }
        if (lower.indexOf("connection refused") >= 0) {
            return {
                "code": 0x1316,
                "params": {},
                "overrideText": txt
            }
        }
        if (lower.indexOf("network is unreachable") >= 0) {
            return {
                "code": 0x1317,
                "params": {},
                "overrideText": txt
            }
        }
        if (lower.indexOf("no such host") >= 0 || lower.indexOf(
                    "host unreachable") >= 0) {
            return {
                "code": 0x1318,
                "params": {},
                "overrideText": txt
            }
        }

        // Preserve numeric backend codes (render as hex)
        if (code !== "")
            return {
                "code": code,
                "params": {},
                "overrideText": txt
            }
        // Fallback: record unmapped entry and return generic connect-failed code
        logUnmapped(txt, rawCode, "fallback CONNECT_FAILED")
        return {
            "code": (errApi.Codes.CONNECT_FAILED || 0x1101),
            "params": {},
            "overrideText": txt
        }
    }

    // Display a coded error using the deviceTab overlay
    function showError(code, params, overrideText) {
        var c = (code !== undefined && code !== null
                 && ("" + code) !== "") ? code : (errApi.Codes.UNKNOWN
                                                  || 0x1F01)
        var msg = overrideText || errApi.text(c, params)

        deviceTab.lastError = msg
        deviceTab.lastErrorCode = String(c)
        deviceTab.errorSeq++
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
    const start = toMins(svc.prefs.nightStart)
    const end = toMins(svc.prefs.nightEnd)
    if (start === null || end === null)
    return false
    const nowMin = now.getHours() * 60 + now.getMinutes()
    return (start <= end) ? (nowMin >= start
    && nowMin < end) : (nowMin >= start || nowMin < end)
}

// Status banner: ECU connection state
Rectangle {
    id: statusBar
    anchors.top: parent.top
    width: parent.width
    height: 36
    color: (ecu && ecu.isConnected && ecu.isConnected()) ? "#0b2a0b" : "#2a0b0b"
    opacity: (ecu && ecu.isConnected && ecu.isConnected()) ? 0 : 0.9
    visible: opacity > 0
    Text {
        anchors.centerIn: parent
        text: (ecu && ecu.isConnected && ecu.isConnected(
                   )) ? "" : "ECU DISCONNECTED"
        color: "#ffcc00"
        font.family: dashFontName()
        font.pixelSize: 28
    }
}

// Global dimmer overlay for night brightness adjustments
Rectangle {
    anchors.fill: parent
    color: "black"
    property real targetB: isNight() ? (svc.prefs.brightnessNight
                                        ?? 0.35) : (svc.prefs.brightness ?? 1.0)
    opacity: Math.max(0, Math.min(1, 1.0 - targetB))
    z: 9999
    visible: opacity > 0
}

// Styled tab component used by the TabBar
component StyledTab: TabButton {
    id: __tab
    // allow caller to pass a tracker
    property var metrics: null

    implicitHeight: 64
    leftPadding: 10
    rightPadding: 10
    background: Item {}

    contentItem: Text {
        id: tabText
        text: __tab.text
        font.family: dashFontName()
        font.pixelSize: 72
        font.letterSpacing: 0.5
        color: __tab.checked ? "white" : "#9fb0bd"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        // keep metrics up to date
        onPaintedWidthChanged: {
            if (__tab.metrics)
            __tab.metrics.maxPainted = Math.max(__tab.metrics.maxPainted,
                                                paintedWidth)
        }
        Component.onCompleted: {
            if (__tab.metrics)
            __tab.metrics.maxPainted = Math.max(__tab.metrics.maxPainted,
                                                paintedWidth)
        }
    }

    // Tab sizing: use shared max painted width for equal-width tabs; otherwise size to text
    implicitWidth: Math.ceil(
                       (metrics
                        && metrics.equalize ? (metrics.maxPainted
                                               || tabText.paintedWidth) : tabText.paintedWidth))
                   + leftPadding + rightPadding
}

// HoldButton: press-and-hold action with visual progress
component HoldButton: Item {
    id: hb
    width: 280
    height: 64
    property string label: "Hold to Reset Trip"
    property int holdMs: 1200
    signal activated
    property bool pressed: false
    property real progress: 0.0 // 0..1 fill from left to right

    // outer frame
    Rectangle {
        anchors.fill: parent
        radius: 12
        border.width: 3
        border.color: "#ffcc00"
        color: "transparent"
    }

    // Progress fill (left-to-right)
    Rectangle {
        id: fill
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width * hb.progress
        radius: 12
        color: "#ffcc00"
        opacity: 0.50 // subtle fill; tweak if you want stronger
        Behavior on width {
            NumberAnimation {
                duration: 60
                easing.type: Easing.OutCubic
            }
        }
    }

    // label
    Text {
        anchors.centerIn: parent
        text: hb.pressed ? "Keep holding…" : hb.label
        font.family: dashFontName()
        font.pixelSize: 26
        color: (hb.progress > 0.7) ? "black" : "#ffcc00"
    }

    // Touch area and interaction
    MouseArea {
        anchors.fill: parent
        onPressed: {
            hb.pressed = true
            hb.progress = 0
            tick.start()
        }
        onReleased: {
            hb.pressed = false
            tick.stop()
            hb.progress = 0
        }
        onCanceled: {
            hb.pressed = false
            tick.stop()
            hb.progress = 0
        }
    }

    // Timer driving the hold progress
    Timer {
        id: tick
        interval: 16
        repeat: true
        property int elapsed: 0
        onTriggered: {
            elapsed += interval
            hb.progress = Math.min(1, elapsed / hb.holdMs)
            if (elapsed >= hb.holdMs) {
                stop()
                elapsed = 0
                hb.pressed = false
                hb.activated()
                hb.progress = 0
            }
        }
        onRunningChanged: if (!running) {
            elapsed = 0
        }
    }
}

// Modal backdrop that blocks input behind popups
Rectangle {
    id: modalDim
    anchors.fill: parent
    color: "black"
    opacity: (macPad.visible || timePad.visible || numPad.visible
              || replayPopup.visible || crashLogsPopup.visible) ? 0.5 : 0
    visible: opacity > 0
    z: 12000
    Behavior on opacity {
        NumberAnimation {
            duration: 120
        }
    }
    MouseArea {
        anchors.fill: parent
    } // eat clicks behind dialogs
}

// Hex keypad used to enter Bluetooth MAC addresses
Item {
    id: macPad
    visible: false
    z: 12100
    anchors.centerIn: parent
    width: 560
    height: 455

    property string value: ""
    property var acceptCallback: null

    function pushChar(c) {
        let raw = macPad.value.replace(/:/g, "")
        if (raw.length >= 12)
            return
        raw += c
        let out = ""
        for (var i = 0; i < raw.length; i++) {
            if (i && (i % 2 === 0))
                out += ":"
            out += raw[i]
        }
        macPad.value = out.toUpperCase()
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: "#0b151a"
        border.color: "#28424d"
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        Text {
            text: "Enter Bluetooth Address"
            color: "#ffcc00"
            font.family: dashFontName()
            font.pixelSize: 26
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }

        Rectangle {
            width: parent.width
            height: 54
            radius: 8
            color: "#0f232b"
            border.color: "#2f4b57"
            Text {
                anchors.centerIn: parent
                text: macPad.value.length ? macPad.value : "AA:BB:CC:DD:EE:FF"
                color: macPad.value.length ? "white" : "#7a8b94"
                font.pixelSize: 22
                font.family: dashFontName()
            }
        }

        GridLayout {
            columns: 4
            rowSpacing: 10
            columnSpacing: 10
            Layout.fillWidth: true

            Repeater {
                model: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "A", "B", "C", "D", "E", "F"]
                delegate: Button {
                    text: modelData
                    implicitWidth: 120
                    implicitHeight: 56
                    font.pixelSize: 22
                    onClicked: macPad.pushChar(modelData)
                }
            }

            Button {
                text: "Back"
                implicitWidth: 120
                implicitHeight: 56
                font.pixelSize: 22
                onClicked: {
                    let raw = macPad.value.replace(/:/g, "")
                    raw = raw.slice(0, Math.max(0, raw.length - 1))
                    let out = ""
                    for (var i = 0; i < raw.length; i++) {
                        if (i && (i % 2 === 0))
                        out += ":"
                        out += raw[i]
                    }
                    macPad.value = out
                }
            }
            Button {
                text: "Clear"
                implicitWidth: 120
                implicitHeight: 56
                font.pixelSize: 22
                onClicked: macPad.value = ""
            }
            Button {
                text: "Cancel"
                implicitWidth: 120
                implicitHeight: 56
                font.pixelSize: 22
                onClicked: {
                    macPad.visible = false
                    macPad.acceptCallback = null
                }
            }
            Button {
                text: "OK"
                implicitWidth: 120
                implicitHeight: 56
                font.pixelSize: 22
                enabled: macPad.value.replace(/:/g, "").length === 12
                onClicked: {
                    if (macPad.acceptCallback)
                    macPad.acceptCallback(macPad.value)
                    macPad.visible = false
                    macPad.acceptCallback = null
                }
            }
        }
    }
}

// Time picker component (HH:MM)
Item {
    id: timePad
    visible: false
    z: 12100
    anchors.centerIn: parent
    width: 460
    height: 330

    property int hour: 19
    property int minute: 0
    property string label: "Time"
    property var acceptCallback: null

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: "#0b151a"
        border.color: "#28424d"
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        Text {
            text: timePad.label
            color: "#ffcc00"
            font.family: dashFontName()
            font.pixelSize: 26
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }

        Row {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Column {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter
                Button {
                    text: "▲"
                    implicitWidth: 90
                    implicitHeight: 50
                    font.pixelSize: 22
                    onClicked: timePad.hour = (timePad.hour + 1) % 24
                }
                Rectangle {
                    width: 90
                    height: 50
                    radius: 8
                    color: "#0f232b"
                    border.color: "#2f4b57"
                    Text {
                        anchors.centerIn: parent
                        text: ("0" + timePad.hour).slice(-2)
                        color: "white"
                        font.pixelSize: 24
                    }
                }
                Button {
                    text: "▼"
                    implicitWidth: 90
                    implicitHeight: 50
                    font.pixelSize: 22
                    onClicked: timePad.hour = (timePad.hour + 23) % 24
                }
            }

            Text {
                text: ":"
                color: "white"
                font.pixelSize: 28
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter
                Button {
                    text: "▲"
                    implicitWidth: 90
                    implicitHeight: 50
                    font.pixelSize: 22
                    onClicked: timePad.minute = (timePad.minute + 1) % 60
                }
                Rectangle {
                    width: 90
                    height: 50
                    radius: 8
                    color: "#0f232b"
                    border.color: "#2f4b57"
                    Text {
                        anchors.centerIn: parent
                        text: ("0" + timePad.minute).slice(-2)
                        color: "white"
                        font.pixelSize: 24
                    }
                }
                Button {
                    text: "▼"
                    implicitWidth: 90
                    implicitHeight: 50
                    font.pixelSize: 22
                    onClicked: timePad.minute = (timePad.minute + 59) % 60
                }
            }
        }

        Row {
            spacing: 14
            anchors.horizontalCenter: parent.horizontalCenter
            Button {
                text: "Cancel"
                implicitWidth: 140
                implicitHeight: 50
                font.pixelSize: 22
                onClicked: {
                    timePad.visible = false
                    timePad.acceptCallback = null
                }
            }
            Button {
                text: "OK"
                implicitWidth: 140
                implicitHeight: 50
                font.pixelSize: 22
                onClicked: {
                    const s = ("0" + timePad.hour).slice(
                        -2) + ":" + ("0" + timePad.minute).slice(-2)
                    if (timePad.acceptCallback)
                    timePad.acceptCallback(s)
                    timePad.visible = false
                    timePad.acceptCallback = null
                }
            }
        }
    }
}

// Numeric keypad (auto-sizing) for numeric preferences
Item {
    id: numPad
    visible: false
    z: 12100
    anchors.centerIn: parent

    // padding around the inner column
    property int pad: 16

    // Implicit size equals content size plus padding
    implicitWidth: Math.max(360, numPadCol.implicitWidth + pad * 2)
    implicitHeight: numPadCol.implicitHeight + pad * 2

    // Clamp to parent to prevent overflow
    width: parent ? Math.min(implicitWidth, parent.width - 40) : implicitWidth
    height: parent ? Math.min(implicitHeight,
                              parent.height - 40) : implicitHeight

    // config
    property string label: "Value"
    property int min: 0
    property int max: 100
    property int step: 1
    property int value: 0
    property string suffix: "" // e.g., "ms"
    property var acceptCallback: null

    // internal
    property string _buffer: ""

    function clamp(v) {
        return Math.max(min, Math.min(max, v))
    }
    function apply() {
        let v = _buffer.length ? parseInt(_buffer) : value
        if (isNaN(v))
            v = value
        v = Math.round(v / step) * step
        v = clamp(v)
        if (acceptCallback)
            acceptCallback(v)
        numPad.visible = false
        numPad.acceptCallback = null
        numPad._buffer = ""
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: "#0b151a"
        border.color: "#28424d"
    }

    // To enable auto-scroll when content is clamped, wrap this Column in a Flickable.
    Column {
        id: numPadCol
        anchors.fill: parent
        anchors.margins: numPad.pad
        spacing: 14

        Text {
            text: numPad.label
            color: "#ffcc00"
            font.family: dashFontName()
            font.pixelSize: 26
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }

        Rectangle {
            width: parent.width
            height: 64
            radius: 8
            color: "#0f232b"
            border.color: "#2f4b57"
            Row {
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: (numPad._buffer.length ? numPad._buffer : numPad.value)
                          + (numPad.suffix ? (" " + numPad.suffix) : "")
                    color: "white"
                    font.pixelSize: 26
                    font.family: dashFontName()
                }
            }
        }

        GridLayout {
            columns: 3
            rowSpacing: 10
            columnSpacing: 10
            Layout.fillWidth: true

            Repeater {
                model: ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
                delegate: Button {
                    text: modelData
                    implicitWidth: 110
                    implicitHeight: 56
                    font.pixelSize: 22
                    onClicked: numPad._buffer += modelData
                }
            }

            Button {
                text: "0"
                implicitWidth: 110
                implicitHeight: 56
                font.pixelSize: 22
                onClicked: numPad._buffer += "0"
                Layout.columnSpan: 2
            }
            Button {
                text: "+"
                implicitWidth: 110
                implicitHeight: 56
                font.pixelSize: 22
                onClicked: {
                    let v = numPad.clamp(
                        (numPad._buffer.length ? parseInt(
                                                     numPad._buffer) : numPad.value) + numPad.step)
                    numPad._buffer = String(v)
                }
            }

            Button {
                text: "Back"
                implicitWidth: 110
                implicitHeight: 50
                font.pixelSize: 20
                onClicked: numPad._buffer = numPad._buffer.slice(0, -1)
            }
            Button {
                text: "Clear"
                implicitWidth: 110
                implicitHeight: 50
                font.pixelSize: 20
                onClicked: numPad._buffer = ""
            }
            Button {
                text: "−"
                implicitWidth: 110
                implicitHeight: 50
                font.pixelSize: 22
                onClicked: {
                    let v = numPad.clamp(
                        (numPad._buffer.length ? parseInt(
                                                     numPad._buffer) : numPad.value) - numPad.step)
                    numPad._buffer = String(v)
                }
            }
        }

        Row {
            spacing: 14
            anchors.horizontalCenter: parent.horizontalCenter
            Button {
                text: "Cancel"
                implicitWidth: 140
                implicitHeight: 50
                font.pixelSize: 22
                onClicked: {
                    numPad.visible = false
                    numPad.acceptCallback = null
                    numPad._buffer = ""
                }
            }
            Button {
                text: "OK"
                implicitWidth: 140
                implicitHeight: 50
                font.pixelSize: 22
                onClicked: numPad.apply()
            }
        }

        Text {
            text: "Range: " + numPad.min + "–" + numPad.max
                  + (numPad.suffix ? (" " + numPad.suffix) : "") + "  •  step " + numPad.step
            color: "#9fb0bd"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }
    }
}

// Replay browser popup for opening recorded logs
Popup {
    id: replayPopup
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    z: 12100
    x: Math.round((svc.width - width) / 2)
    y: Math.round((svc.height - height) / 2)
    width: Math.min(svc.width * 0.8, 960)
    height: Math.min(svc.height * 0.8, 560)

    background: Rectangle {
        radius: 14
        color: "#0b151a"
        border.color: "#28424d"
        border.width: 1
    }

    // Lightweight state for the replay picker
    QtObject {
        id: replayPicker
        property url lastSelection: ""
        property bool autoPlay: true
    }

    // Sync FolderListModel with preferences when popup is shown
    onVisibleChanged: if (visible)
    logs.folder = asUrl(svc.prefs.logDir)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: "Replay Browser"
                font.pixelSize: 20
                color: "#ffcc00"
                font.family: dashFontName()
            }
            Item {
                Layout.fillWidth: true
            }
            ThemedButton {
                text: "✕"
                width: 56
                height: 40
                onClicked: replayPopup.close()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            TextField {
                id: folderField
                Layout.fillWidth: true
                placeholderText: "Select your logs folder…"
                text: svc.prefs.logDir
                onEditingFinished: {
                    if (text !== svc.prefs.logDir) {
                        svc.prefs.logDir = text
                        logs.folder = asUrl(text)
                    }
                }
            }
            ThemedButton {
                text: "Browse…"
                width: 140
                height: 50
                onClicked: dirDialog.open()
            }
            ThemedButton {
                text: "Refresh"
                width: 140
                height: 50
                onClicked: logs.folder = asUrl(svc.prefs.logDir)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Label {
                    text: "Replays in: "
                          + (svc.prefs.logDir
                             && svc.prefs.logDir.length ? svc.prefs.logDir : "(not set)")
                    color: "#9fb0bd"
                    font.pixelSize: 16
                    elide: Label.ElideRight
                    Layout.fillWidth: true
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "#0f232b"
                    border.color: "#2f4b57"
                    border.width: 1
                }

                FolderListModel {
                    id: logs
                    folder: asUrl(svc.prefs.logDir)
                    nameFilters: ["*.csv", "*.json"]
                    showDirs: false
                    showDotAndDotDot: false
                    sortField: FolderListModel.Time
                    sortReversed: true
                }

                ListView {
                    id: logList
                    anchors.fill: parent
                    clip: true
                    model: logs
                    highlight: Rectangle {
                        color: "#244059"
                        radius: 8
                        opacity: 0.5
                    }
                    ScrollBar.vertical: ScrollBar {}

                    footer: Item {
                        width: 1
                        height: logs.count === 0 ? 80 : 0
                        Rectangle {
                            anchors.centerIn: parent
                            width: logList.width - 40
                            height: 60
                            radius: 10
                            color: "#0f232b"
                            border.color: "#2f4b57"
                            visible: logs.count === 0
                            Text {
                                anchors.centerIn: parent
                                text: (svc.prefs.logDir
                                       && svc.prefs.logDir.length) ? "No .csv or .json logs found in this folder." : "Choose a log folder in Settings → Performance."
                                color: "#9fb0bd"
                                font.pixelSize: 18
                            }
                        }
                    }

                    delegate: ItemDelegate {
                        width: ListView.view.width
                        text: fileName
                        font.pixelSize: 20
                        background: Rectangle {
                            color: hovered ? "#1b3342" : "transparent"
                        }
                        onClicked: {
                            logList.currentIndex = index
                            replayPicker.lastSelection = logs.get(index,
                                                                  "fileURL")
                        }
                        contentItem: Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8
                            Text {
                                text: fileName
                                color: "white"
                                font.pixelSize: 20
                                elide: Text.ElideRight
                                width: parent.width * 0.70
                            }
                            Item {
                                Layout.fillWidth: true
                                width: 1
                                height: 1
                            }
                            Text {
                                text: Qt.formatDateTime(fileModified,
                                                        "yyyy-MM-dd  HH:mm")
                                color: "#9fb0bd"
                                font.pixelSize: 16
                                horizontalAlignment: Text.AlignRight
                                width: parent.width * 0.28
                            }
                        }
                    }

                    Component.onCompleted: {
                        if (!replayPicker || !replayPicker.lastSelection
                            || !replayPicker.lastSelection.length) {
                            if (logs.count > 0)
                            currentIndex = 0
                            return
                        }
                        var want = String(replayPicker.lastSelection)
                        var found = -1
                        for (var i = 0; i < logs.count; ++i) {
                            if (String(logs.get(i, "fileURL")) === want) {
                                found = i
                                break
                            }
                        }
                        currentIndex = (found >= 0) ? found : (logs.count > 0 ? 0 : -1)
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10

                RowLayout {
                    spacing: 6
                    CheckBox {
                        id: autoPlayCheck
                        checked: replayPicker.autoPlay
                        onToggled: replayPicker.autoPlay = checked
                    }
                    Label {
                        text: "Auto-play on open"
                        color: "white"
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                ThemedButton {
                    text: "Cancel"
                    onClicked: replayPopup.close()
                }
                ThemedButton {
                    text: "Open"
                    enabled: logs.count > 0 && logList.currentIndex >= 0
                    onClicked: {
                        const idx = logList.currentIndex
                        const fileUrl = logs.get(idx, "fileURL")
                        replayPicker.lastSelection = fileUrl
                        svc.openReplay(fileUrl,
                                       replayPicker.autoPlay) // <-- pass it out
                        replayPopup.close()
                    }
                }
            }
        }
    }

    FolderDialog {
        id: dirDialog
        title: "Select your logs folder"
        onAccepted: {
            folderField.text = selectedFolder
            svc.prefs.logDir = selectedFolder
            logs.folder = asUrl(selectedFolder)
        }
    }
}

Popup {
    id: crashLogsPopup
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    z: 12100
    x: Math.round((svc.width - width) / 2)
    y: Math.round((svc.height - height) / 2)
    width: Math.min(svc.width * 0.9, 1100)
    height: Math.min(svc.height * 0.85, 640)
    background: Rectangle {
        radius: 14
        color: "#0b151a"
        border.color: "#28424d"
        border.width: 1
    }

    // Crash log directory (consistent with CrashLog::init in C++)
    readonly property string crashDir: StandardPaths.writableLocation(
                                           StandardPaths.AppDataLocation) + "/"
                                       + Qt.application.name

    // Currently selected crash log file for the viewer
    property url viewerFileUrl: ""

    // Load crash log text synchronously for the viewer
    QtObject {
        id: crashTxt
        property string text: ""
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // Header
        RowLayout {
            Layout.fillWidth: true
            Label {
                text: (stack.currentIndex
                       === 0) ? "Crash Logs" : ("Crash Log — " + decodeURIComponent(
                                                    String(
                                                        crashLogsPopup.viewerFileUrl)).replace(
                                                    /^file:\/\/\//, ""))
                color: "#ffcc00"
                font.pixelSize: 20
                font.family: dashFontName()
                elide: Label.ElideRight
                Layout.fillWidth: true
            }
            ThemedButton {
                text: (stack.currentIndex === 0) ? "Close" : "Back"
                width: 120
                height: 44
                onClicked: {
                    if (stack.currentIndex === 0)
                    crashLogsPopup.close()
                    else {
                        stack.currentIndex = 0
                        crashLogsPopup.viewerFileUrl = ""
                        crashTxt.text = ""
                    }
                }
            }
        }

        StackLayout {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0 // 0=list, 1=viewer

            // Page 0: List view
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    // Top row: folder and actions
                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "Folder: " + crashLogsPopup.crashDir
                            color: "#9fb0bd"
                            font.pixelSize: 14
                            elide: Label.ElideRight
                            Layout.fillWidth: true
                        }
                        ThemedButton {
                            text: "Open Folder"
                            width: 150
                            height: 40
                            font.pixelSize: 16
                            onClicked: Qt.openUrlExternally(
                                           asUrl(crashLogsPopup.crashDir))
                        }
                        ThemedButton {
                            text: "Refresh"
                            width: 120
                            height: 40
                            font.pixelSize: 16
                            onClicked: crashlogs.folder = asUrl(
                                           crashLogsPopup.crashDir)
                        }
                    }

                    // List container
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        // dark card behind the ListView
                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: "#0f232b"
                            border.color: "#2f4b57"
                            border.width: 1
                        }

                        // Crash logs FolderListModel
                        FolderListModel {
                            id: crashlogs
                            folder: asUrl(crashLogsPopup.crashDir)
                            nameFilters: ["crashlog*.txt"]
                            showDirs: false
                            showDotAndDotDot: false
                            sortField: FolderListModel.Time
                            sortReversed: true
                        }

                        ListView {
                            id: crashlogList
                            anchors.fill: parent
                            clip: true
                            model: crashlogs
                            highlight: Rectangle {
                                color: "#244059"
                                radius: 8
                                opacity: 0.5
                            }
                            ScrollBar.vertical: ScrollBar {}

                            delegate: ItemDelegate {
                                width: ListView.view.width
                                text: fileName
                                font.pixelSize: 20

                                background: Rectangle {
                                    color: hovered ? "#1b3342" : "transparent"
                                }
                                contentItem: Text {
                                    text: fileName
                                    color: "white"
                                    font.pixelSize: 20
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    crashlogList.currentIndex = index
                                    const url = crashlogs.get(
                                        index,
                                        "fileURL") // this is usually a QUrl already
                                    crashLogsPopup.viewerFileUrl = url

                                    // Ensure a QUrl is passed to the invokable; wrap strings when necessary
                                    crashTxt.text = Fs.readTextUrl(
                                        typeof url === "string" ? Qt.resolvedUrl(
                                                                      url) : url)

                                    stack.currentIndex = 1
                                }
                            }
                        }
                    }
                }
            }

            // Page 1: Viewer
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    // Container with dark underlay (no Control.background styling)
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        // dark card behind the scroll area
                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: "#0f232b"
                            border.color: "#2f4b57"
                            border.width: 1
                            z: 0
                        }

                        // scrolling text viewer
                        ScrollView {
                            anchors.fill: parent
                            clip: true
                            z: 1

                            // IMPORTANT: do NOT set ScrollView.background on native style
                            TextArea {
                                id: logTextArea
                                readOnly: true
                                wrapMode: TextArea.NoWrap
                                text: crashTxt.text

                                // readable on dark bg
                                color: "#e6f2f8"
                                selectionColor: "#244059"
                                selectedTextColor: "#ffffff"
                                font.family: "monospace"
                                font.pixelSize: 14

                                // transparent, so the dark underlay shows through
                                background: null
                            }
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignRight
                        spacing: 10
                        ThemedButton {
                            text: "Open in Editor"
                            width: 160
                            height: 40
                            font.pixelSize: 16
                            enabled: !!crashLogsPopup.viewerFileUrl
                            onClicked: Qt.openUrlExternally(
                                           crashLogsPopup.viewerFileUrl)
                        }
                    }
                }
            }
        }
    }
}

// Safe content area below the status banner
Item {
    id: safe
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: statusBar.visible ? statusBar.bottom : parent.top // center below the banner
    anchors.bottom: parent.bottom

    // Main layout: centered card with tabbed content
    Column {
        id: mainCol
        anchors.top: parent.top
        anchors.topMargin: 14
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 14

        // TabBar with animated underline
        Item {
            id: tabBox
            anchors.horizontalCenter: parent.horizontalCenter // center horizontally
            // Use the ListView's contentWidth when available so we don't include extra gutters
            width: tabs.contentItem ? tabs.contentItem.contentWidth : tabs.implicitWidth
            implicitWidth: width
            implicitHeight: tabs.implicitHeight

            QtObject {
                id: tabMetrics
                property real maxPainted: 0
                property bool equalize: true
            }

            // underline geometry
            property real ulX: 0
            property real ulW: 0

            TabBar {
                id: tabs
                anchors.horizontalCenter: parent.horizontalCenter
                background: Item {}
                height: 72
                spacing: 32
                leftPadding: 0 // <— kills default left gutter
                rightPadding: 0 // <— kills default right gutter

                StyledTab {
                    text: "Device"
                    metrics: tabMetrics
                }
                StyledTab {
                    text: "Tachometer"
                    metrics: tabMetrics
                }
                StyledTab {
                    text: "Display"
                    metrics: tabMetrics
                }
                StyledTab {
                    text: "Gauges"
                    metrics: tabMetrics
                }
                StyledTab {
                    text: "Performance"
                    metrics: tabMetrics
                }
            }

            Rectangle {
                id: underline
                anchors.bottom: tabs.bottom
                anchors.bottomMargin: 2
                height: 4
                radius: 2
                color: "#ffcc00"
                x: tabBox.ulX
                width: tabBox.ulW
                Behavior on x {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on width {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }
            }

            function updateUnderline() {
                const list = tabs.contentItem
                if (!list)
                    return
                const btn = list.itemAtIndex ? list.itemAtIndex(
                                                   tabs.currentIndex) : null
                if (!btn || !btn.contentItem)
                    return

                const txt = btn.contentItem
                const p = txt.mapToItem(tabBox, 0, 0)
                const glyphW = (txt.paintedWidth
                                && txt.paintedWidth > 0) ? txt.paintedWidth : txt.implicitWidth
                tabBox.ulW = glyphW
                tabBox.ulX = p.x + (txt.width - glyphW) / 2
            }

            Component.onCompleted: tabBox.updateUnderline()
            Connections {
                target: tabs
                function onCurrentIndexChanged() {
                    tabBox.updateUnderline()
                }
            }
            Connections {
                target: tabs
                function onWidthChanged() {
                    tabBox.updateUnderline()
                }
            }
            Connections {
                target: tabs.contentItem
                function onContentWidthChanged() {
                    tabBox.updateUnderline()
                }
            }
            Connections {
                target: neu
                function onStatusChanged() {
                    tabBox.updateUnderline()
                }
            }
            Connections {
                target: tabMetrics
                function onMaxPaintedChanged() {
                    tabBox.updateUnderline()
                }
            }
        }

        // Card container (centered, constrained to viewport)
        Rectangle {
            x: Math.round((svc.width - width) / 2)
            width: Math.min(safe.width - 48, 1480)
            height: Math.min(safe.height - 160, 500)
            radius: 18
            color: "#081418AA"
            clip: true

            StackLayout {
                id: pages
                anchors.fill: parent
                anchors.margins: 22
                currentIndex: tabs.currentIndex

                // Device tab: Bluetooth / ECU connection controls
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Item {
                        anchors.fill: parent

                        // Content centered within the card; horizontal offset allowed
                        Item {
                            id: deviceCenter
                            width: Math.min(parent.width, 900)
                            height: devCol.implicitHeight
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenterOffset: svc.offsetDeviceX

                            Column {
                                id: devCol
                                spacing: 18
                                width: parent.width

                                // Connection state header
                                Row {
                                    spacing: 12
                                    Text {
                                        text: "Device"
                                        font.family: dashFontName()
                                        font.pixelSize: 32
                                        color: "#ffcc00"
                                    }
                                    Rectangle {
                                        radius: 6
                                        height: 32
                                        color: (ecu && ecu.isConnected
                                                && ecu.isConnected(
                                                    )) ? "#0b2a0b" : (ecu
                                                                      && ecu.scanning ? "#2a1b0b" : "#2a0b0b")
                                        width: statusText.implicitWidth + 20
                                        Text {
                                            id: statusText
                                            anchors.centerIn: parent
                                            text: (ecu && ecu.isConnected
                                                   && ecu.isConnected(
                                                       )) ? "CONNECTED" : (ecu
                                                                           && ecu.scanning ? "SCANNING…" : "DISCONNECTED")
                                            color: "#ffcc00"
                                            font.family: dashFontName()
                                            font.pixelSize: 18
                                        }
                                    }
                                }

                                Text {
                                    text: "Windows tip: pair ECUMaster in Bluetooth Settings first, then Connect here."
                                    visible: Qt.platform.os === "windows"
                                             && (!ecu || !ecu.isConnected
                                                 || !ecu.isConnected())
                                    color: "#cccccc"
                                    font.pixelSize: 18
                                }

                                Row {
                                    spacing: 12
                                    ThemedButton {
                                        text: (ecu
                                               && ecu.scanning) ? "Stop Scan" : "Scan for Devices"
                                        width: 240
                                        height: 56
                                        font.pixelSize: 20
                                        onClicked: {
                                            if (!ecu)
                                            return
                                            if (ecu.scanning)
                                            ecu.stopScan()
                                            else
                                            ecu.startScan()
                                        }
                                    }
                                    BusyIndicator {
                                        running: ecu && ecu.scanning
                                        visible: running
                                        width: 32
                                        height: 32
                                    }
                                    ThemedButton {
                                        text: "Refresh"
                                        width: 180
                                        height: 56
                                        font.pixelSize: 20
                                        onClicked: if (ecu)
                                        ecu.startScan()
                                    }
                                }

                                Row {
                                    spacing: 16

                                    // Discovered devices list (left column)
                                    ListView {
                                        id: deviceList
                                        width: 480
                                        height: 220
                                        clip: true
                                        model: ecu ? ecu.devices : []
                                        delegate: ItemDelegate {
                                            width: deviceList.width
                                            text: modelData
                                            font.pixelSize: 20
                                            onClicked: {
                                                deviceTab.selectedDisplay = modelData
                                                const m = /\(([0-9A-Fa-f:]{17})\)/.exec(
                                                    modelData)
                                                deviceTab.selectedAddress = m ? m[1] : ""
                                            }
                                        }
                                        ScrollBar.vertical: ScrollBar {}
                                        Rectangle {
                                            anchors.fill: parent
                                            color: "transparent"
                                            border.color: "#333"
                                            radius: 8
                                        }
                                    }

                                    // Manual address and action controls (right column)
                                    Column {
                                        id: rightCol
                                        spacing: 10
                                        width: 420

                                        // Anchor element used to position the error overlay
                                        Text {
                                            id: btAddrLabel
                                            text: "Bluetooth Address (AA:BB:CC:DD:EE:FF)"
                                            color: "#ddd"
                                            font.pixelSize: 16
                                            // Reposition the overlay when the anchor moves
                                            onYChanged: errorOverlay.reposition(
                                                            )
                                            onXChanged: errorOverlay.reposition(
                                                            )
                                        }

                                        // Touch-friendly address field (opens MAC keypad)
                                        Rectangle {
                                            id: addrDisplay
                                            width: parent.width
                                            height: 52
                                            radius: 8
                                            color: "#0f232b"
                                            border.color: "#2f4b57"
                                            Row {
                                                anchors.fill: parent
                                                anchors.margins: 12
                                                spacing: 10
                                                Text {
                                                    text: deviceTab.selectedAddress.length ? deviceTab.selectedAddress : "Tap to enter"
                                                    color: deviceTab.selectedAddress.length ? "white" : "#7a8b94"
                                                    font.pixelSize: 22
                                                    font.family: dashFontName()
                                                    elide: Text.ElideRight
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                                Item {
                                                    Layout.fillWidth: true
                                                    width: 1
                                                    height: 1
                                                }
                                                Text {
                                                    text: "✎"
                                                    color: "#ffcc00"
                                                    font.pixelSize: 22
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    macPad.value = deviceTab.selectedAddress
                                                    || ""
                                                    macPad.acceptCallback = function (s) {
                                                        deviceTab.selectedAddress = s
                                                        if (ecu)
                                                            ecu.setDeviceAddress(
                                                                        s)
                                                    }
                                                    macPad.visible = true
                                                }
                                            }
                                        }

                                        Row {
                                            spacing: 10
                                            ThemedButton {
                                                text: (ecu && ecu.isConnected
                                                       && ecu.isConnected(
                                                           )) ? "Disconnect" : "Connect"
                                                width: 180
                                                height: 56
                                                font.pixelSize: 20
                                                onClicked: {
                                                    if (!ecu)
                                                    return

                                                    // Validate Bluetooth address before attempting connect
                                                    if (!deviceTab.selectedAddress
                                                        || deviceTab.selectedAddress.length === 0) {
                                                        showError(
                                                            Errors.API.Codes.ADDR_EMPTY)
                                                        return
                                                    }
                                                    if (!/^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$/.test(
                                                            deviceTab.selectedAddress)) {
                                                        showError(
                                                            Errors.API.Codes.ADDR_INVALID,
                                                            {
                                                                "addr": deviceTab.selectedAddress
                                                            })
                                                        return
                                                    }

                                                    if (ecu.isConnected
                                                        && ecu.isConnected()) {
                                                        ecu.disconnectDevice()
                                                    } else {
                                                        ecu.setDeviceAddress(
                                                            deviceTab.selectedAddress)
                                                        ecu.connectToDevice()
                                                    }
                                                }
                                            }
                                            ThemedButton {
                                                text: "Connect Selected"
                                                width: 220
                                                height: 56
                                                font.pixelSize: 20
                                                enabled: deviceTab.selectedDisplay.length > 0
                                                         && (!ecu
                                                             || !ecu.isConnected
                                                             || !ecu.isConnected(
                                                                 ))
                                                onClicked: {
                                                    if (!ecu)
                                                    return
                                                    if (!deviceTab.selectedDisplay
                                                        || deviceTab.selectedDisplay.length === 0) {
                                                        showError(
                                                            Errors.API.Codes.NO_DEVICES_FOUND)
                                                        return
                                                    }
                                                    ecu.connectToName(
                                                        deviceTab.selectedDisplay)
                                                }
                                            }
                                            ThemedButton {
                                                text: "Set Address Only"
                                                width: 220
                                                height: 56
                                                font.pixelSize: 20
                                                enabled: deviceTab.selectedAddress.length > 0
                                                onClicked: if (ecu)
                                                ecu.setDeviceAddress(
                                                    deviceTab.selectedAddress)
                                            }
                                        }

                                        // Numeric preference pickers (modal NumberPad)
                                        Row {
                                            spacing: 14
                                            enabled: (svc.prefs.autoReconnectTries
                                                      ?? 0) > 0
                                            Text {
                                                text: "Max tries"
                                                color: "white"
                                                font.pixelSize: 20
                                            }
                                            ThemedButton {
                                                width: 140
                                                height: 50
                                                font.pixelSize: 20
                                                text: String(
                                                          svc.prefs.autoReconnectTries
                                                          ?? 5)
                                                onClicked: {
                                                    numPad.label = "Max tries"
                                                    numPad.min = 1
                                                    numPad.max = 20
                                                    numPad.step = 1
                                                    numPad.value = svc.prefs.autoReconnectTries
                                                    ?? 5
                                                    numPad.suffix = ""
                                                    numPad.acceptCallback = function (v) {
                                                        svc.prefs.autoReconnectTries = v
                                                    }
                                                    numPad.visible = true
                                                }
                                            }
                                            Text {
                                                text: "Backoff (ms)"
                                                color: "white"
                                                font.pixelSize: 20
                                            }
                                            ThemedButton {
                                                width: 160
                                                height: 50
                                                font.pixelSize: 20
                                                text: String(
                                                          svc.prefs.autoReconnectBackoffMs
                                                          ?? 750) + " ms"
                                                onClicked: {
                                                    numPad.label = "Backoff (ms)"
                                                    numPad.min = 250
                                                    numPad.max = 10000
                                                    numPad.step = 250
                                                    numPad.value = svc.prefs.autoReconnectBackoffMs
                                                    ?? 750
                                                    numPad.suffix = "ms"
                                                    numPad.acceptCallback = function (v) {
                                                        svc.prefs.autoReconnectBackoffMs = v
                                                    }
                                                    numPad.visible = true
                                                }
                                            }
                                        }
                                    }
                                }

                                // RSSI display
                                Text {
                                    text: "RSSI: " + ((ecu && ecu.rssi
                                                       !== undefined) ? ecu.rssi : "—") + " dBm"
                                    color: "#cccccc"
                                    font.pixelSize: 12
                                }

                                // Bottom row: toggle switches
                                Row {
                                    spacing: 14
                                    Text {
                                        text: "Auto-reconnect"
                                        color: "white"
                                        font.pixelSize: 20
                                    }
                                    ThemedSwitch {
                                        checked: (svc.prefs.autoReconnectTries
                                                  ?? 0) > 0
                                        width: 90
                                        height: 50
                                        onToggled: svc.prefs.autoReconnectTries
                                                   = checked ? (svc.prefs.autoReconnectTries
                                                                || 5) : 0
                                    }

                                    Text {
                                        text: "Reconnect on wake"
                                        color: "white"
                                        font.pixelSize: 20
                                    }
                                    ThemedSwitch {
                                        checked: !!(svc.prefs.reconnectOnWake
                                                    ?? true)
                                        width: 90
                                        height: 50
                                        onToggled: svc.prefs.reconnectOnWake = checked
                                    }
                                }

                                // Update deviceTab error state from ECU backend
                                Connections {
                                    target: ecu
                                    function onErrorChanged(msg, code) {
                                        if (replayPopup && replayPopup.visible)
                                            return
                                        var mapped = classifyEcuError(msg, code)
                                        showError(mapped.code, mapped.params,
                                                  mapped.overrideText)
                                        errorOverlay.dismissed = false
                                        errorOverlay.show()
                                    }
                                }

                                // Local compatibility properties
                                property string selectedDisplay: ""
                                property string selectedAddress: ""
                            }

                            // Overlay error banner: auto-measures and wraps (maximum 2 lines)
                            Rectangle {
                                id: errorOverlay
                                z: 300
                                color: "#3a1010"
                                border.color: "#7a3030"
                                radius: 8

                                // Tunable properties for banner layout and font
                                property int pad: 8
                                property int marginY: 6
                                property int maxWidth: 420 // preferred max single-line width (outer, incl. padding)
                                property int fontPx: 16 // font size
                                property string fontFamily: "" // "" = system default, or dashFontName()

                                // Shared font object used for measuring and display
                                property var overlayFont: Qt.font({
                                                                      "pixelSize": fontPx,
                                                                      "family": fontFamily
                                                                  })
                                onFontPxChanged: overlayFont = Qt.font({
                                                                           "pixelSize": fontPx,
                                                                           "family": fontFamily
                                                                       })
                                onFontFamilyChanged: overlayFont = Qt.font({
                                                                               "pixelSize": fontPx,
                                                                               "family": fontFamily
                                                                           })

                                // Internal banner state
                                property bool dismissed: false
                                property int lastSeqHandled: -1

                                // Read-only bindings sourced from deviceTab
                                readonly property string msg: deviceTab.lastError
                                                              || ""
                                readonly property string code: deviceTab.lastErrorCode
                                                               || ""
                                readonly property int seq: deviceTab.errorSeq
                                                           || 0

                                function fmtCode(c) {
                                    if (c === undefined || c === null
                                            || c === "")
                                        return ""
                                    if (typeof c === "number")
                                        return "0x" + c.toString(
                                                    16).toUpperCase()
                                    const s = String(c).trim()
                                    if (/^0x[0-9a-f]+$/i.test(s))
                                        return s.toUpperCase()
                                    if (/^\d+$/.test(s))
                                        return "0x" + Number(s).toString(
                                                    16).toUpperCase()
                                    return s
                                }

                                function show() {
                                    dismissed = false
                                    opacity = 1
                                    visible = true
                                    lastSeqHandled = seq
                                    Qt.callLater(reposition) // ensure polished before measuring
                                }

                                visible: (msg.length > 0) && !dismissed
                                opacity: visible ? 1 : 0
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 160
                                    }
                                }

                                // Hidden text item used to measure single-line width
                                Text {
                                    id: errMeasure
                                    visible: false
                                    text: (errorOverlay.code.length ? ("[" + errorOverlay.fmtCode(
                                                                           errorOverlay.code) + "] ") : "") + errorOverlay.msg
                                    font: errorOverlay.overlayFont
                                    wrapMode: Text.NoWrap
                                    onTextChanged: Qt.callLater(
                                                       errorOverlay.reposition)
                                }

                                // Hidden probe used to compute wrapped heights (up to two lines)
                                Text {
                                    id: errProbe
                                    visible: false
                                    text: errMeasure.text
                                    font: errorOverlay.overlayFont
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                    elide: Text.ElideNone
                                    width: 0
                                }

                                // Visible banner text item
                                Text {
                                    id: errText
                                    anchors.margins: errorOverlay.pad
                                    anchors.left: parent.left
                                    anchors.top: parent.top

                                    text: errMeasure.text
                                    color: "#ffaaaa"
                                    font: errorOverlay.overlayFont

                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                    elide: Text.ElideNone
                                    verticalAlignment: Text.AlignVCenter

                                    width: Math.max(
                                               0,
                                               errorOverlay.width - errorOverlay.pad * 2)

                                    onImplicitWidthChanged: errorOverlay.reposition()
                                    onImplicitHeightChanged: errorOverlay.reposition()
                                }

                                function reposition() {
                                    if (!btAddrLabel || !deviceCenter)
                                        return

                                    const pad2 = errorOverlay.pad * 2
                                    const minW = 200

                                    // 1) Compute natural single-line width
                                    const singleLineOuter = Math.ceil(
                                                              errMeasure.paintedWidth) + pad2

                                    // 2) Use single-line if it fits maxWidth
                                    if (singleLineOuter <= errorOverlay.maxWidth) {
                                        errorOverlay.width = Math.max(
                                                    minW, singleLineOuter)
                                        // Set banner height to the measured single-line height
                                        errProbe.width = Math.max(
                                                    0,
                                                    errorOverlay.width - pad2)
                                        errorOverlay.height = errProbe.implicitHeight + pad2
                                    } else {
                                        // 3) Otherwise, allow up to two lines at maxWidth and adjust height accordingly
                                        //    widen until the text fits within two lines.
                                        const twoLineTargetH = (function () {
                                            // Give probe a huge width to get 1 line height, then double it.
                                            errProbe.width = 9999
                                            const oneLineH = errProbe.implicitHeight
                                            return oneLineH * 2 + (0) // already excludes padding
                                        })()

                                        // Binary-search for the narrowest width that keeps
                                        // the wrapped height at or below two lines.
                                        let lo = Math.max(minW,
                                                          errorOverlay.maxWidth)
                                        let hi = Math.max(lo, singleLineOuter)
                                        let best = hi
                                        for (var i = 0; i < 14; ++i) {
                                            const mid = Math.round(
                                                          (lo + hi) / 2)
                                            errProbe.width = Math.max(
                                                        0, mid - pad2)
                                            const h = errProbe.implicitHeight
                                            if (h <= twoLineTargetH) {
                                                best = mid
                                                hi = mid - 1
                                            } else {
                                                lo = mid + 1
                                            }
                                        }

                                        errorOverlay.width = best
                                        errProbe.width = Math.max(
                                                    0,
                                                    errorOverlay.width - pad2)
                                        errorOverlay.height = errProbe.implicitHeight + pad2
                                    }

                                    // Position the banner above the Bluetooth address label
                                    const p = btAddrLabel.mapToItem(
                                                deviceCenter, 0, 0)
                                    errorOverlay.x = p.x
                                    errorOverlay.y = p.y - errorOverlay.height
                                            - errorOverlay.marginY
                                }

                                Component.onCompleted: Qt.callLater(reposition)
                                onWidthChanged: reposition()
                                onHeightChanged: reposition()
                                Connections {
                                    target: btAddrLabel
                                    function onXChanged() {
                                        errorOverlay.reposition()
                                    }
                                }
                                Connections {
                                    target: btAddrLabel
                                    function onYChanged() {
                                        errorOverlay.reposition()
                                    }
                                }
                                Connections {
                                    target: deviceCenter
                                    function onXChanged() {
                                        errorOverlay.reposition()
                                    }
                                }
                                Connections {
                                    target: deviceCenter
                                    function onYChanged() {
                                        errorOverlay.reposition()
                                    }
                                }
                                Connections {
                                    target: deviceCenter
                                    function onWidthChanged() {
                                        errorOverlay.reposition()
                                    }
                                }
                                Connections {
                                    target: deviceCenter
                                    function onHeightChanged() {
                                        errorOverlay.reposition()
                                    }
                                }
                                Connections {
                                    target: deviceTab
                                    function onLastErrorChanged() {
                                        Qt.callLater(errorOverlay.reposition)
                                    }
                                    function onLastErrorCodeChanged() {
                                        Qt.callLater(errorOverlay.reposition)
                                    }
                                    function onErrorSeqChanged() {
                                        Qt.callLater(errorOverlay.reposition)
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        errorOverlay.dismissed = true
                                        errorOverlay.opacity = 0
                                    }
                                }
                            }
                            // End overlay error banner
                        }
                    }
                }

                // Tachometer tab: shift light / redline settings
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Item {
                        anchors.fill: parent

                        Item {
                            width: 600
                            height: tachCol.implicitHeight
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenterOffset: svc.offsetTachX

                            Column {
                                id: tachCol
                                spacing: 18
                                width: parent.width

                                Row {
                                    spacing: 16
                                    Label {
                                        text: "Redline flash"
                                        color: "white"
                                        font.pixelSize: 22
                                    }
                                    ThemedSwitch {
                                        checked: svc.prefs.ovEnable ?? true
                                        width: 90
                                        height: 50
                                        onToggled: svc.prefs.ovEnable = checked
                                    }
                                }

                                Label {
                                    text: "Shift Light: " + (svc.prefs.shiftShowThreshold
                                                             ?? 5500)
                                    color: "white"
                                    font.pixelSize: 22
                                }
                                ThemedSlider {
                                    from: 2000
                                    to: (svc.prefs.rpmMax ?? 8000)
                                    stepSize: 100
                                    value: svc.prefs.shiftShowThreshold ?? 5500
                                    height: 36
                                    width: 380
                                    onValueChanged: svc.prefs.shiftShowThreshold = Math.round(
                                                        value)
                                }

                                Label {
                                    text: "Shift Blink: " + (svc.prefs.shiftBlinkThreshold
                                                             ?? 6500)
                                    color: "white"
                                    font.pixelSize: 22
                                }
                                ThemedSlider {
                                    from: 2000
                                    to: (svc.prefs.rpmMax ?? 8000)
                                    stepSize: 100
                                    value: svc.prefs.shiftBlinkThreshold ?? 6500
                                    height: 36
                                    width: 380
                                    onValueChanged: svc.prefs.shiftBlinkThreshold = Math.round(
                                                        value)
                                }

                                Label {
                                    text: "Redline Start: " + (svc.prefs.overRevThreshold
                                                               ?? 7200)
                                    color: "white"
                                    font.pixelSize: 22
                                }
                                ThemedSlider {
                                    from: 4000
                                    to: (svc.prefs.rpmMax ?? 8000)
                                    stepSize: 100
                                    value: svc.prefs.overRevThreshold ?? 7200
                                    height: 36
                                    width: 380
                                    onValueChanged: svc.prefs.overRevThreshold = Math.round(
                                                        value)
                                }
                            }
                        }
                    }
                }

                // Display tab: units, brightness, clock, night mode
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Item {
                        anchors.fill: parent

                        Item {
                            width: 620
                            height: dispCol.implicitHeight
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenterOffset: svc.offsetDisplayX

                            Column {
                                id: dispCol
                                spacing: 18
                                width: parent.width

                                Row {
                                    spacing: 16
                                    Label {
                                        text: "Units:"
                                        color: "white"
                                        font.pixelSize: 22
                                    }
                                    ThemedSwitch {
                                        id: units
                                        checked: svc.prefs.useMph ?? true
                                        width: 90
                                        height: 50
                                        onToggled: {
                                            svc.prefs.useMph = checked
                                            if (svc.dashController
                                                && svc.dashController.setUseMph)
                                            svc.dashController.setUseMph(
                                                checked)
                                        }
                                    }
                                    Label {
                                        text: units.checked ? "mph" : "km/h"
                                        color: "white"
                                        font.pixelSize: 22
                                    }
                                }

                                Row {
                                    spacing: 16
                                    Label {
                                        text: "Intro on boot"
                                        color: "white"
                                        font.pixelSize: 22
                                    }
                                    ThemedSwitch {
                                        checked: svc.prefs.introEnable ?? true
                                        width: 90
                                        height: 50
                                        onToggled: svc.prefs.introEnable = checked
                                    }
                                }

                                Row {
                                    spacing: 16
                                    Label {
                                        text: "Clock format"
                                        color: "white"
                                        font.pixelSize: 22
                                    }
                                    ComboBox {
                                        id: clockFmt
                                        model: ["12-hour", "24-hour"]
                                        currentIndex: (svc.prefs.clock24 ? 1 : 0)
                                        onActivated: svc.prefs.clock24 = (currentIndex === 1)
                                        width: 220
                                        height: 50
                                        font.pixelSize: 20
                                    }
                                }

                                Row {
                                    spacing: 14
                                    Label {
                                        text: "Brightness "
                                        color: "white"
                                        font.pixelSize: 22
                                    }
                                    ThemedSlider {
                                        from: 0.05
                                        to: 1
                                        stepSize: 0.05
                                        value: svc.prefs.brightness ?? 1
                                        width: 380
                                        height: 36
                                        onValueChanged: svc.prefs.brightness = value
                                    }
                                    Label {
                                        text: Math.round((svc.prefs.brightness
                                                          ?? 1) * 100) + "%"
                                        color: "white"
                                        font.pixelSize: 22
                                    }
                                }

                                // Night dimming schedule: pick start/end times
                                Row {
                                    spacing: 16
                                    Text {
                                        text: "Night dimming"
                                        color: "white"
                                        font.pixelSize: 22
                                    }
                                    ThemedSwitch {
                                        id: night
                                        checked: !!(svc.prefs.nightStart
                                                    || svc.prefs.nightEnd)
                                        width: 90
                                        height: 50
                                        onToggled: {
                                            if (!checked) {
                                                svc.prefs.nightStart = ""
                                                svc.prefs.nightEnd = ""
                                            } else {
                                                if (!svc.prefs.nightStart)
                                                svc.prefs.nightStart = "19:00"
                                                if (!svc.prefs.nightEnd)
                                                svc.prefs.nightEnd = "06:30"
                                            }
                                        }
                                    }
                                }

                                Row {
                                    spacing: 14
                                    enabled: night.checked
                                    ThemedButton {
                                        text: "From: " + (svc.prefs.nightStart
                                                          || "--:--")
                                        width: 220
                                        height: 56
                                        font.pixelSize: 20
                                        onClicked: {
                                            const s = svc.prefs.nightStart
                                            || "19:00"
                                            timePad.label = "Night Start"
                                            timePad.hour = parseInt(
                                                s.split(":")[0]) || 19
                                            timePad.minute = parseInt(
                                                s.split(":")[1]) || 0
                                            timePad.acceptCallback = function (v) {
                                                svc.prefs.nightStart = v
                                            }
                                            timePad.visible = true
                                        }
                                    }
                                    ThemedButton {
                                        text: "To: " + (svc.prefs.nightEnd
                                                        || "--:--")
                                        width: 220
                                        height: 56
                                        font.pixelSize: 20
                                        onClicked: {
                                            const s = svc.prefs.nightEnd
                                            || "06:30"
                                            timePad.label = "Night End"
                                            timePad.hour = parseInt(
                                                s.split(":")[0]) || 6
                                            timePad.minute = parseInt(
                                                s.split(":")[1]) || 30
                                            timePad.acceptCallback = function (v) {
                                                svc.prefs.nightEnd = v
                                            }
                                            timePad.visible = true
                                        }
                                    }
                                }

                                // Nighttime brightness control
                                Row {
                                    spacing: 14
                                    enabled: night.checked
                                    Text {
                                        text: "Night Brightness "
                                        color: "white"
                                        font.pixelSize: 22
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    ThemedSlider {
                                        from: 0.05
                                        to: 1
                                        stepSize: 0.05
                                        value: svc.prefs.brightnessNight ?? 0.35
                                        width: 380
                                        height: 36
                                        onValueChanged: svc.prefs.brightnessNight = value
                                    }
                                    Text {
                                        text: (!!(svc.prefs.nightStart
                                                  || svc.prefs.nightEnd) ? Math.round((svc.prefs.brightnessNight ?? 0.35) * 100) + "%" : "")
                                        color: "white"
                                        font.pixelSize: 22
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }
                    }
                }

                // Gauges tab: smoothing and anti burn-in options
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Item {
                        anchors.fill: parent

                        Item {
                            width: 600
                            height: gaugesCol.implicitHeight
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenterOffset: svc.offsetGaugesX

                            Column {
                                id: gaugesCol
                                spacing: 18
                                width: parent.width

                                Text {
                                    text: "Smoothing factor (0% = instant, 100% = very slow)"
                                    color: "#b8c7d3"
                                    font.pixelSize: 18
                                }

                                Row {
                                    spacing: 16
                                    Text {
                                        text: "RPM"
                                        color: "white"
                                        width: 120
                                        font.pixelSize: 22
                                    }
                                    ThemedSlider {
                                        from: 0
                                        to: 1
                                        stepSize: 0.05
                                        width: 380
                                        height: 36
                                        value: svc.prefs.smoothRpm ?? 0.30
                                        onValueChanged: svc.prefs.smoothRpm = value
                                    }
                                    Text {
                                        text: Math.round((svc.prefs.smoothRpm
                                                          ?? 0.30) * 100) + "%"
                                        color: "#9fb0bd"
                                        width: 70
                                        font.pixelSize: 22
                                    }
                                }
                                Row {
                                    spacing: 16
                                    Text {
                                        text: "Coolant"
                                        color: "white"
                                        width: 120
                                        font.pixelSize: 22
                                    }
                                    ThemedSlider {
                                        from: 0
                                        to: 1
                                        stepSize: 0.05
                                        width: 380
                                        height: 36
                                        value: svc.prefs.smoothClt ?? 0.30
                                        onValueChanged: svc.prefs.smoothClt = value
                                    }
                                    Text {
                                        text: Math.round((svc.prefs.smoothClt
                                                          ?? 0.30) * 100) + "%"
                                        color: "#9fb0bd"
                                        width: 70
                                        font.pixelSize: 22
                                    }
                                }
                                Row {
                                    spacing: 16
                                    Text {
                                        text: "IAT"
                                        color: "white"
                                        width: 120
                                        font.pixelSize: 22
                                    }
                                    ThemedSlider {
                                        from: 0
                                        to: 1
                                        stepSize: 0.05
                                        width: 380
                                        height: 36
                                        value: svc.prefs.smoothIat ?? 0.30
                                        onValueChanged: svc.prefs.smoothIat = value
                                    }
                                    Text {
                                        text: Math.round((svc.prefs.smoothIat
                                                          ?? 0.30) * 100) + "%"
                                        color: "#9fb0bd"
                                        width: 70
                                        font.pixelSize: 22
                                    }
                                }
                                Row {
                                    spacing: 16
                                    Text {
                                        text: "AFR"
                                        color: "white"
                                        width: 120
                                        font.pixelSize: 22
                                    }
                                    ThemedSlider {
                                        from: 0
                                        to: 1
                                        stepSize: 0.05
                                        width: 380
                                        height: 36
                                        value: svc.prefs.smoothAfr ?? 0.30
                                        onValueChanged: svc.prefs.smoothAfr = value
                                    }
                                    Text {
                                        text: Math.round((svc.prefs.smoothAfr
                                                          ?? 0.30) * 100) + "%"
                                        color: "#9fb0bd"
                                        width: 70
                                        font.pixelSize: 22
                                    }
                                }
                                Row {
                                    spacing: 16
                                    Text {
                                        text: "Battery"
                                        color: "white"
                                        width: 120
                                        font.pixelSize: 22
                                    }
                                    ThemedSlider {
                                        from: 0
                                        to: 1
                                        stepSize: 0.05
                                        width: 380
                                        height: 36
                                        value: svc.prefs.smoothVbat ?? 0.30
                                        onValueChanged: svc.prefs.smoothVbat = value
                                    }
                                    Text {
                                        text: Math.round((svc.prefs.smoothVbat
                                                          ?? 0.30) * 100) + "%"
                                        color: "#9fb0bd"
                                        width: 70
                                        font.pixelSize: 22
                                    }
                                }

                                Row {
                                    spacing: 16
                                    Text {
                                        text: "Anti burn-in nudge"
                                        color: "white"
                                        font.pixelSize: 22
                                    }
                                    ThemedSwitch {
                                        checked: !!(svc.prefs.nudgeAntiBurn
                                                    ?? false)
                                        width: 90
                                        height: 50
                                        onToggled: svc.prefs.nudgeAntiBurn = checked
                                    }
                                }
                            }
                        }
                    }
                }

                // Performance tab: logging, replays, crash logs, trip reset
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Item {
                        anchors.fill: parent

                        Item {
                            width: 600
                            height: perfCol.implicitHeight
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenterOffset: svc.offsetPerfX

                            Column {
                                id: perfCol
                                spacing: 18
                                width: parent.width

                                Row {
                                    spacing: 16
                                    Text {
                                        text: "Keep best 0–60"
                                        color: "white"
                                        font.pixelSize: 22
                                    }
                                    ThemedSwitch {
                                        checked: !!(svc.prefs.keepZ60 ?? true)
                                        width: 90
                                        height: 50
                                        onToggled: svc.prefs.keepZ60 = checked
                                    }
                                }

                                Row {
                                    spacing: 16
                                    Text {
                                        text: "Session logging"
                                        color: "white"
                                        font.pixelSize: 22
                                    }
                                    ThemedSwitch {
                                        checked: !!(svc.prefs.loggingEnabled
                                                    ?? false)
                                        width: 90
                                        height: 50
                                        onToggled: svc.prefs.loggingEnabled = checked
                                    }
                                }
                                // Replays controls
                                Row {
                                    spacing: 16
                                    Text {
                                        text: "Replays"
                                        color: "white"
                                        font.pixelSize: 22
                                    }
                                    ThemedButton {
                                        text: "Open Replay Browser…"
                                        width: 260
                                        height: 56
                                        font.pixelSize: 20
                                        onClicked: replayPopup.open()
                                    }
                                }

                                Row {
                                    spacing: 16
                                    Text {
                                        text: "Crash logs"
                                        color: "white"
                                        font.pixelSize: 22
                                    }
                                    ThemedButton {
                                        text: "Browse…"
                                        width: 220
                                        height: 56
                                        font.pixelSize: 20
                                        onClicked: crashLogsPopup.open()
                                    }
                                }

                                HoldButton {
                                    label: "Hold to Reset Trip"
                                    holdMs: 1200
                                    onActivated: {
                                        if (svc.dashController
                                            && svc.dashController.resetTrip)
                                        svc.dashController.resetTrip()
                                        if (svc.prefs)
                                        svc.prefs.tripBackupKm = 0
                                    }
                                }
                            }
                        }
                    }
                }
            } // StackLayout
        } // Card
    } // Column
} // Item

// Close hotspot (kept for your exit gesture)
Rectangle {
    id: closeHotspot
    x: 1130
    y: 635
    width: 300
    height: 80
    radius: 12
    z: 2000
    color: "#ffffff"
    opacity: 0
    border.color: "#ffffff"
    border.width: 1
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: svc.done()
    }
}

// Keep deviceTab object for compatibility with code above
QtObject {
    id: deviceTab
    property string selectedDisplay: ""
    property string selectedAddress: ""
    property string lastError: ""
    property string lastErrorCode: ""
    property int errorSeq: 0
}
}
