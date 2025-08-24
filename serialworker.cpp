#include "serialworker.h"
#include "dashmodel.h"
#include <QtMath>
static inline double kphToMph(double k){ return k*0.621371; }

SerialWorker::SerialWorker(DashModel* model, QObject* parent)
    : QObject(parent), m_model(model)
{
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
    m_buf.append(m_port.readAll());
    // TODO: parse your 16-byte ECUmaster frame here; when you have one:
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
