#pragma once
#include "core/iecuprotocol.h"
#include <QTimer>

class DemoProtocol : public IECUProtocol {
    Q_OBJECT
  public:
    using IECUProtocol::IECUProtocol;
    QString name() const override { return "Demo"; }

    bool probe(ITransport *t) override { Q_UNUSED(t); return true; }
    bool start(ITransport *t) override {
        Q_UNUSED(t);
        connect(&tick_, &QTimer::timeout, this, &DemoProtocol::gen);
        tick_.start(50); // 20 Hz
        emit statusChanged("Demo running (no hardware)");
        return true;
    }
    void stop() override { tick_.stop(); }

  private:
    QTimer tick_;
    double t_ = 0;

  private slots:
    void gen();
};
