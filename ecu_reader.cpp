#include "ecu_reader.h"
#include "ecu_reader.h"
// ECU reader implementation: handles Bluetooth discovery, RFCOMM socket I/O,
// frame extraction and mapping channel IDs to named properties for QML.
// Comments updated for clarity only; no functional changes.
#include <QFile>
#include <QOperatingSystemVersion>
#include <QRegularExpression>
#include <QUrl>
#include <QXmlStreamReader>
#include <QtBluetooth/QBluetoothSocket>
#include <QtBluetooth/QBluetoothUuid>
#include <QtMath>

static constexpr quint8 ID_CHAR = 0xA3;
static const QBluetoothUuid
    SPP_UUID("{00001101-0000-1000-8000-00805F9B34FB}"); // RFCOMM SPP

EcuReader::EcuReader(QObject *parent) : QObject(parent) {
  // Discovery agent (Classic BT; BlueZ on Pi)
  m_agent.reset(new QBluetoothDeviceDiscoveryAgent(this));
  connect(m_agent.get(), &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
          this, &EcuReader::onDeviceFound);
  connect(m_agent.get(), &QBluetoothDeviceDiscoveryAgent::finished, this,
          &EcuReader::onScanFinished);
  connect(m_agent.get(), &QBluetoothDeviceDiscoveryAgent::canceled, this,
          &EcuReader::onScanFinished);
#if QT_VERSION >= QT_VERSION_CHECK(6, 4, 0)
  connect(m_agent.get(), &QBluetoothDeviceDiscoveryAgent::errorOccurred, this,
          &EcuReader::onScanError);
#else
  connect(m_agent.get(),
          qOverload<QBluetoothDeviceDiscoveryAgent::Error>(
              &QBluetoothDeviceDiscoveryAgent::error),
          this, &EcuReader::onScanError);
#endif
}

void EcuReader::setDeviceAddress(const QString &btAddr) {
  m_address = QBluetoothAddress(btAddr);
}

void EcuReader::connectToDevice() {
  if (!m_address.isNull()) {
    if (!m_socket)
      m_socket.reset(
          new QBluetoothSocket(QBluetoothServiceInfo::RfcommProtocol));

    // Reconnect signals every time (safe)
    disconnect(m_socket.get(), nullptr, this, nullptr);
    connect(m_socket.get(), &QBluetoothSocket::readyRead, this,
            &EcuReader::onReadyRead);
    connect(m_socket.get(), &QBluetoothSocket::stateChanged, this,
            &EcuReader::onStateChanged);
    connect(m_socket.get(), &QBluetoothSocket::errorOccurred, this,
            &EcuReader::onErrorOccurred);

    m_buf.clear();
    m_socket->connectToService(m_address, SPP_UUID);
    emit info(QString("Connecting to %1 ...").arg(m_address.toString()));
  } else {
    m_lastError = QStringLiteral("No Bluetooth address set");
    emit errorChanged(m_lastError);
  }
}

void EcuReader::disconnectDevice() {
  if (m_socket)
    m_socket->disconnectFromService();
}

bool EcuReader::loadXmlMap(const QString &urlOrPath) {
  QString path = urlOrPath;
  if (urlOrPath.startsWith("qrc:") || urlOrPath.startsWith(":/")) {
    // use as-is
  } else if (urlOrPath.startsWith("file:")) {
    path = QUrl(urlOrPath).toLocalFile();
  }
  QFile f(path);
  if (!f.open(QIODevice::ReadOnly)) {
    m_lastError = QString("Failed to open XML: %1").arg(path);
    emit errorChanged(m_lastError);
    return false;
  }

  m_chmap.clear();
  QXmlStreamReader xr(&f);
  while (!xr.atEnd()) {
    xr.readNext();
    if (xr.isStartElement() && xr.name() == QLatin1String("symbol")) {
      auto a = xr.attributes();
      if (!a.hasAttribute("channel"))
        continue;
      int ch = a.value("channel").toInt();
      ChannelInfo ci;
      ci.name = a.value("name").toString();
      ci.storage = a.value("storage").toString();
      ci.unit = a.value("unit").toString();
      ci.divider = a.hasAttribute("divider")
                       ? a.value("divider").toString().toDouble()
                       : 1.0;
      ci.offset = a.hasAttribute("offset")
                      ? a.value("offset").toString().toDouble()
                      : 0.0;
      m_chmap.insert(ch, ci);
    }
  }
  if (xr.hasError()) {
    m_lastError = QString("XML parse error: %1").arg(xr.errorString());
    emit errorChanged(m_lastError);
    return false;
  }
  emit info(QString("Loaded channel map (%1 symbols)").arg(m_chmap.size()));
  return true;
}

