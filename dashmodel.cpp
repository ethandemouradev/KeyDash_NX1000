#include "dashmodel.h"
#include <QSettings>
#include <QVariantMap>
#include <QtMath>

DashModel::DashModel(QObject *parent)
    : QObject(parent), m_gears(10, 0.0) // allow gears 1..9 by default
{
  // Default gear ratios (optional)
  m_gears[1] = 3.321;
  m_gears[2] = 1.902;
  m_gears[3] = 1.308;
  m_gears[4] = 1.000;
  m_gears[5] = 0.891;
  // m_gears[6].. as needed
}

void DashModel::setUseMph(bool v) {
  if (m_useMph == v)
    return;
  m_useMph = v;
  emit useMphChanged();
}

void DashModel::setRpmMax(int v) {
  // clamp to something sensible
  if (v < 1000)
    v = 1000;
  if (m_rpmMax == v)
    return;
  m_rpmMax = v;
  emit rpmMaxChanged();
}

void DashModel::setFinalDrive(double v) {
  if (qFuzzyCompare(m_finalDrive, v))
    return;
  m_finalDrive = v;
  emit finalDriveChanged();
}

void DashModel::setGearRatio(int gear, double ratio) {
  if (gear < 1)
    return;
  if (gear >= m_gears.size())
    m_gears.resize(gear + 1);

  if (qFuzzyCompare(m_gears[gear], ratio))
    return;
  m_gears[gear] = ratio;
  emit gearRatioChanged(gear, ratio);
}

double DashModel::gearRatio(int gear) const {
  if (gear < 1 || gear >= m_gears.size())
    return 0.0;
  return m_gears[gear];
}

bool DashModel::loadVehicleConfig(const QString &path) {
  QSettings ini(path, QSettings::IniFormat);
  if (ini.status() != QSettings::NoError)
    return false;

  ini.beginGroup("vehicle");
  setFinalDrive(ini.value("final_drive", m_finalDrive).toDouble());
  setUseMph(ini.value("use_mph", m_useMph).toBool());
  setRpmMax(ini.value("rpm_max", m_rpmMax).toInt());

  // read gear1..gear10 if present
  for (int g = 1; g <= 10; ++g) {
    const QString key = QStringLiteral("gear%1").arg(g);
    if (ini.contains(key))
      setGearRatio(g, ini.value(key).toDouble());
  }
  ini.endGroup();
  return true;
}

/* Replay support */

// (1) Inform UI when replay mode is active (optionally toggle connected banner)
void DashModel::setReplayMode(bool on) {
  m_replayMode = on;
  // Choose behavior you prefer:
  // If you want the ECU banner to show “disconnected” during replay:
  setConnected(!on);
  // Otherwise: comment the line above out.
}

// Helper: read numbers safely from a QVariantMap
static inline double getNum(const QVariantMap &m, const char *key,
                            double def = qQNaN()) {
  auto it = m.constFind(QString::fromLatin1(key));
  if (it == m.constEnd())
    return def;
  bool ok = false;
  double v = it.value().toDouble(&ok);
  return ok ? v : def;
}

// (2) Ingest a replay frame (called by ReplayPage)
void DashModel::ingestFrame(const QVariantMap &f) {
  // Extract commonly-logged fields (matches LogParser.normalizeRow()).
  const double rpm = qIsNaN(getNum(f, "rpm")) ? m_rpm : getNum(f, "rpm");
  const double mph = getNum(f, "speed");         // optional if your log has it
  const double mapk = getNum(f, "map");          // kPa (absolute)
  const double boostLogged = getNum(f, "boost"); // psi (gauge), optional
  const double clt = qIsNaN(getNum(f, "clt")) ? m_clt : getNum(f, "clt");
  const double iat = qIsNaN(getNum(f, "iat")) ? m_iat : getNum(f, "iat");
  const double afr = qIsNaN(getNum(f, "afr")) ? m_afr : getNum(f, "afr");
  const double vbat = qIsNaN(getNum(f, "batt")) ? m_vbat : getNum(f, "batt");
  const double gearV = getNum(f, "gear"); // optional if present

  // Derive boost from MAP if needed: boost_psi = max(0, (MAP_kPa - 101.325) * 0.1450377)
  double boostPsi = boostLogged;
  if (qIsNaN(boostPsi) && !qIsNaN(mapk)) {
    boostPsi = qMax(0.0, (mapk - 101.325) * 0.1450377377);
  } else if (qIsNaN(boostPsi)) {
    boostPsi = m_boost; // keep prior if neither present
  }

  const double useMph = qIsNaN(mph) ? m_speed : mph;
  const int useGear = qIsNaN(gearV) ? m_gear : int(qRound(gearV));

  // Reuse smoothing and setters so UI reacts like live data.
  applySample(rpm,      // rpm
              useMph,   // speed
              boostPsi, // boost (psi gauge)
              clt,      // coolant °C
              iat,      // intake °C
              vbat,     // volts
              afr,      // afr
              useGear   // gear
  );

  // Optional: set indicator flags from log fields if present:
  // setCelOn(f.value("cel").toBool());
  // setTcsOn(f.value("tcs").toBool());
  // setHeadlightsOn(f.value("hl").toBool());
}
