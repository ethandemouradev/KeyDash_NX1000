// io_bridge.h
#pragma once
#include <QObject>

class IOBridge : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool turnLeft READ turnLeft NOTIFY turnLeftChanged)
    Q_PROPERTY(bool turnRight READ turnRight NOTIFY turnRightChanged)
    Q_PROPERTY(bool brake READ brake NOTIFY brakeChanged)
    Q_PROPERTY(bool hazard READ hazard NOTIFY hazardChanged)

  public:
    explicit IOBridge(QObject* parent=nullptr);

    bool turnLeft() const { return m_turnLeft; }
    bool turnRight() const { return m_turnRight; }
    bool brake() const { return m_brake; }
    bool hazard() const { return m_hazard; }

  public slots:
    void setTurnLeft(bool v);
    void setTurnRight(bool v);
    void setBrake(bool v);
    void setHazard(bool v);

  signals:
    void turnLeftChanged();
    void turnRightChanged();
    void brakeChanged();
    void hazardChanged();

  private:
    bool m_turnLeft{false};
    bool m_turnRight{false};
    bool m_brake{false};
    bool m_hazard{false};
};
