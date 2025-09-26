// pages/ReplayPage.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../scripts/LogParser.js" as LP
import "qrc:/KeyDash_NX1000/pages" as Pages   // <-- your DashboardPage import

Page {
    id: page
    title: "Replay"

    // passed in from Main.qml
    required property var dashController
    required property var prefs
    property url initialSource: ""
    property bool autoPlay: true

    // state
    property var lastFrame: ({ t:0, rpm:0, map:0, tps:0, clt:0, iat:0, afr:0, batt:0 })

    // ============== 1) Local container so overlay can anchor to a sibling ==============
    Item {
        id: stage
        anchors.fill: parent

        // ---- Your actual dashboard, full screen ----
        Pages.DashboardPage {
            id: dash
            anchors.fill: parent
            skipIntro: true            // <-- just assign; no 'property' keyword
            prefs: page.prefs
            dashController: page.dashController
        }

        // Show/hide overlay with a tap anywhere on the dash
        TapHandler {
            target: null
            onTapped: overlay.visible = !overlay.visible
        }

        // ---- Transport overlay (bottom, full width, auto height) ----
        Rectangle {
            id: overlay
            anchors {
                left: stage.left; right: stage.right; bottom: stage.bottom
                leftMargin: 12; rightMargin: 12; bottomMargin: 12
            }
            radius: 14
            color: "#0b151acc"
            z: 100000
            implicitHeight: overlayCol.implicitHeight + 24
            visible: true
            opacity: visible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

            readonly property bool atEnd: replay.duration > 0 && replay.position >= replay.duration - 0.001
            property bool pinned: false       // <-- define since you reference it later
            property bool fingerDown: false   // <-- DragHandler touches this

            ColumnLayout {
                id: overlayCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                // Single header row: centered controls + right-aligned Close
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    // Centering container takes all width
                    Item {
                        Layout.fillWidth: true
                        // Center the control cluster inside this item
                        Row {
                            id: controlCluster
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 10

                            // Play / Pause / Restart
                            Button {
                                id: playBtn
                                text: replay.playing ? "Pause" : (overlay.atEnd ? "Restart" : "Play")
                                implicitWidth: 140; implicitHeight: 64
                                font.pixelSize: 22
                                enabled: replay.duration > 0
                                onClicked: {
                                    if (replay.playing) replay.pause()
                                    else {
                                        if (overlay.atEnd) replay.seek(0)
                                        replay.play()
                                    }
                                }
                            }
                            Button {
                                text: "Stop"
                                implicitWidth: 120; implicitHeight: 64
                                font.pixelSize: 22
                                enabled: replay.duration > 0
                                onClicked: { replay.stop(); overlay.visible = true }
                            }

                            // Speed chips
                            Row {
                                spacing: 8
                                Repeater {
                                    model: [0.5, 1, 2, 4]
                                    delegate: Button {
                                        text: modelData + "×"
                                        checkable: true
                                        checked: Number(replay.speed) === Number(modelData)
                                        implicitWidth: 88; implicitHeight: 56
                                        font.pixelSize: 20
                                        onClicked: replay.speed = Number(modelData)
                                    }
                                }
                            }

                            // Time readout
                            Rectangle {
                                radius: 8; color: "#10212a"; border.color: "#28424d"
                                implicitHeight: 56; implicitWidth: timeCol.implicitWidth + 20
                                Column {
                                    id: timeCol
                                    anchors.centerIn: parent; spacing: 0
                                    Text {
                                        text: (replay.position.toFixed(1) + " / " + Math.max(0, replay.duration).toFixed(1) + " s")
                                        color: "white"; font.pixelSize: 22
                                    }
                                    Text {
                                        text: replay.playing ? (replay.speed + "×") : "paused"
                                        color: "#9fb0bd"; font.pixelSize: 14
                                        horizontalAlignment: Text.AlignHCenter
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                    }

                    // Close button stays on the far right
                    Button {
                        text: "Close"
                        implicitWidth: 120; implicitHeight: 64
                        font.pixelSize: 22
                        Layout.alignment: Qt.AlignRight
                        onClicked: page.StackView.view ? page.StackView.view.pop() : 0
                    }
                }

                // Scrub bar: duration-scaled width, centered, big touch targets
                RowLayout {
                    Layout.fillWidth: true

                    // left spacer
                    Item { Layout.fillWidth: true }

                    // centered cell holds the actual bar (fixed width)
                    Item {
                        // This is the visible bar container
                        id: scrub
                        // ---- sizing knobs ----
                        property real pxPerSecond: 6
                        property real minBar: 320
                        property real maxBar: Math.min(overlay.width - 48, 1200)

                        readonly property real desired: Math.max(0, Number(replay.duration) || 0) * pxPerSecond
                        width: Math.max(minBar, Math.min(maxBar, desired))
                        height: 56

                        // tell the RowLayout how big this cell is
                        implicitWidth: width
                        implicitHeight: height

                        // background track
                        Rectangle {
                            id: track
                            anchors.verticalCenter: parent.verticalCenter
                            x: 0
                            width: scrub.width
                            height: 14
                            radius: 7
                            color: "#163041"
                        }

                        // progress fill
                        Rectangle {
                            id: fill
                            anchors.verticalCenter: track.verticalCenter
                            x: track.x
                            height: track.height
                            radius: track.radius
                            width: Math.round(track.width * (replay.duration > 0 ? replay.position / replay.duration : 0))
                            color: "#ffcc00"
                        }

                        // thumb (big)
                        Rectangle {
                            id: thumb
                            width: 28; height: 28; radius: 14
                            color: "#ffcc00"; border.color: "#604b00"
                            anchors.verticalCenter: track.verticalCenter
                            x: Math.max(track.x - width/2,
                                        Math.min(track.x + track.width - width/2, fill.x + fill.width - width/2))
                        }

                        // Pointer handling (tap + drag)
                        MouseArea {
                            anchors.fill: parent
                            onPressed:  overlay.fingerDown = true
                            onReleased: overlay.fingerDown = false

                            function seekFromX(xLocal) {
                                const v = Math.max(0, Math.min(1, (xLocal - track.x) / track.width))
                                replay.seek(v * Math.max(0, replay.duration))
                            }
                            onClicked: (mouse) => seekFromX(mouse.x)
                            onPositionChanged: (mouse) => { if (pressed) seekFromX(mouse.x) }
                        }
                    }

                    // right spacer
                    Item { Layout.fillWidth: true }
                }

            }
        }
    }

    // ============== 3) Replayer engine (headless) ==============
    LogReplayController {
        id: replay

        // 3A) Push every parsed frame into DashModel (robust field mapping)
        onFrameAdvanced: (f) => {
            lastFrame = f

            if (!page.dashController)
                return

            // --- tolerant column mapping (handles mph/kph/speed, map/boost, batt/vbat, etc.) ---
            const rpm   = (f.rpm   !== undefined) ? Number(f.rpm)   : 0
            const mph   = (function(){
                if (f.mph  !== undefined) return Number(f.mph)
                if (f.speed!== undefined) return Number(f.speed)            // already in mph in your fake log
                if (f.kph  !== undefined) return Number(f.kph) / 1.60934    // convert
                if (f.kmh  !== undefined) return Number(f.kmh) / 1.60934
                return 0
            })()
            const boost = (function(){
                if (f.boost !== undefined) return Number(f.boost)
                if (f.map   !== undefined) return Number(f.map) - 14.7       // crude: MAP(psia) - 14.7 ≈ boost psi
                return 0
            })()
            const clt   = (f.clt   !== undefined) ? Number(f.clt)
                        : (f.coolant !== undefined) ? Number(f.coolant) : NaN
            const iat   = (f.iat   !== undefined) ? Number(f.iat)
                        : (f.mat    !== undefined) ? Number(f.mat)    : NaN
            const vbat  = (f.vbat  !== undefined) ? Number(f.vbat)
                        : (f.batt   !== undefined) ? Number(f.batt)   : NaN
            const afr   = (function(){
                if (f.afr     !== undefined) return Number(f.afr)
                if (f.lambda  !== undefined) return Number(f.lambda) * 14.7
                return NaN
            })()
            const gear  = (f.gear  !== undefined) ? parseInt(f.gear, 10) : -1

            // 3B) Feed the model
            if (page.dashController.applySample) {
                // one-shot helper you already exposed in DashModel
                page.dashController.applySample(rpm, mph, boost, clt, iat, vbat, afr, gear)
            } else {
                // fallback: call individual setters (safe-guarded)
                if (page.dashController.setRpm)     page.dashController.setRpm(rpm)
                if (page.dashController.setSpeed)   page.dashController.setSpeed(mph)
                if (page.dashController.setBoost && !Number.isNaN(boost)) page.dashController.setBoost(boost)
                if (page.dashController.setClt   && !Number.isNaN(clt))   page.dashController.setClt(clt)
                if (page.dashController.setIat   && !Number.isNaN(iat))   page.dashController.setIat(iat)
                if (page.dashController.setVbat  && !Number.isNaN(vbat))  page.dashController.setVbat(vbat)
                if (page.dashController.setAfr   && !Number.isNaN(afr))   page.dashController.setAfr(afr)
                if (page.dashController.setGear)  page.dashController.setGear(gear)
            }
        }

        // 3C) Pause live inputs while replaying (optional niceties)
        onLoaded: {
            if (page.dashController && page.dashController.setReplayMode)
                page.dashController.setReplayMode(true)

            // make sure UI units match settings while replaying
            if (page.dashController && page.dashController.setUseMph)
                page.dashController.setUseMph(!!page.prefs.useMph)

            replay.seek(0)
        }
        onEnded: {
            if (page.dashController && page.dashController.setReplayMode)
                page.dashController.setReplayMode(false)
            overlay.visible = true
        }
    }

    Component.onCompleted: {
            if (initialSource && String(initialSource).length) {
                replay.sourceUrl = initialSource
                replay.load()
                if (autoPlay) replay.play()   // <-- obey the flag
            }
        }
}
