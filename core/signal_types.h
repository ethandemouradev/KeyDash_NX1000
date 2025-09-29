#pragma once
#include <QString>
#include <QMetaType>
#include <QtGlobal>

struct SignalUpdate {
    QString name;     // e.g., "Engine.RPM"
    double value{0};  // normalized numeric
    qint64 t_ms{0};   // epoch ms
};
Q_DECLARE_METATYPE(SignalUpdate)
