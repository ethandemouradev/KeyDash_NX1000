// io_bridge.cpp 1
#include "io_bridge.h"

IOBridge::IOBridge(QObject* parent) : QObject(parent) {}

void IOBridge::setTurnLeft(bool v) {
    if (m_turnLeft == v) return;
    m_turnLeft = v;
    emit turnLeftChanged();
}

void IOBridge::setTurnRight(bool v) {
    if (m_turnRight == v) return;
    m_turnRight = v;
    emit turnRightChanged();
}

void IOBridge::setBrake(bool v) {
    if (m_brake == v) return;
    m_brake = v;
    emit brakeChanged();
}

void IOBridge::setHazard(bool v) {
    if (m_hazard == v) return;
    m_hazard = v;
    emit hazardChanged();
}
