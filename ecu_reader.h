#pragma once
#include <QObject>
#include <QtBluetooth/QBluetoothAddress>
#include <QtBluetooth/QBluetoothUuid>
#include <QtBluetooth/QBluetoothSocket>
#include <QtBluetooth/QBluetoothDeviceDiscoveryAgent>
#include <QtBluetooth/QBluetoothLocalDevice>
#include <QVariant>
#include <QHash>
#include <QStringList>

struct ChannelInfo {
    QString name;
    QString storage;     // "word", "sword", "ubyte", "sbyte", "percent7"
    double  divider = 1; // may be negative in XML
    double  offset  = 0;
    QString unit;
};

class EcuReader : public QObject {
    Q_OBJECT

    // Live channels for QML
    Q_PROPERTY(int rpm     READ rpm     NOTIFY rpmChanged)
    Q_PROPERTY(int map     READ map     NOTIFY mapChanged)
    Q_PROPERTY(int tps     READ tps     NOTIFY tpsChanged)
    Q_PROPERTY(double batt READ batt    NOTIFY battChanged)
    Q_PROPERTY(int iat     READ iat     NOTIFY iatChanged)
    Q_PROPERTY(int clt     READ clt     NOTIFY cltChanged)
    Q_PROPERTY(double afr  READ afr     NOTIFY afrChanged)
    Q_PROPERTY(double lambda READ lambda NOTIFY lambdaChanged)
    Q_PROPERTY(int baro    READ baro    NOTIFY baroChanged)

    // Connection/discovery state (note READ is now isConnected)
    Q_PROPERTY(bool connected READ isConnected WRITE setConnected NOTIFY connectionChanged)
    Q_PROPERTY(bool scanning  READ scanning                        NOTIFY scanningChanged)
    Q_PROPERTY(QStringList devices READ devices                    NOTIFY devicesChanged)

public:
    explicit EcuReader(QObject* parent=nullptr);

    // Connection control
    Q_INVOKABLE void setDeviceAddress(const QString& btAddr);  // "XX:XX:XX:XX:XX:XX"
    Q_INVOKABLE QString deviceAddress() const { return m_address.toString(); }
    Q_INVOKABLE void connectToDevice();
    Q_INVOKABLE void disconnectDevice();
    Q_INVOKABLE bool isConnected() const { return m_connected; }  // <— renamed getter

    // XML channel map
    Q_INVOKABLE bool loadXmlMap(const QString& urlOrPath);
    Q_INVOKABLE QString connectionError() const { return m_lastError; }

    // Discovery
    Q_INVOKABLE void startScan();
    Q_INVOKABLE void stopScan();
    Q_INVOKABLE void connectToName(const QString& nameOrSubstring);

    // Current values
    int rpm() const    { return m_rpm; }
    int map() const    { return m_map; }
    int tps() const    { return m_tps; }
    double batt() const{ return m_batt; }
    int iat() const    { return m_iat; }
    int clt() const    { return m_clt; }
    double afr() const { return m_afr; }
    double lambda() const { return m_lambda; }
    int baro() const   { return m_baro; }

    // Discovery properties
    bool scanning() const { return m_scanning; }
    QStringList devices() const { return m_devicesList; }

signals:
    // Value updates
    void rpmChanged();
    void mapChanged();
    void tpsChanged();
    void battChanged();
    void iatChanged();
    void cltChanged();
    void afrChanged();
    void lambdaChanged();
    void baroChanged();

    // Connection state (single canonical signal)
    void connectionChanged(bool connected);

    // Legacy compatibility signals (optional)
    void connectedLegacy();     // emitted when connection becomes true
    void disconnectedLegacy();  // emitted when connection becomes false

    // Errors (supports optional code for your overlay)
    void errorChanged(const QString& msg, const QVariant& code = QVariant());

    // Discovery state
    void scanningChanged();
    void devicesChanged();

    // Diagnostics
    void info(const QString& message);
    void warn(const QString& message);

private slots:
    // Socket handlers
    void onReadyRead();
    void onStateChanged(QBluetoothSocket::SocketState);
    void onErrorOccurred(QBluetoothSocket::SocketError);

    // Discovery handlers
    void setConnected(bool v) {
        if (m_connected == v) return;
        m_connected = v;
        emit connectionChanged(m_connected);
        if (m_connected) emit connectedLegacy(); else emit disconnectedLegacy();
    }
    void onDeviceFound(const QBluetoothDeviceInfo& info);
    void onScanFinished();
    void onScanError(QBluetoothDeviceDiscoveryAgent::Error error);

private:
    void parseIncoming();
    bool tryExtractFrame(int& ch, quint8& vh, quint8& vl, quint8& cs);
    static bool checksumOk(quint8 ch, quint8 vh, quint8 vl, quint8 cs, int mod);
    static qint32 decodeRaw(const QString& storage, quint8 vh, quint8 vl);
    static double scaleValue(const ChannelInfo& info, qint32 raw);
    void applyChannel(int ch, double value);

    // State
    int m_baro = 100;
    bool m_connected = false;

    // BT
    QScopedPointer<QBluetoothSocket> m_socket;
    QScopedPointer<QBluetoothDeviceDiscoveryAgent> m_agent;
    QBluetoothLocalDevice m_local;
    QBluetoothAddress m_address;

    // Discovery cache
    QList<QBluetoothDeviceInfo> m_found;
    QStringList m_devicesList;
    bool m_scanning = false;

    // Decode buffer/map
    QByteArray m_buf;
    QHash<int, ChannelInfo> m_chmap;

    // Latest values
    int m_rpm=0, m_map=0, m_tps=0, m_iat=0, m_clt=0;
    double m_batt=0.0, m_afr=0.0, m_lambda=0.0;

    // Last error text
    QString m_lastError;
};
