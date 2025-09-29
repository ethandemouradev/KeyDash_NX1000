#include "serial_transport.h"
#include <QSerialPortInfo>

bool SerialTransport::open() {
    if (m_sp.isOpen()) return true;
    m_sp.setPortName(m_portName);
    m_sp.setBaudRate(m_baud);
    m_sp.setParity(QSerialPort::NoParity);
    m_sp.setDataBits(QSerialPort::Data8);
    m_sp.setStopBits(QSerialPort::OneStop);
    m_sp.setFlowControl(QSerialPort::NoFlowControl);
    if (!m_sp.open(QIODevice::ReadWrite)) return false;
    connect(&m_sp, &QSerialPort::readyRead, this, &SerialTransport::onReadyRead);
    return true;
}

void SerialTransport::close() {
    if (m_sp.isOpen()) m_sp.close();
}

qint64 SerialTransport::write(const QByteArray &data) {
    return m_sp.isOpen() ? m_sp.write(data) : -1;
}

void SerialTransport::onReadyRead() {
    const QByteArray buf = m_sp.readAll();
    if (!buf.isEmpty()) emit bytesIn(buf);
}
