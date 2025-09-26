#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>
#include <QTimer>
#include <QCursor>
#include <QDateTime>
#include <QStandardPaths>
#include <QFile>
#include <QDir>
#include <QLockFile>
#include <algorithm>

#include "FileReader.h"
#include "dashmodel.h"
#include "ecu_reader.h"
#include "crashlog.h"

#ifdef HAVE_SERIALPORT
#include "serialworker.h"
#endif

using namespace Qt::StringLiterals;

static inline double smooth(double prev, double now, double alpha) {
    if (alpha < 0.0) alpha = 0.0;
    if (alpha > 1.0) alpha = 1.0;
    return prev * (1.0 - alpha) + now * alpha;
}

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName("KeyDash");
    QCoreApplication::setOrganizationDomain("keydash.local");
    QCoreApplication::setApplicationVersion("0.1.0");
    QCoreApplication::setApplicationName("KeyDash_NX1000");

    // Start crash logging *very* early
    CrashLog::init(QStringLiteral("KeyDash_NX1000"), QStringLiteral("1.0.0"));

    QGuiApplication app(argc, argv);

    // (Optional) enforce single instance
    const QString lockDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(lockDir);
    QLockFile lock(lockDir + "/KeyDash.lock");
    lock.setStaleLockTime(0);
    if (!lock.tryLock(100)) {
        // Another instance is running; exit quietly
        return 0;
    }

#ifndef QT_DEBUG
    QLoggingCategory::setFilterRules(QStringLiteral("*.debug=false"));
#endif

    // Settings storage
    QSettings settings(QSettings::IniFormat, QSettings::UserScope,
                       QCoreApplication::organizationName(),
                       QCoreApplication::applicationName());

    // --- Models/IO ---
    DashModel dash;
    dash.loadVehicleConfig();

    EcuReader ecu;
    ecu.loadXmlMap("qrc:/proto/version1_218.xml");

#ifdef HAVE_SERIALPORT
    SerialWorker worker(&dash);
#else
    qWarning("Qt6 SerialPort not found – running without ECU serial I/O.");
