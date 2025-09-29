#pragma once
#include <QObject>
#include <QScopedPointer>
#include "core/iecuprotocol.h"

class ITransport;

class EcuManager : public QObject {
    Q_OBJECT
  public:
    explicit EcuManager(QObject *parent=nullptr);
    ~EcuManager();

           // Ownership stays here; you can expose setters for UI
    void setTransport(ITransport *t);   // injected from app
    void setProtocol(IECUProtocol *p);  // pick specific
    bool start();
    void stop();

  signals:
    void sig(const SignalUpdate &update);
    void statusChanged(const QString&);

  private:
    ITransport *m_t{nullptr};
    QScopedPointer<IECUProtocol> m_p;
};
