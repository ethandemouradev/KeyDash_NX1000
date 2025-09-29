#pragma once
#include <QObject>
#include "signal_types.h"

class ITransport;

class IECUProtocol : public QObject {
    Q_OBJECT
  public:
    using QObject::QObject;
    virtual ~IECUProtocol() = default;

           // Quick sniff: is this protocol present on this transport?
    virtual bool probe(ITransport *t) = 0;

           // Begin decoding (connect to transport signals, start polling if needed)
    virtual bool start(ITransport *t) = 0;
    virtual void stop() = 0;
    virtual QString name() const = 0;

  signals:
    void sig(const SignalUpdate &update); // normalized signals to data model
    void statusChanged(const QString &status);
};
