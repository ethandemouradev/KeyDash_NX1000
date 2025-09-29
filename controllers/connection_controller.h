#pragma once
#include <QObject>
#include <QPointer>
#include "core/ecu_manager.h"
#include "core/signal_types.h"

class ITransport;
class IECUProtocol;

class ConnectionController : public QObject {
    Q_OBJECT
  public:
    explicit ConnectionController(QObject *parent=nullptr);
    ~ConnectionController();

           // QML calls this when you press “Apply & Connect”
    Q_INVOKABLE bool apply(const QString &transportKey,
                           const QString &portName, int baud,
                           const QString &canIface,
                           const QString &protoKey);

  signals:
    void sig(const SignalUpdate &update);
    void statusChanged(const QString &status);

  private:
    QPointer<EcuManager> m_mgr;
    QScopedPointer<ITransport> m_transport;
    QScopedPointer<IECUProtocol> m_protocol;

    bool setupTransport(const QString &transportKey, const QString &portName, int baud, const QString &canIface);
    bool setupProtocol(const QString &protoKey);
};
