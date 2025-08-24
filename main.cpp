#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>
#include <QTimer>
#include <QCursor>
#include <QDateTime>

#include "dashmodel.h"

#ifdef HAVE_SERIALPORT
#include "serialworker.h"
#endif

using namespace Qt::StringLiterals;

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("KeyDash");
    QCoreApplication::setOrganizationDomain("keydash.local");
    QCoreApplication::setApplicationName("KeyDash_NX1000");
    QGuiApplication::setOverrideCursor(Qt::BlankCursor);

    DashModel dash;
    dash.loadVehicleConfig();

#ifdef HAVE_SERIALPORT
    SerialWorker worker(&dash);
#else
    qWarning("Qt6 SerialPort not found – running without ECU serial I/O.");
#endif

    QTimer clock;
    QObject::connect(&clock, &QTimer::timeout, [&]{
        dash.setDateTimeString(QDateTime::currentDateTime().toString("dddd, MMM d\nh:mmap"));
    });
    clock.start(1000);
    dash.setDateTimeString(QDateTime::currentDateTime().toString("dddd, MMM d\nh:mmap"));

    auto *settings = new QSettings(QSettings::IniFormat, QSettings::UserScope,
                                   QCoreApplication::organizationName(),
                                   QCoreApplication::applicationName());

    // Load extra settings (system-wide defaults)
    QSettings sys("/etc/keydash/keydash.ini", QSettings::IniFormat);
    sys.beginGroup("vehicle");
    dash.setRpmMax(sys.value("rpm_max", dash.rpmMax()).toInt());
    dash.setUseMph(sys.value("use_mph", true).toBool());
    dash.setFinalDrive(sys.value("final_drive", 4.1).toDouble());
    dash.setGearRatio(1, sys.value("gear1", 3.5).toDouble());
    dash.setGearRatio(2, sys.value("gear2", 2.2).toDouble());
    dash.setGearRatio(3, sys.value("gear3", 1.5).toDouble());
    dash.setGearRatio(4, sys.value("gear4", 1.1).toDouble());
    dash.setGearRatio(5, sys.value("gear5", 1.0).toDouble());
    sys.endGroup();

    dash.setOdo(settings->value("odo", dash.odo()).toDouble());
    dash.setTrip(settings->value("trip", dash.trip()).toDouble());

    QObject::connect(&dash, &DashModel::odoChanged, [&](){
        settings->setValue("odo", dash.odo());
    });
    QObject::connect(&dash, &DashModel::tripChanged, [&](){
        settings->setValue("trip", dash.trip());
    });

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("dash", &dash);
    engine.load(u"qrc:/KeyDash_NX1000/Main.qml"_s);

    if (engine.rootObjects().isEmpty()) return -1;
    return app.exec();
}
