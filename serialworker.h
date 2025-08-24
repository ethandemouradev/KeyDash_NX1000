#pragma once
#include <QObject>
#include <QtSerialPort/QSerialPort>
#include <QTimer>
class DashModel;

class SerialWorker : public QObject {
    Q_OBJECT
public:
    explicit SerialWorker(DashModel* model, QObject* parent=nullptr);
    Q_INVOKABLE bool openPort(const QString& name, int baud=19200);
private slots:
    void onReadyRead();
    void demoTick();
private:
    void pushSample(double rpm,double speed_kph,double boost,double clt,double iat,double vbat,double afr,int gear);
    DashModel* m_model{nullptr};
    QSerialPort m_port; QByteArray m_buf; QTimer m_demo;
    double t{0.0}, speedKph{0.0};
};
