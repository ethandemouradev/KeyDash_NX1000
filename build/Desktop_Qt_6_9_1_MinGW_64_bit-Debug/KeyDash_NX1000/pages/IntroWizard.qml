import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: wizard
    signal finished()
    required property var prefs
    required property var theme   // primaryColor, secondaryColor, bgStart, bgEnd

    // ---- Touch constants ----
    readonly property int  fontXL: 22
    readonly property int  fontLG: 20
    readonly property int  fontMD: 18
    readonly property int  ctlH:   52
    readonly property int  btnH:   56
    readonly property int  cardW:  680
    readonly property color textColor: "white"

    function withAlpha(col, a) { return Qt.rgba(col.r, col.g, col.b, a) }

    // Global dimmer overlay for night brightness adjustments (0..100)
    Rectangle {
        anchors.fill: parent
        color: "black"
        // avoid nullish-coalescing (??) – use a safe ternary
        property real targetB: (typeof bright !== "undefined" ? (bright.value / 100.0) : 1.0)
        opacity: Math.max(0, Math.min(1, 1.0 - targetB))
        z: 99999
        visible: opacity > 0
    }

    // ---------- Background ----------
    Canvas {
        id: mainBg
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d")
            const w = width, h = height
            const g = ctx.createLinearGradient(0, 0, w, 0)
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
        Connections { target: theme; function onBgStartChanged(){ mainBg.requestPaint() } function onBgEndChanged(){ mainBg.requestPaint() } }
    }

    // ---------- POPUPS ----------
    // 1) Alpha (letters) for Badge
    Component {
        id: alphaPadComp
        Popup {
            id: pad
            modal: true; focus: true; dim: true
            anchors.centerIn: Overlay.overlay
            width: 720; height: 500   // taller so Space/Backspace/Clear/Done are visible
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
            property var targetField: null
            background: Rectangle { radius: 20; color: withAlpha(theme.bgStart, 0.92); border.color: withAlpha(theme.secondaryColor, 0.65); border.width: 1 }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                TextField {
                    id: preview
                    Layout.fillWidth: true
                    implicitHeight: ctlH
                    text: pad.targetField ? pad.targetField.text : ""
                    color: textColor
                    font.pixelSize: fontLG
                    placeholderTextColor: withAlpha(textColor, 0.5)
                    background: Rectangle { radius: 12; color: withAlpha(theme.bgEnd, 0.55); border.color: withAlpha(theme.primaryColor, 0.45) }
                }

                ColumnLayout {
                    spacing: 8
                    Component {
                        id: keyBtn
                        Button {
                            text: modelData
                            Layout.preferredHeight: btnH
                            Layout.preferredWidth: (modelData === "Space") ? 300 : 60
                            background: Rectangle { radius: 12; color: withAlpha(theme.bgEnd, 0.6); border.color: withAlpha(theme.secondaryColor, 0.35) }
                            contentItem: Text { text: parent.text; color: textColor; font.pixelSize: fontLG; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: {
                                if (text === "⌫") preview.text = preview.text.slice(0, -1)
                                else if (text === "Space") preview.text += " "
                                else preview.text += text
                            }
                        }
                    }
                    RowLayout { spacing: 8; Repeater { model: ["1","2","3","4","5","6","7","8","9","0"]; delegate: keyBtn } }
                    RowLayout { spacing: 8; Repeater { model: ["Q","W","E","R","T","Y","U","I","O","P"]; delegate: keyBtn } }
                    RowLayout { spacing: 8; Repeater { model: ["A","S","D","F","G","H","J","K","L"]; delegate: keyBtn } }
                    RowLayout { spacing: 8; Repeater { model: ["Z","X","C","V","B","N","M",".","-"]; delegate: keyBtn } }
                    RowLayout { spacing: 8; Repeater { model: ["Space","⌫"]; delegate: keyBtn } }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 12
                    Button {
                        text: "Clear"
                        Layout.preferredHeight: btnH
                        background: Rectangle { radius: 12; color: withAlpha(theme.bgEnd, 0.6); border.color: withAlpha(theme.secondaryColor, 0.35) }
                        contentItem: Text { text: parent.text; color: textColor; font.pixelSize: fontLG; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: preview.text = ""
                    }
                    Button {
                        text: "Done"
                        Layout.preferredHeight: btnH
                        background: Rectangle { radius: 12; color: theme.primaryColor; border.color: withAlpha(theme.secondaryColor, 0.6) }
                        contentItem: Text { text: parent.text; color: "black"; font.bold: true; font.pixelSize: fontLG; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: { if (pad.targetField) pad.targetField.text = preview.text; pad.close() }
                    }
                }
            }
        }
    }

    // 2) Numeric keypad for odometer + ratios
    Component {
        id: numPadComp
        Popup {
            id: np
            modal: true; focus: true; dim: true
            anchors.centerIn: Overlay.overlay
            width: 380; height: 520
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
            property var targetField: null
            background: Rectangle { radius: 20; color: withAlpha(theme.bgStart, 0.92); border.color: withAlpha(theme.secondaryColor, 0.65); border.width: 1 }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                TextField {
                    id: npPreview
                    Layout.fillWidth: true
                    implicitHeight: ctlH
                    text: np.targetField ? np.targetField.text : ""
                    color: textColor; font.pixelSize: fontLG
                    placeholderTextColor: withAlpha(textColor, 0.5)
                    background: Rectangle { radius: 12; color: withAlpha(theme.bgEnd, 0.55); border.color: withAlpha(theme.primaryColor, 0.45) }
                }
                GridLayout {
                    columns: 3; rowSpacing: 10; columnSpacing: 10
                    Repeater {
                        model: ["7","8","9","4","5","6","1","2","3",".","0","⌫"]
                        delegate: Button {
                            text: modelData
                            Layout.preferredWidth: 106
                            Layout.preferredHeight: btnH
                            background: Rectangle { radius: 12; color: withAlpha(theme.bgEnd, 0.6); border.color: withAlpha(theme.secondaryColor, 0.35) }
                            contentItem: Text { text: parent.text; color: textColor; font.pixelSize: fontLG; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: {
                                if (text === "⌫") npPreview.text = npPreview.text.slice(0, -1)
                                else npPreview.text += text
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignRight; spacing: 12
                    Button {
                        text: "Clear"; Layout.preferredHeight: btnH
                        background: Rectangle { radius: 12; color: withAlpha(theme.bgEnd, 0.6); border.color: withAlpha(theme.secondaryColor, 0.35) }
                        contentItem: Text { text: parent.text; color: textColor; font.pixelSize: fontLG; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: npPreview.text = ""
                    }
                    Button {
                        text: "Done"; Layout.preferredHeight: btnH
                        background: Rectangle { radius: 12; color: theme.primaryColor; border.color: withAlpha(theme.secondaryColor, 0.6) }
                        contentItem: Text { text: parent.text; color: "black"; font.bold: true; font.pixelSize: fontLG; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: { if (np.targetField) np.targetField.text = npPreview.text; np.close() }
                    }
                }
            }
        }
    }

    // ---------- Content ----------
    Flickable {
        id: scroller
        anchors.top: parent.top
        anchors.bottom: footer.top
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true

        readonly property int gridSpacing: 26
        readonly property int colCount: Math.max(1,
            Math.min(3, Math.floor((scroller.width + gridSpacing) / (cardW + gridSpacing))))

        contentWidth: Math.max(width, gridWrap.implicitWidth)
        contentHeight: topGap.height + grid.implicitHeight + bottomGap.height + 24

        // top spacer (more room so it doesn’t feel glued to the top)
        Item { id: topGap; width: 1; height: 56 }

        // horizontally centered wrapper
        Item {
            id: gridWrap
            anchors.top: topGap.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: (scroller.colCount * cardW)
                         + ((scroller.colCount - 1) * scroller.gridSpacing)

            GridLayout {
                id: grid
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 3
                columnSpacing: scroller.gridSpacing
                rowSpacing: scroller.gridSpacing

                // ---- Row 0 ----
                // Badge (col 0)
                Frame {
                    padding: 20
                    Layout.preferredWidth: cardW
                    Layout.row: 0
                    Layout.column: 0
                    background: Rectangle {
                        radius: 18
                        color: withAlpha(theme.bgEnd, 0.68)
                        border.color: withAlpha(theme.secondaryColor, 0.28)
                        border.width: 1
                    }
                    contentItem: ColumnLayout {
                        spacing: 12
                        Label { text: "Badge Name"; color: textColor; font.pixelSize: fontXL }
                        TextField {
                            id: badge
                            Layout.fillWidth: true
                            implicitHeight: ctlH
                            text: prefs.badgeText || "KeyDash"
                            color: textColor; font.pixelSize: fontLG
                            readOnly: true
                            placeholderTextColor: withAlpha(textColor, 0.5)
                            background: Rectangle { radius: 12; color: withAlpha(theme.bgStart, 0.45); border.color: withAlpha(theme.primaryColor, 0.28) }
                            MouseArea { anchors.fill: parent; onClicked: { let p = alphaPadComp.createObject(wizard); p.targetField = badge; p.open(); } }
                        }
                    }
                }

                // Color Scheme (col 1)
                Frame {
                    padding: 20
                    Layout.preferredWidth: cardW
                    Layout.row: 0
                    Layout.column: 1
                    background: Rectangle {
                        radius: 18
                        color: withAlpha(theme.bgEnd, 0.68)
                        border.color: withAlpha(theme.secondaryColor, 0.28)
                        border.width: 1
                    }
                    contentItem: ColumnLayout {
                        spacing: 12
                        Label { text: "Color Scheme"; color: textColor; font.pixelSize: fontXL }
                        RowLayout {
                            spacing: 14
                            ComboBox {
                                id: scheme
                                model: ["Default","Dark Blue","Gold","Purple"]
                                Layout.preferredWidth: 260
                                implicitHeight: ctlH
                                font.pixelSize: fontLG
                                contentItem: Label {
                                    text: scheme.displayText || ""
                                    color: textColor; font.pixelSize: fontLG
                                    verticalAlignment: Text.AlignVCenter; padding: 12
                                }
                                background: Rectangle { radius: 12; color: withAlpha(theme.bgStart, 0.5); border.color: withAlpha(theme.secondaryColor, 0.35) }
                            }
                            Rectangle {
                                Layout.fillWidth: true; height: 12; radius: 6
                                gradient: Gradient {
                                    GradientStop { position: 0; color: theme.primaryColor }
                                    GradientStop { position: 1; color: theme.secondaryColor }
                                }
                                border.color: withAlpha(theme.secondaryColor, 0.35); border.width: 1
                            }
                        }
                    }
                }

                // Units (col 2)
                Frame {
                    padding: 20
                    Layout.preferredWidth: cardW
                    Layout.row: 0
                    Layout.column: 2
                    background: Rectangle {
                        radius: 18
                        color: withAlpha(theme.bgEnd, 0.68)
                        border.color: withAlpha(theme.secondaryColor, 0.28)
                        border.width: 1
                    }
                    contentItem: ColumnLayout {
                        spacing: 12
                        Label { text: "Units"; color: textColor; font.pixelSize: fontXL }
                        RowLayout {
                            spacing: 18
                            ComboBox {
                                id: speedUnits
                                model: ["km/h","mph"]
                                currentIndex: (prefs.speedUnits === "mph") ? 1 : 0
                                Layout.preferredWidth: 200
                                implicitHeight: ctlH
                                font.pixelSize: fontLG
                                contentItem: Label { text: speedUnits.displayText || ""; color: textColor; font.pixelSize: fontLG; verticalAlignment: Text.AlignVCenter; padding: 12 }
                                background: Rectangle { radius: 12; color: withAlpha(theme.bgStart, 0.5); border.color: withAlpha(theme.secondaryColor, 0.35) }
                            }
                            ComboBox {
                                id: tempUnits
                                model: ["°C","°F"]
                                currentIndex: (prefs.tempUnits === "°F") ? 1 : 0
                                Layout.preferredWidth: 200
                                implicitHeight: ctlH
                                font.pixelSize: fontLG
                                contentItem: Label { text: tempUnits.displayText || ""; color: textColor; font.pixelSize: fontLG; verticalAlignment: Text.AlignVCenter; padding: 12 }
                                background: Rectangle { radius: 12; color: withAlpha(theme.bgStart, 0.5); border.color: withAlpha(theme.secondaryColor, 0.35) }
                            }
                            ComboBox {
                                id: pressUnits
                                model: ["kPa","psi"]
                                currentIndex: (prefs.pressUnits === "psi") ? 1 : 0
                                Layout.preferredWidth: 200
                                implicitHeight: ctlH
                                font.pixelSize: fontLG
                                contentItem: Label { text: pressUnits.displayText || ""; color: textColor; font.pixelSize: fontLG; verticalAlignment: Text.AlignVCenter; padding: 12 }
                                background: Rectangle { radius: 12; color: withAlpha(theme.bgStart, 0.5); border.color: withAlpha(theme.secondaryColor, 0.35) }
                            }
                        }
                    }
                }

                // ---- Row 1 ----
                // Clock & Brightness under Badge (col 0)
                Frame {
                    padding: 20
                    Layout.preferredWidth: cardW
                    Layout.row: 1
                    Layout.column: 0
                    background: Rectangle {
                        radius: 18
                        color: withAlpha(theme.bgEnd, 0.68)
                        border.color: withAlpha(theme.secondaryColor, 0.28)
                        border.width: 1
                    }
                    contentItem: ColumnLayout {
                        spacing: 12
                        Label { text: "Clock & Brightness"; color: textColor; font.pixelSize: fontXL }
                        RowLayout {
                            spacing: 18
                            ComboBox {
                                id: clockFmt
                                model: ["24h","12h"]
                                currentIndex: (prefs.clockFormat === "12h" || prefs.clockFormat === "12") ? 1 : 0
                                Layout.preferredWidth: 160
                                implicitHeight: ctlH
                                font.pixelSize: fontLG
                                contentItem: Label { text: clockFmt.displayText || ""; color: textColor; font.pixelSize: fontLG; verticalAlignment: Text.AlignVCenter; padding: 12 }
                                background: Rectangle { radius: 12; color: withAlpha(theme.bgStart,0.5); border.color: withAlpha(theme.secondaryColor,0.35) }
                            }
                            Slider {
                                id: bright
                                from: 0; to: 100
                                // keep prefs.brightness in 0..100
                                value: (typeof prefs.brightness === "number") ? prefs.brightness * 100 : 80
                                Layout.fillWidth: true
                                implicitHeight: ctlH
                                background: Item {
                                    x: bright.leftPadding
                                    y: bright.topPadding + bright.availableHeight/2 - height/2
                                    width: bright.availableWidth
                                    height: 8
                                    Rectangle { anchors.fill: parent; radius: 4; color: withAlpha(theme.bgStart, 0.6) }
                                    Rectangle { width: bright.visualPosition * parent.width; height: parent.height; radius: 4; color: theme.secondaryColor }
                                }
                                handle: Rectangle {
                                    width: 28; height: 28; radius: 14
                                    color: theme.secondaryColor
                                    border.color: withAlpha(theme.primaryColor, 0.5)
                                    x: bright.leftPadding + bright.visualPosition * (bright.availableWidth - width)
                                    y: bright.topPadding  + bright.availableHeight/2 - height/2
                                }
                            }
                            Label { text: Math.round(bright.value) + "%"; color: textColor; font.pixelSize: fontLG }
                        }
                    }
                }

                // Odometer under Color Scheme (col 1)
                Frame {
                    padding: 20
                    Layout.preferredWidth: cardW
                    Layout.row: 1
                    Layout.column: 1
                    background: Rectangle {
                        radius: 18
                        color: withAlpha(theme.bgEnd, 0.68)
                        border.color: withAlpha(theme.secondaryColor, 0.28)
                        border.width: 1
                    }
                    contentItem: ColumnLayout {
                        spacing: 12
                        Label { text: "Odometer"; color: textColor; font.pixelSize: fontXL }
                        RowLayout {
                            spacing: 14
                            TextField {
                                id: odoField
                                Layout.preferredWidth: 280
                                implicitHeight: ctlH
                                text: (Number(prefs.odometer)||0).toString()
                                color: textColor; font.pixelSize: fontLG
                                readOnly: true
                                placeholderTextColor: withAlpha(textColor, 0.5)
                                background: Rectangle { radius: 12; color: withAlpha(theme.bgStart, 0.5); border.color: withAlpha(theme.secondaryColor, 0.35) }
                                MouseArea { anchors.fill: parent; onClicked: { let p = numPadComp.createObject(wizard); p.targetField = odoField; p.open(); } }
                            }
                            ComboBox {
                                id: odoUnits
                                model: ["km","mi"]
                                currentIndex: (prefs.odometerUnits === "mi") ? 1 : 0
                                Layout.preferredWidth: 160
                                implicitHeight: ctlH
                                font.pixelSize: fontLG
                                contentItem: Label { text: odoUnits.displayText || ""; color: textColor; font.pixelSize: fontLG; verticalAlignment: Text.AlignVCenter; padding: 12 }
                                background: Rectangle { radius: 12; color: withAlpha(theme.bgStart, 0.5); border.color: withAlpha(theme.secondaryColor, 0.35) }
                            }
                        }
                    }
                }

                // Transmission Ratios under Units (col 2)
                Frame {
                    id: gearFrame
                    padding: 20
                    Layout.preferredWidth: cardW
                    Layout.row: 1
                    Layout.column: 2
                    background: Rectangle {
                        radius: 18
                        color: withAlpha(theme.bgEnd, 0.68)
                        border.color: withAlpha(theme.secondaryColor, 0.28)
                        border.width: 1
                    }
                    property int gearCount: Math.max(3, Math.min(11, (prefs.gearRatios && prefs.gearRatios.length) ? prefs.gearRatios.length : 6))

                    contentItem: ColumnLayout {
                        spacing: 12
                        RowLayout {
                            Layout.fillWidth: true
                            Label { text: "Transmission Ratios"; color: textColor; font.pixelSize: fontXL; Layout.fillWidth: true }
                            Label { text: "Gears"; color: textColor; font.pixelSize: fontMD }
                            ComboBox {
                                id: gearCountBox
                                model: [3,4,5,6,7,8,9,10,11]
                                currentIndex: Math.max(0, model.indexOf(gearFrame.gearCount))
                                Layout.preferredWidth: 120
                                implicitHeight: ctlH
                                font.pixelSize: fontLG
                                contentItem: Label { text: gearCountBox.displayText || ""; color: textColor; font.pixelSize: fontLG; verticalAlignment: Text.AlignVCenter; padding: 12 }
                                background: Rectangle { radius: 12; color: withAlpha(theme.bgStart,0.5); border.color: withAlpha(theme.secondaryColor,0.35) }
                                onCurrentIndexChanged: gearFrame.gearCount = model[currentIndex]
                            }
                        }
                        ColumnLayout {
                            id: ratiosCol
                            Repeater {
                                id: gearRepeater
                                model: gearFrame.gearCount
                                delegate: RowLayout {
                                    spacing: 12
                                    Label { text: "Gear " + (index + 1); color: textColor; font.pixelSize: fontMD; Layout.preferredWidth: 80 }
                                    TextField {
                                        id: ratio
                                        placeholderText: "3.321"
                                        width: 140
                                        implicitHeight: ctlH
                                        color: textColor; font.pixelSize: fontLG
                                        readOnly: true
                                        placeholderTextColor: withAlpha(textColor, 0.5)
                                        background: Rectangle { radius: 12; color: withAlpha(theme.bgStart, 0.5); border.color: withAlpha(theme.primaryColor, 0.35) }
                                        MouseArea { anchors.fill: parent; onClicked: { let p = numPadComp.createObject(wizard); p.targetField = ratio; p.open(); } }
                                    }
                                }
                            }
                            RowLayout {
                                spacing: 12
                                Label { text: "Final"; color: textColor; font.pixelSize: fontMD; Layout.preferredWidth: 80 }
                                TextField {
                                    id: finalDrive
                                    placeholderText: "4.100"
                                    width: 140
                                    implicitHeight: ctlH
                                    color: textColor; font.pixelSize: fontLG
                                    readOnly: true
                                    placeholderTextColor: withAlpha(textColor, 0.5)
                                    background: Rectangle { radius: 12; color: withAlpha(theme.bgStart, 0.5); border.color: withAlpha(theme.primaryColor, 0.35) }
                                    MouseArea { anchors.fill: parent; onClicked: { let p = numPadComp.createObject(wizard); p.targetField = finalDrive; p.open(); } }
                                }
                            }
                        }
                    }
                }
            } // GridLayout
        } // gridWrap

        // bottom spacer so last card doesn't tuck under footer
        Item { id: bottomGap; width: 1; height: 48 }
    }

    // ---------- Footer ----------
    Rectangle {
        id: footer
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        height: 88
        color: "transparent"
        RowLayout {
            anchors.fill: parent; anchors.margins: 18; spacing: 14
            Button {
                text: "Skip"; Layout.preferredHeight: btnH; Layout.preferredWidth: 140
                background: Rectangle { radius: 14; color: withAlpha(theme.bgStart, 0.14); border.color: withAlpha(theme.secondaryColor, 0.55) }
                contentItem: Text { text: parent.text; color: textColor; font.pixelSize: fontLG; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: wizard.finished()
            }
            Item { Layout.fillWidth: true }
            Button {
                id: saveBtn
                text: "Save"; Layout.preferredHeight: btnH; Layout.preferredWidth: 160
                background: Rectangle { radius: 14; color: theme.primaryColor; border.color: withAlpha(theme.secondaryColor, 0.7) }
                contentItem: Text { text: parent.text; color: "black"; font.bold: true; font.pixelSize: fontLG; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: {
                    /*prefs.badgeText     = badge.text
                    prefs.themeName     = scheme.currentText
                    prefs.speedUnits    = speedUnits.currentText
                    prefs.tempUnits     = tempUnits.currentText
                    prefs.pressUnits    = pressUnits.currentText
                    prefs.clockFormat   = clockFmt.currentText
                    prefs.brightness    = Math.round(bright.value)         // 0..100
                    prefs.odometer      = Number(odoField.text) || 0
                    prefs.odometerUnits = odoUnits.currentText

                    let arr = []
                    for (let i = 0; i < gearRepeater.count; ++i) {
                        const rowItem = gearRepeater.itemAt(i)
                        if (rowItem && rowItem.ratio) {
                            const v = parseFloat(rowItem.ratio.text)
                            if (!isNaN(v)) arr.push(v)
                        }
                    }
                    prefs.gearRatios = arr
                    prefs.finalDrive = parseFloat(finalDrive.text) || 0*/
                    //prefs.firstStart = false
                    wizard.finished()
                }
            }
        }
    }
}
