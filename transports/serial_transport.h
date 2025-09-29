#pragma once
#include "core/itransport.h"
#include <QSerialPort>

class SerialTransport : public ITransport {
    Q_OBJECT
  public:
    explicit SerialTransport(const QString &portName, int baud, QObject *parent=nullptr)
        : ITransport(parent), m_portName(portName), m_baud(baud) {}

    bool open() override;
    void close() override;
    bool isOpen() const override { return m_sp.isOpen(); }

    qint64 write(const QByteArray &data);

  private:
    QString m_portName;
    int m_baud{115200};
    QSerialPort m_sp;

  private slots:
    void onReadyRead();
};