// ----- Discovery (Pi/BlueZ) -----
void EcuReader::startScan() {
  if (QOperatingSystemVersion::currentType() ==
      QOperatingSystemVersion::Windows) {
    m_lastError = "Windows: please pair ECUMaster in OS settings; app-side "
                  "scan is limited.";
    emit errorChanged(m_lastError);
    emit warn(m_lastError);
    return;
  }
  if (m_scanning)
    return;

  // Power on adapter if off
  if (m_local.isValid() &&
      m_local.hostMode() == QBluetoothLocalDevice::HostPoweredOff)
    m_local.powerOn();

  m_found.clear();
  m_devicesList.clear();
  emit devicesChanged();

  m_scanning = true;
  emit scanningChanged();

  m_agent->start(QBluetoothDeviceDiscoveryAgent::ClassicMethod);
  emit info("Bluetooth scan started");
}

void EcuReader::stopScan() {
  if (!m_scanning)
    return;
  m_agent->stop();
  m_scanning = false;
  emit scanningChanged();
  emit info("Bluetooth scan stopped");
}

void EcuReader::onDeviceFound(const QBluetoothDeviceInfo &info) {
  // Only classic-capable devices (SPP lives there)
  if (!(info.coreConfigurations() &
        QBluetoothDeviceInfo::BaseRateCoreConfiguration) &&
      !(info.coreConfigurations() &
        QBluetoothDeviceInfo::BaseRateAndLowEnergyCoreConfiguration)) {
    return;
  }
  m_found.append(info);
  const QString line =
      QString("%1 (%2)").arg(info.name(), info.address().toString());
  m_devicesList.append(line);
  emit devicesChanged();
}

void EcuReader::onScanFinished() {
  m_scanning = false;
  emit scanningChanged();
  emit info(QString("Bluetooth scan finished. Found %1 device(s).")
                .arg(m_found.size()));
}

void EcuReader::onScanError(QBluetoothDeviceDiscoveryAgent::Error error) {
  m_scanning = false;
  emit scanningChanged();
  emit warn(QString("Bluetooth scan error: %1").arg(int(error)));
}

void EcuReader::connectToName(const QString &nameOrSubstring) {
  if (m_scanning)
    stopScan();

  // If it's a MAC string, connect directly
  static const QRegularExpression macRx(
      QStringLiteral("^[0-9A-Fa-f]{2}(:[0-9A-Fa-f]{2}){5}$"));
  if (macRx.match(nameOrSubstring).hasMatch()) {
    setDeviceAddress(nameOrSubstring);
    connectToDevice();
    return;
  }

  // Pick best match by name (exact, then substring)
  auto itPick = m_found.cend();
  for (auto it = m_found.cbegin(); it != m_found.cend(); ++it) {
    const auto nm = it->name();
    if (nm.compare(nameOrSubstring, Qt::CaseInsensitive) == 0) {
      itPick = it;
      break;
    }
    if (nm.contains(nameOrSubstring, Qt::CaseInsensitive) &&
        itPick == m_found.cend())
      itPick = it;
  }
  if (itPick == m_found.cend()) {
    emit warn(QString("No device matches '%1'").arg(nameOrSubstring));
    return;
  }
  setDeviceAddress(itPick->address().toString());
  connectToDevice();
}

// ----- Socket handlers -----
void EcuReader::onStateChanged(QBluetoothSocket::SocketState st) {
  switch (st) {
  case QBluetoothSocket::SocketState::ConnectedState:
    setConnected(true); // << was: emit connected();
    emit info("Bluetooth connected");
    break;
  case QBluetoothSocket::SocketState::UnconnectedState:
    setConnected(false); // << was: emit disconnected();
    emit info("Bluetooth disconnected");
    break;
  default:
    break;
  }
}

void EcuReader::onErrorOccurred(QBluetoothSocket::SocketError) {
  m_lastError =
      m_socket ? m_socket->errorString() : QStringLiteral("Bluetooth error");
  emit errorChanged(m_lastError); // (or emit errorChanged(m_lastError, code) if
                                  // you pass codes)
  if (!isConnected())
    setConnected(false); // keep property/signals consistent
  emit warn(m_lastError);
}

void EcuReader::onReadyRead() {
  m_buf += m_socket->readAll();
  parseIncoming();
}

