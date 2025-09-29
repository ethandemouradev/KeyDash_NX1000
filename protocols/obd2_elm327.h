#pragma once
#include "core/iecuprotocol.h"
#include <QObject>
#include <QTimer>

class SerialTransport;

class OBD2Elm327Protocol : public IECUProtocol {
    Q_OBJECT
  public:
    explicit OBD2Elm327Protocol(QObject *parent=nullptr);
    QString name() const override { return "OBD2/ELM327"; }

    bool probe(ITransport *t) override;  // send "ATZ" and expect "ELM"
    bool start(ITransport *t) override;  // set up periodic PID polling
    void stop() override;

  private:
    SerialTransport *m_st{nullptr};
    QTimer m_poll;
    QByteArray m_rxBuf;

    void send(const QByteArray &cmd);
    void pollOnce();

  private slots:
    void onSerial(const QByteArray &buf);

           // helpers
    bool parseLine(const QByteArray &line, QString &pid, int &value);
};
