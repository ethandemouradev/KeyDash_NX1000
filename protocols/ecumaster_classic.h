#pragma once
#include "core/iecuprotocol.h"

class SerialTransport;

class EcuMasterClassicProtocol : public IECUProtocol {
    Q_OBJECT
  public:
    using IECUProtocol::IECUProtocol;
    QString name() const override { return "ECUMaster Classic"; }

    bool probe(ITransport *t) override;   // we'll accept serial for now
    bool start(ITransport *t) override;   // connect to serial, ready to parse
    void stop() override;

  private:
    SerialTransport *m_st { nullptr };

  private slots:
    void onSerial(const QByteArray &buf); // TODO: call your existing frame parser here
};