// ----- Frame decode -----
void EcuReader::parseIncoming() {
  int ch;
  quint8 vh, vl, cs;
  while (tryExtractFrame(ch, vh, vl, cs)) {
    const ChannelInfo info =
        m_chmap.value(ch, ChannelInfo{QString(), "word", 1.0, 0.0, QString()});
    const qint32 raw = decodeRaw(info.storage, vh, vl);
    const double val = scaleValue(info, raw);
    applyChannel(ch, val);
  }
}

bool EcuReader::tryExtractFrame(int &ch, quint8 &vh, quint8 &vl, quint8 &cs) {
  // scan buffer for a 5-byte frame with ID_CHAR at index 1
  for (int i = 0; i + 5 <= m_buf.size(); ++i) {
    const uchar B0 = uchar(m_buf[i + 0]);
    const uchar B1 = uchar(m_buf[i + 1]);
    const uchar B2 = uchar(m_buf[i + 2]);
    const uchar B3 = uchar(m_buf[i + 3]);
    const uchar B4 = uchar(m_buf[i + 4]);
    if (B1 != ID_CHAR)
      continue;
    const bool ok256 = checksumOk(B0, B2, B3, B4, 256);
    const bool ok255 = !ok256 && checksumOk(B0, B2, B3, B4, 255);
    if (!ok256 && !ok255)
      continue;
    ch = int(B0);
    vh = B2;
    vl = B3;
    cs = B4;
    m_buf.remove(0, i + 5);
    return true;
  }
  // avoid unbounded growth on garbage
  if (m_buf.size() > 4096)
    m_buf.remove(0, m_buf.size() - 1024);
  return false;
}

bool EcuReader::checksumOk(quint8 ch, quint8 vh, quint8 vl, quint8 cs,
                           int mod) {
  return ((int(ch) + int(ID_CHAR) + int(vh) + int(vl)) % mod) == cs;
}

qint32 EcuReader::decodeRaw(const QString &storage, quint8 vh, quint8 vl) {
  const QString s = storage.toLower();
  if (s == "word" || s == "sword") {
    quint16 u = (quint16(vh) << 8) | vl;
    if (s == "sword")
      return (u & 0x8000) ? (qint32(u) - 0x10000) : qint32(u);
    return qint32(u);
  }
  qint32 u8 = vl; // 8-bit signals in low byte
  if (s == "sbyte")
    return (u8 & 0x80) ? (u8 - 0x100) : u8;
  return u8; // ubyte/percent7
}

double EcuReader::scaleValue(const ChannelInfo &info, qint32 raw) {
  double v = raw;
  if (info.divider != 0.0)
    v /= info.divider;
  v += info.offset;
  return v;
}

void EcuReader::applyChannel(int ch, double v) {
  const auto info = m_chmap.value(ch);
  const QString nm = info.name.toLower();

  // BARO / Atmospheric kPa
  if (nm.contains("baro") || nm.contains("atmo")) {
    const int nv = int(qRound(v)); // v already scaled to kPa
    if (nv != m_baro) {
      m_baro = nv;
      emit baroChanged();
    }
  }
  // v1.218 key channels
  switch (ch) {
  case 1: {
    int nv = int(qRound(v));
    if (nv != m_rpm) {
      m_rpm = nv;
      emit rpmChanged();
    }
    break;
  } // RPM word/1
  case 2: {
    int nv = int(qRound(v));
    if (nv != m_map) {
      m_map = nv;
      emit mapChanged();
    }
    break;
  } // MAP kPa word/1
  case 3: {
    int nv = int(qRound(v));
    if (nv != m_tps) {
      m_tps = nv;
      emit tpsChanged();
    }
    break;
  } // TPS % ubyte/1
  case 4: {
    int nv = int(qRound(v));
    if (nv != m_iat) {
      m_iat = nv;
      emit iatChanged();
    }
    break;
  } // IAT C sbyte/1
  case 5: {
    double nv = v;
    if (qFabs(nv - m_batt) > 0.01) {
      m_batt = nv;
      emit battChanged();
    }
    break;
  } // Batt word/37 V
  case 12: {
    double nv = v;
    if (qFabs(nv - m_afr) > 0.01) {
      m_afr = nv;
      emit afrChanged();
    }
    break;
  } // AFR ubyte/10
  case 24: {
    int nv = int(qRound(v));
    if (nv != m_clt) {
      m_clt = nv;
      emit cltChanged();
    }
    break;
  } // CLT sword/1 C
  case 27: {
    double nv = v;
    if (qFabs(nv - m_lambda) > 0.001) {
      m_lambda = nv;
      emit lambdaChanged();
    }
    break;
  } // λ ubyte/128
  default:
    break;
  }
}
