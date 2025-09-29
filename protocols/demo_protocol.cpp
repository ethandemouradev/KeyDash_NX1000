#include "demo_protocol.h"
#include <QtMath>
#include <QDateTime>

void DemoProtocol::gen() {
    const qint64 now = QDateTime::currentMSecsSinceEpoch();
    t_ += 0.05;

           // RPM sweeps 900–7000
    double rpm = 900 + (qSin(t_) * 0.5 + 0.5) * (7000 - 900);
    emit sig({"Engine.RPM", rpm, now});

           // Speed 0–120 kph wave
    double spd = (qSin(t_ * 0.3) * 0.5 + 0.5) * 120.0;
    emit sig({"Vehicle.SpeedKph", spd, now});

           // Temps
    double clt = 75 + (qSin(t_ * 0.1) * 0.5 + 0.5) * 20;  // 75–95 C
    double iat = 35 + (qSin(t_ * 0.2 + 1.0) * 0.5 + 0.5) * 10; // 35–45 C
    emit sig({"Temps.CLT_C", clt, now});
    emit sig({"Temps.IAT_C", iat, now});

           // TPS (0–100) if you keep it later
    emit sig({"Engine.TPS_Percent", (qSin(t_*0.8)*0.5+0.5)*100.0, now});

           // Boost (psi) since you renamed map → boost
           // oscillate between -10 (vac) and +12 (boost)
    double boostPsi = -10 + (qSin(t_*0.6)*0.5+0.5) * (12 - (-10));
    emit sig({"Engine.Boost_PSI", boostPsi, now});
}