#endif

    // ---------- Clock text ----------
    QTimer clock;
    QObject::connect(&clock, &QTimer::timeout, [&]{
        dash.setDateTimeString(QDateTime::currentDateTime().toString("dddd, MMM d\nh:mmap"));
    });
    clock.start(1000);
    dash.setDateTimeString(QDateTime::currentDateTime().toString("dddd, MMM d\nh:mmap"));

    // ---------- Restore odo/trip ----------
    dash.setOdo(settings.value("odo", dash.odo()).toDouble());
    dash.setTrip(settings.value("trip", dash.trip()).toDouble());
    QObject::connect(&dash, &DashModel::odoChanged, [&]{ settings.setValue("odo", dash.odo()); });
    QObject::connect(&dash, &DashModel::tripChanged, [&]{ settings.setValue("trip", dash.trip()); });

    // ---------- Defaults (optional) ----------
    {
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
    }

    // ==========================================================
    //                ECU → DashModel bridge
    // ==========================================================
    const double KPA_TO_PSI = 0.14503773773020923;
    auto readAlpha = [&](const char* key, double def) {
        return settings.value(QStringLiteral("KeyDash/") + key, def).toDouble();
    };

    QObject::connect(&ecu, &EcuReader::rpmChanged, &app, [&](){
        dash.setRpm(smooth(dash.rpm(), ecu.rpm(), readAlpha("smoothRpm", 0.35)));
    });
    QObject::connect(&ecu, &EcuReader::mapChanged, &app, [&](){
        double baroKpa = settings.value("KeyDash/baroKpa", 101.3).toDouble();
        int propIdx = ecu.metaObject()->indexOfProperty("baro");
        if (propIdx >= 0) {
            QVariant v = ecu.metaObject()->property(propIdx).read(&ecu);
            if (v.isValid()) baroKpa = v.toDouble();
        }
        const double boostPsi = (ecu.map() - baroKpa) * KPA_TO_PSI;
        dash.setBoost(smooth(dash.boost(), boostPsi, readAlpha("smoothBoost", 0.25)));
    });
    QObject::connect(&ecu, &EcuReader::cltChanged,  &app, [&](){ dash.setClt (smooth(dash.clt(),  ecu.clt(),  readAlpha("smoothClt",  0.25))); });
    QObject::connect(&ecu, &EcuReader::iatChanged,  &app, [&](){ dash.setIat (smooth(dash.iat(),  ecu.iat(),  readAlpha("smoothIat",  0.25))); });
    QObject::connect(&ecu, &EcuReader::battChanged, &app, [&](){ dash.setVbat(smooth(dash.vbat(), ecu.batt(), readAlpha("smoothVbat", 0.30))); });
    QObject::connect(&ecu, &EcuReader::afrChanged,  &app, [&](){ dash.setAfr (smooth(dash.afr(),  ecu.afr(),  readAlpha("smoothAfr",  0.30))); });

    // ==========================================================
    //       Auto-connect on startup
    // ==========================================================
    {
        const QString btAddr = settings.value("KeyDash/bt_addr").toString();
        if (!btAddr.isEmpty()) {
            ecu.setDeviceAddress(btAddr);
            ecu.connectToDevice();
        }
    }
    QObject::connect(&ecu, &EcuReader::connectionChanged, &app, [&](bool ok){
        if (ok) settings.setValue("KeyDash/bt_addr", ecu.deviceAddress());
    });

    // ==========================================================
    //        Auto-reconnect / on wake
    // ==========================================================
    int pendingReconnects = 0;
    QPointer<QTimer> reconnectTimer;
    auto scheduleReconnect = [&](int tries, int backoffMs) {
        if (tries <= 0) return;
        pendingReconnects = tries;
        if (!reconnectTimer) {
            reconnectTimer = new QTimer(&app);
            reconnectTimer->setSingleShot(true);
            QObject::connect(reconnectTimer, &QTimer::timeout, &app, [&](){
                if (ecu.isConnected()) return;
                ecu.connectToDevice();
                if (--pendingReconnects > 0) {
                    int backoff = settings.value("KeyDash/autoReconnectBackoffMs", backoffMs).toInt();
                    reconnectTimer->start(std::max(100, backoff));
                }
            });
        }
        reconnectTimer->start(std::max(100, backoffMs));
    };
    QObject::connect(&ecu, &EcuReader::disconnectedLegacy, &app, [&](){
        const int tries   = settings.value("KeyDash/autoReconnectTries", 5).toInt();
        const int backoff = settings.value("KeyDash/autoReconnectBackoffMs", 2000).toInt();
        scheduleReconnect(tries, backoff);
    });
    QObject::connect(&app, &QGuiApplication::applicationStateChanged, [&](Qt::ApplicationState st){
        if (st == Qt::ApplicationActive) {
            if (settings.value("KeyDash/reconnectOnWake", true).toBool() && !ecu.isConnected())
                ecu.connectToDevice();
        }
    });

    // ==========================================================
    //                   CSV Session logging
    // ==========================================================
    QFile logFile;
    QTimer logTimer;

    auto writeHeader = [&](QFile& f){
        static const QByteArray hdr =
            "ts_ms,rpm,speed,useMph,boost,clt,iat,vbat,afr,gear,map,baro\n";
        f.write(hdr);
    };
    auto openLogFile = [&]()->bool{
        QString dir = settings.value("KeyDash/logDir").toString();
        if (dir.isEmpty())
            dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir().mkpath(dir);
        const QString path = dir + QDir::separator()
                             + QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss") + ".csv";
        logFile.setFileName(path);
        if (!logFile.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            qWarning("Could not open log file");
            return false;
        }
        writeHeader(logFile);
        return true;
    };
    auto updateLogTimer = [&](){
        logTimer.stop();
        const bool on = settings.value("KeyDash/logEnabled", false).toBool();
        int hz = std::clamp(settings.value("KeyDash/logHz", 10).toInt(), 1, 50);
        if (!on) { if (logFile.isOpen()) logFile.close(); return; }
        if (!logFile.isOpen()) if (!openLogFile()) return;
        logTimer.start(1000 / hz);
    };
    QObject::connect(&logTimer, &QTimer::timeout, &app, [&](){
        if (!logFile.isOpen()) return;
        double baroKpa = settings.value("KeyDash/baroKpa", 101.3).toDouble();
        int propIdx = ecu.metaObject()->indexOfProperty("baro");
        if (propIdx >= 0) {
            QVariant v = ecu.metaObject()->property(propIdx).read(&ecu);
            if (v.isValid()) baroKpa = v.toDouble();
        }
        const qint64 t = QDateTime::currentMSecsSinceEpoch();
        QByteArray row;
        row.reserve(200);
        row.append(QByteArray::number(t)).append(',');
        row.append(QByteArray::number(dash.rpm())).append(',');
        row.append(QByteArray::number(dash.speed())).append(',');
        row.append(dash.useMph() ? "1," : "0,");
        row.append(QByteArray::number(dash.boost())).append(',');
        row.append(QByteArray::number(dash.clt())).append(',');
        row.append(QByteArray::number(dash.iat())).append(',');
        row.append(QByteArray::number(dash.vbat())).append(',');
        row.append(QByteArray::number(dash.afr())).append(',');
        row.append(QByteArray::number(dash.gear())).append(',');
        row.append(QByteArray::number(ecu.map())).append(',');
        row.append(QByteArray::number(baroKpa)).append('\n');
        logFile.write(row);
    });
    QTimer prefsPoll; prefsPoll.setInterval(2000);
    QObject::connect(&prefsPoll, &QTimer::timeout, &app, updateLogTimer);
    prefsPoll.start();
    updateLogTimer();

    // ==========================================================
    //                     QML Engine
    // ==========================================================
    QQmlApplicationEngine engine;

    FileReader fs;
    engine.rootContext()->setContextProperty("Fs", &fs);
    engine.rootContext()->setContextProperty("fileReader", &fs);
    engine.rootContext()->setContextProperty("FileReader", &fs);
    engine.rootContext()->setContextProperty("dash", &dash);
    engine.rootContext()->setContextProperty("ecu",  &ecu);

    const QUrl url(u"qrc:/KeyDash_NX1000/Main.qml"_s);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && objUrl == url) QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);
    engine.load(url);

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
