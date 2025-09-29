import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: root
    title: "ECU / Connection"

    property alias selectedTransport: transportGroup.checkedButton
    property alias selectedProtocol:  protoGroup.checkedButton
    property string statusText: ""
    readonly property bool isDemo: protoGroup.checkedButton && protoGroup.checkedButton.key === "Demo"
    signal apply(string portName, int baud, string canIface, string protoName, string transportName)

    Connections {
      target: connCtrl
      function onStatusChanged(s) {
        console.log("STATUS:", s) // you should see this in the log
        statusText = s
      }
    }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 12

        Label {
          text: statusText.length ? statusText : "Idle"
          color: statusText.indexOf("Failed") >= 0 ? "tomato" : "lightgreen"
          font.pixelSize: 18
          Layout.fillWidth: true
          wrapMode: Text.Wrap
        }

        GroupBox {
            title: "Transport"
            Layout.fillWidth: true
            RowLayout {
                id: transportRow; spacing: 16
                ButtonGroup { id: transportGroup }
                RadioButton { text: "Serial"; checked: true; ButtonGroup.group: transportGroup; property string key: "serial" }
                RadioButton { text: "CAN (socketcan)"; ButtonGroup.group: transportGroup; property string key: "can" }
            }
        }

        RowLayout {
            visible: transportGroup.checkedButton && transportGroup.checkedButton.key === "serial"
            spacing: 12; Layout.fillWidth: true
            TextField { id: port; enabled: !isDemo; placeholderText: "Example: COM7 or /dev/ttyUSB0"; Layout.fillWidth: true }
            SpinBox  { id: baud; enabled: !isDemo; from: 1200; to: 10000000; value: isDemo ? 38400 : baud.value }

        }

        RowLayout {
            visible: transportGroup.checkedButton && transportGroup.checkedButton.key === "can"
            spacing: 12; Layout.fillWidth: true
            TextField { id: canIf; placeholderText: "can0"; Layout.fillWidth: true; text: "can0" }
        }

        GroupBox {
            title: "Protocol"
            Layout.fillWidth: true
            RowLayout {
                id: protoRow; spacing: 16
                ButtonGroup { id: protoGroup }
                RadioButton { text: "Demo (no hardware)"; ButtonGroup.group: protoGroup; property string key: "Demo" }
                RadioButton { text: "OBD2/ELM327"; checked: true; ButtonGroup.group: protoGroup; property string key: "OBD2" }
                RadioButton { text: "ECUMaster Classic"; ButtonGroup.group: protoGroup; property string key: "ECUMasterClassic" }
                // Later: RadioButton { text: "ECUMaster Black (CAN)"; ButtonGroup.group: protoGroup; property string key: "ECUMasterBlack" }
            }
        }

        Label { text: statusText; color: statusText.indexOf("Failed")>=0 ? "tomato" : "lightgreen" }

        Button {
          text: "Apply & Connect"
          onClicked: {
            const tKey = transportGroup.checkedButton ? transportGroup.checkedButton.key : "serial"
            const pKey = protoGroup.checkedButton ? protoGroup.checkedButton.key : "Demo"
            const ok = connCtrl.apply(tKey, port.text, baud.value, canIf.text, pKey)
            root.statusText = ok ? "Connecting..." : "Failed to start — see status line"
            console.debug("Transport:", tKey, "Port:", port.text || "<empty>", "Baud:", baud.value, "Proto:", pKey, "=>", ok)
          }
        }
        Label { text: "Tip: OBD2 uses an ELM327 adapter on a serial COM/tty port. CAN uses socketcan (can0)." }
    }
}
