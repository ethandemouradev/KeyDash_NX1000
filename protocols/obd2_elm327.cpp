#include "obd2_elm327.h"
#include "transports/serial_transport.h"
#include <QDateTime>

OBD2Elm327Protocol::OBD2Elm327Protocol(QObject *parent) : IECUProtocol(parent) {
    connect(&m_poll, &QTimer::timeout, this, &OBD2Elm327Protocol::pollOnce);
    m_poll.setInterval(100); // ~10 Hz total across a few PIDs
}

bool OBD2Elm327Protocol::probe(ITransport *t) {
    m_st = qobject_cast<SerialTransport*>(t);
    if (!m_st) return false;
    connect(m_st, &ITransport::bytesIn, this, &OBD2Elm327Protocol::onSerial, Qt::UniqueConnection);
    m_rxBuf.clear();
    send("ATZ\r");     // reset
    send("ATI\r");     // identify
    // naive probe: we'll look for "ELM" substring in responses we collect in onSerial()
    return true; // allow start(); you can gate this tighter if you want
}

bool OBD2Elm327Protocol::start(ITransport *t) {
    m_st = qobject_cast<SerialTransport*>(t);
    if (!m_st || !m_st->isOpen()) return false;

    send("ATE0\r"); // echo off
    send("ATL0\r"); // linefeeds off
    send("ATS0\r"); // spaces off
    send("ATH0\r"); // headers off
    send("ATSP0\r"); // auto protocol

    m_poll.start();
    emit statusChanged("Polling OBD-II PIDs");
    return true;
}

void OBD2Elm327Protocol::stop() {
    m_poll.stop();
}

void OBD2Elm327Protocol::send(const QByteArray &cmd) {
    if (m_st) m_st->write(cmd);
}

void OBD2Elm327Protocol::onSerial(const QByteArray &buf) {
    m_rxBuf += buf;
    // Split on '>' prompt or CR
    int idx;
    while ((idx = m_rxBuf.indexOf('\r')) >= 0) {
        const QByteArray line = m_rxBuf.left(idx);
        m_rxBuf.remove(0, idx+1);
        QString pid; int val = 0;
        if (parseLine(line, pid, val)) {
            const qint64 now = QDateTime::currentMSecsSinceEpoch();
            if (pid == "0C") { // RPM = ((A*256)+B)/4
                emit sig({"Engine.RPM", val/4.0, now});
            } else if (pid == "0D") { // Speed = A (km/h)
                emit sig({"Vehicle.SpeedKph", double(val), now});
            } else if (pid == "05") { // Coolant temp = A-40 (C)
                emit sig({"Temps.CLT_C", double(val-40), now});
            } else if (pid == "0F") { // IAT = A-40
                emit sig({"Temps.IAT_C", double(val-40), now});
            } else if (pid == "11") { // TPS = A*100/255
                emit sig({"Engine.TPS_Percent", (val*100.0)/255.0, now});
            } else if (pid == "0B") { // MAP = A (kPa) approx
                emit sig({"Engine.MAP_kPa", double(val), now});
            }
        }
    }
}

bool OBD2Elm327Protocol::parseLine(const QByteArray &line, QString &pid, int &value) {
    // Expect like: "41 0C 1A F8" → mode 01 response (0x41), PID 0C, then A B
    QList<QByteArray> tok = line.simplified().split(' ');
    if (tok.size() < 3) return false;
    if (tok[0] != "41") return false;
    pid = QString::fromLatin1(tok[1]);
    value = 0;
    for (int i=2;i<tok.size();++i) {
        bool ok=false; int b = tok[i].toInt(&ok, 16);
        if (!ok) return false;
        value = (value<<8) | (b & 0xFF);
    }
    return true;
}

void OBD2Elm327Protocol::pollOnce() {
    // rotate through a few core PIDs
    static int step = 0;
    const char* pids[] = { "010C", "010D", "0105", "010F", "0111", "010B" };
    send(QByteArray(pids[step]) + "\r");
    step = (step+1) % 6;
}
