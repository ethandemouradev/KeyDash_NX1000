#include "ecumaster_classic.h"
#include "transports/serial_transport.h"
#include <QDateTime>

bool EcuMasterClassicProtocol::probe(ITransport *t) {
    m_st = qobject_cast<SerialTransport*>(t);
    if (!m_st) return false;
    connect(m_st, &ITransport::bytesIn, this, &EcuMasterClassicProtocol::onSerial, Qt::UniqueConnection);
    return true; // Later: sniff your classic header to be strict
}

bool EcuMasterClassicProtocol::start(ITransport *t) {
    Q_UNUSED(t);
    if (!m_st) return false;
    emit statusChanged("ECUMaster Classic (serial) started");
    return true;
}

void EcuMasterClassicProtocol::stop() {
    // nothing yet
}

void EcuMasterClassicProtocol::onSerial(const QByteArray &buf) {
    Q_UNUSED(buf);
    // TODO: plug your existing ecu_reader decode here and emit normalized signals, e.g.:
    // const qint64 now = QDateTime::currentMSecsSinceEpoch();
    // emit sig({"Engine.RPM", rpm, now});
    // emit sig({"Temps.CLT_C", clt, now});
    // emit sig({"Lambda.AFR", afr, now});
}
