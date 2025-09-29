#include "can_transport.h"
#include <QCanBus>
#include <QCanBusDevice>
#include <QCanBusFrame>

bool CanTransport::open() {
    if (m_dev && m_dev->state() == QCanBusDevice::ConnectedState) return true;
    QString errStr;
    m_dev = QCanBus::instance()->createDevice(m_plugin, m_iface, &errStr);
    if (!m_dev) return false;
    if (!m_dev->connectDevice()) return false;
    connect(m_dev, &QCanBusDevice::framesReceived, this, &CanTransport::onFramesReceived);
    return true;
}

void CanTransport::close() {
    if (m_dev) m_dev->disconnectDevice();
}

bool CanTransport::isOpen() const {
    return m_dev && m_dev->state() == QCanBusDevice::ConnectedState;
}

bool CanTransport::write(quint32 id, const QByteArray &payload) {
    if (!isOpen()) return false;
    QCanBusFrame f(id, payload);
    return m_dev->writeFrame(f);
}

void CanTransport::onFramesReceived() {
    if (!m_dev) return;
    while (m_dev->framesAvailable() > 0) {
        const QCanBusFrame f = m_dev->readFrame();
        emit canIn(f.frameId(), f.payload());
    }
}
