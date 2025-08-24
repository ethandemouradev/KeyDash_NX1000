#include "dashmodel.h"
#include <QSettings>
#include <QtMath>

DashModel::DashModel(QObject* parent)
    : QObject(parent),
    m_gears(10, 0.0) // allow gears 1..9 by default
{
    // defaults (optional)
    m_gears[1] = 3.321;
    m_gears[2] = 1.902;
    m_gears[3] = 1.308;
    m_gears[4] = 1.000;
    m_gears[5] = 0.891;
    // m_gears[6].. as needed
}

void DashModel::setUseMph(bool v) {
    if (m_useMph == v) return;
    m_useMph = v;
    emit useMphChanged();
}

void DashModel::setRpmMax(int v) {
    // clamp to something sensible
    if (v < 1000) v = 1000;
    if (m_rpmMax == v) return;
    m_rpmMax = v;
    emit rpmMaxChanged();
}

void DashModel::setFinalDrive(double v) {
    if (qFuzzyCompare(m_finalDrive, v)) return;
    m_finalDrive = v;
    emit finalDriveChanged();
}

void DashModel::setGearRatio(int gear, double ratio) {
    if (gear < 1) return;
    if (gear >= m_gears.size())
        m_gears.resize(gear + 1);

    if (qFuzzyCompare(m_gears[gear], ratio)) return;
    m_gears[gear] = ratio;
    emit gearRatioChanged(gear, ratio);
}

double DashModel::gearRatio(int gear) const {
    if (gear < 1 || gear >= m_gears.size()) return 0.0;
    return m_gears[gear];
}

bool DashModel::loadVehicleConfig(const QString& path) {
    QSettings ini(path, QSettings::IniFormat);
    if (ini.status() != QSettings::NoError) return false;

    ini.beginGroup("vehicle");
    setFinalDrive(ini.value("final_drive", m_finalDrive).toDouble());
    setUseMph(ini.value("use_mph", m_useMph).toBool());
    setRpmMax(ini.value("rpm_max", m_rpmMax).toInt());

    // read gear1..gear10 if present
    for (int g = 1; g <= 10; ++g) {
        const QString key = QStringLiteral("gear%1").arg(g);
        if (ini.contains(key)) setGearRatio(g, ini.value(key).toDouble());
    }
    ini.endGroup();
    return true;
}
