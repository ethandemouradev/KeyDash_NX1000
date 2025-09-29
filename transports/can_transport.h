#pragma once
#include "core/itransport.h"
#include <QObject>
#include <QPointer>

class QCanBusDevice;

class CanTransport : public ITransport {
    Q_OBJECT
  public:
    explicit CanTransport(const QString &iface = "can0", const QString &plugin = "socketcan",
                          QObject *parent=nullptr)
        : ITransport(parent), m_iface(iface), m_plugin(plugin) {}

    bool open() override;
    void close() override;
    bool isOpen() const override;

           // Optional: write CAN frame
    bool write(quint32 id, const QByteArray &payload);

  private:
    QString m_iface, m_plugin;
    QPointer<QCanBusDevice> m_dev;

  private slots:
    void onFramesReceived();
};
