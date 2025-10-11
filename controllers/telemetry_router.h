#pragma once
#include <QObject>


class TelemetryRouter : public QObject {
    Q_OBJECT
    Q_PROPERTY(Mode mode READ mode WRITE setMode NOTIFY modeChanged)
  public:
    enum Mode { Live, Sample, Replay }; Q_ENUM(Mode)
    explicit TelemetryRouter(QObject* parent=nullptr);
    Mode mode() const { return m_mode; }
    void setMode(Mode m);


  signals:
    void modeChanged();
    // Forwarded telemetry signals
    void rpmChanged(int);
    void tpsChanged(double);
    void mapChanged(double);
    // ... add others


  public slots:
    void onLiveUpdate(/* struct Telemetry t */);
    void onSampleUpdate(/* ... */);
    void onReplayUpdate(/* ... */);


  private:
    Mode m_mode{Live};
    bool m_livePaused{false};
};
