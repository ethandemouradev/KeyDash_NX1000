// Lightweight serial port helper that feeds the DashModel. The implementation
// can either use a real serial device (openPort) or emit synthetic demo
// samples when no hardware is available.

#pragma once
#include <QObject>
+#include <QtSerialPort/QSerialPort>
+#include <QTimer>
+
+class DashModel;
+
+class SerialWorker : public QObject {
+	Q_OBJECT
+	public:
+		explicit SerialWorker(DashModel* model, QObject* parent=nullptr);
+		// Open a serial device for incoming ECU frames (returns false on error).
+		Q_INVOKABLE bool openPort(const QString& name, int baud=19200);
+	private slots:
+		void onReadyRead();
+		void demoTick();
+	private:
+		void pushSample(double rpm,double speed_kph,double boost,double clt,double iat,double vbat,double afr,int gear);
+		DashModel* m_model{nullptr};
+		QSerialPort m_port; QByteArray m_buf; QTimer m_demo;
+		double t{0.0}, speedKph{0.0};
+	};
