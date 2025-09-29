#include "controllers/connection_controller.h"
#include "transports/serial_transport.h"
#include "transports/can_transport.h"
#include "protocols/obd2_elm327.h"
#include "protocols/ecumaster_classic.h"
#include <QSerialPortInfo>
#include "protocols/demo_protocol.h"

ConnectionController::ConnectionController(QObject *parent) : QObject(parent) {
    m_mgr = new EcuManager(this);
    connect(m_mgr, &EcuManager::sig, this, &ConnectionController::sig);
    connect(m_mgr, &EcuManager::statusChanged, this, &ConnectionController::statusChanged);
}

ConnectionController::~ConnectionController() { if (m_mgr) m_mgr->stop(); }

bool ConnectionController::setupTransport(const QString &key, const QString &port, int baud, const QString &canIf) {
    if (key == "serial") {
        QString p = port.trimmed();
        if (p.isEmpty()) {
            const auto ports = QSerialPortInfo::availablePorts();
            if (!ports.isEmpty())
                p = ports.first().portName();
        }
        if (p.isEmpty()) {
            emit statusChanged("Transport failed: no serial port specified (and none detected)");
            return false;
        }
        m_transport.reset(new SerialTransport(p, baud, this));
        if (!m_transport->open()) {
            emit statusChanged(QString("Transport failed: cannot open %1 @ %2 baud").arg(p).arg(baud));
            return false;
        }
        emit statusChanged(QString("Serial open: %1 @ %2").arg(p).arg(baud));
        return true;

    } else if (key == "can") {
        QString ifc = canIf.trimmed().isEmpty() ? QStringLiteral("can0") : canIf.trimmed();
        m_transport.reset(new CanTransport(ifc, "socketcan", this));
        if (!m_transport->open()) {
            emit statusChanged(QString("Transport failed: cannot open CAN iface %1").arg(ifc));
            return false;
        }
        emit statusChanged(QString("CAN open: %1").arg(ifc));
        return true;
    }
    emit statusChanged("Transport failed: unknown transport key");
    return false;
}

bool ConnectionController::setupProtocol(const QString &key) {
    if (key == "OBD2") {
        m_protocol.reset(new OBD2Elm327Protocol(this));
        return true;
    } else if (key == "ECUMasterClassic") {
        m_protocol.reset(new EcuMasterClassicProtocol(this));
        return true;
    } else if (key == "Demo") {
        m_protocol.reset(new DemoProtocol(this));
        return true;
    }

    return false;
}

bool ConnectionController::apply(const QString &transportKey,
                                 const QString &portName, int baud,
                                 const QString &canIface,
                                 const QString &protoKey)
{
    // 1) Set up protocol first so we can special-case Demo
    if (!setupProtocol(protoKey)) {
        emit statusChanged(QString("Unknown protocol: %1").arg(protoKey));
        return false;
    }

           // 2) Demo protocol requires NO hardware/transport
    if (protoKey == "Demo") {
        m_transport.reset(nullptr);
        m_mgr->setTransport(nullptr);
        m_mgr->setProtocol(m_protocol.take()); // manager owns protocol
        if (!m_mgr->start()) {
            emit statusChanged("Failed to start Demo protocol");
            return false;
        }
        emit statusChanged("Connected via Demo (no hardware)");
        return true;
    }

           // 3) All other protocols: open the requested transport
    if (!setupTransport(transportKey, portName, baud, canIface)) {
        emit statusChanged(QString("Transport failed: %1 (port='%2', baud=%3, iface='%4')")
                               .arg(transportKey, portName, QString::number(baud), canIface));
        return false;
    }

           // 4) Wire up and start
    m_mgr->setTransport(m_transport.data());
    m_mgr->setProtocol(m_protocol.take()); // manager owns protocol
    if (!m_mgr->start()) {
        emit statusChanged("Failed to start ECU protocol");
        return false;
    }

    emit statusChanged(QString("Connected via %1 / %2").arg(transportKey, protoKey));
    return true;
}

