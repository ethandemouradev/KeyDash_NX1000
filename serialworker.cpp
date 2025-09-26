// Serial port helper that can drive the DashModel with either real ECU data
// or a synthetic demo stream. All edits here are comment-only; behaviour
// and timing are preserved.

#include "serialworker.h"
#include "dashmodel.h"
#include <QtMath>

+// Convert kilometers-per-hour to miles-per-hour (used by demo/port code).
static inline double kphToMph(double k){ return k*0.621371; }

SerialWorker::SerialWorker(DashModel* model, QObject* parent)
    : QObject(parent), m_model(model)
{
    // Start the synthetic demo timer (50 ms -> 20 Hz) by default. Opening a
    // real serial port will stop the demo loop.
    connect(&m_demo,&QTimer::timeout,this,&SerialWorker::demoTick);
    m_demo.start(50); // 20 Hz demo
}
bool SerialWorker::openPort(const QString& name, int baud){
    m_port.setPortName(name);
    m_port.setBaudRate(baud);
    m_port.setDataBits(QSerialPort::Data8);
    m_port.setParity(QSerialPort::NoParity);
    m_port.setStopBits(QSerialPort::OneStop);
    m_port.setFlowControl(QSerialPort::NoFlowControl);
    if(!m_port.open(QIODevice::ReadOnly)) return false;
    connect(&m_port,&QSerialPort::readyRead,this,&SerialWorker::onReadyRead);
    m_demo.stop(); return true;
}
void SerialWorker::onReadyRead(){
    // Append incoming bytes to the frame buffer. Parsing is intentionally
    // left to the integrator: when a complete ECU frame is available call
    // pushSample(...) with the decoded values.
    m_buf.append(m_port.readAll());
    // Example integration point (decode frame -> pushSample(...)).
    // pushSample(rpm, speed_kph, boost, clt, iat, vbat, afr, gear);
}
void SerialWorker::demoTick(){
    t += 0.05;
    double rpm   = 1000 + (qSin(t)*0.5 + 0.5)*6500;
    speedKph     = qMax(0.0, speedKph + qSin(t*0.3)*2.0);
    double boost = qMax(0.0, (rpm-2200.0)/6000.0) * 16.0;
    double clt=82+3*qSin(t*0.15), iat=27+5*qSin(t*0.2), vbat=14.2+0.3*qSin(t*0.6);
    double afr=14.7+0.5*qSin(t*0.8); int gear=qBound(1,int((rpm/8000.0)*6)+1,6);
    pushSample(rpm, speedKph, boost, clt, iat, vbat, afr, gear);

    double mph = kphToMph(speedKph);
    double dt_hours = 0.05 / 3600.0;
    double d_miles = mph * dt_hours;
    if (m_model) {
        m_model->setTrip(m_model->trip() + d_miles);
        m_model->setOdo(m_model->odo() + d_miles);
    }
}
void SerialWorker::pushSample(double rpm,double speed_kph,double boost,double clt,double iat,double vbat,double afr,int gear){
    if(!m_model) return;
    m_model->applySample(rpm, kphToMph(speed_kph), boost, clt, iat, vbat, afr, gear);
}
