#pragma once
#include <QObject>
#include <QByteArray>

class ITransport : public QObject {
    Q_OBJECT
  public:
    using QObject::QObject;
    virtual ~ITransport() = default;

    virtual bool open() = 0;
    virtual void close() = 0;
    virtual bool isOpen() const = 0;

  signals:
    void bytesIn(const QByteArray &buf);           // serial/TCP/UDP
    void canIn(quint32 id, const QByteArray &dlc); // CAN frames (8 bytes)
};
