#pragma once
#include <QObject>
#include <QString>

class DashModel : public QObject {
    Q_OBJECT

    Q_PROPERTY(double  speed READ speed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(double  rpm   READ rpm   WRITE setRpm   NOTIFY rpmChanged)
    Q_PROPERTY(double  boost READ boost WRITE setBoost NOTIFY boostChanged)
    Q_PROPERTY(double  clt   READ clt   WRITE setClt   NOTIFY cltChanged)
    Q_PROPERTY(double  iat   READ iat   WRITE setIat   NOTIFY iatChanged)
    Q_PROPERTY(double  vbat  READ vbat  WRITE setVbat  NOTIFY vbatChanged)
    Q_PROPERTY(double  afr   READ afr   WRITE setAfr   NOTIFY afrChanged)
    Q_PROPERTY(int     gear  READ gear  WRITE setGear  NOTIFY gearChanged)
    Q_PROPERTY(QString dateTimeString READ dateTimeString WRITE setDateTimeString NOTIFY dateTimeChanged)
    Q_PROPERTY(double  odo   READ odo  WRITE setOdo  NOTIFY odoChanged)
    Q_PROPERTY(double  trip  READ trip WRITE setTrip NOTIFY tripChanged)

    // NEW: indicator flags
    Q_PROPERTY(bool leftSignal   READ leftSignal   WRITE setLeftSignal   NOTIFY leftSignalChanged)
    Q_PROPERTY(bool rightSignal  READ rightSignal  WRITE setRightSignal  NOTIFY rightSignalChanged)
    Q_PROPERTY(bool headlightsOn READ headlightsOn WRITE setHeadlightsOn NOTIFY headlightsOnChanged)
    Q_PROPERTY(bool celOn        READ celOn        WRITE setCelOn        NOTIFY celOnChanged)
    Q_PROPERTY(bool tcsOn        READ tcsOn        WRITE setTcsOn        NOTIFY tcsOnChanged)

    // QML-visible properties
    Q_PROPERTY(bool   useMph     READ useMph     WRITE setUseMph     NOTIFY useMphChanged)
    Q_PROPERTY(int    rpmMax     READ rpmMax     WRITE setRpmMax     NOTIFY rpmMaxChanged)
    Q_PROPERTY(double finalDrive READ finalDrive WRITE setFinalDrive NOTIFY finalDriveChanged)

public:
    explicit DashModel(QObject* parent=nullptr);

    // getters
    bool   useMph()     const { return m_useMph; }
    int    rpmMax()     const { return m_rpmMax; }
    double finalDrive() const { return m_finalDrive; }
    double  speed() const { return m_speed; }
    double  rpm()   const { return m_rpm; }
    double  boost() const { return m_boost; }
    double  clt()   const { return m_clt; }
    double  iat()   const { return m_iat; }
    double  vbat()  const { return m_vbat; }
    double  afr()   const { return m_afr; }
    int     gear()  const { return m_gear; }
    QString dateTimeString() const { return m_dt; }
    double  odo()   const { return m_odo; }
    double  trip()  const { return m_trip; }
    bool    leftSignal()   const { return m_leftSignal; }
    bool    rightSignal()  const { return m_rightSignal; }
    bool    headlightsOn() const { return m_headlightsOn; }
    bool    celOn()        const { return m_celOn; }
    bool    tcsOn()        const { return m_tcsOn; }

    Q_INVOKABLE double gearRatio(int gear) const;

public slots:
    // setters
    void setUseMph(bool v);
    void setRpmMax(int v);
    void setFinalDrive(double v);
    void setSpeed(double v){ if (v!=m_speed){ m_speed=v; emit speedChanged(); } }
    void setRpm(double v){ if (v!=m_rpm){ m_rpm=v; emit rpmChanged(); } }
    void setBoost(double v){ if (v!=m_boost){ m_boost=v; emit boostChanged(); } }
    void setClt(double v){ if (v!=m_clt){ m_clt=v; emit cltChanged(); } }
    void setIat(double v){ if (v!=m_iat){ m_iat=v; emit iatChanged(); } }
    void setVbat(double v){ if (v!=m_vbat){ m_vbat=v; emit vbatChanged(); } }
    void setAfr(double v){ if (v!=m_afr){ m_afr=v; emit afrChanged(); } }
    void setGear(int v){ if (v!=m_gear){ m_gear=v; emit gearChanged(); } }
    void setDateTimeString(const QString& s){ if (s!=m_dt){ m_dt=s; emit dateTimeChanged(); } }
    void setOdo(double v){ if (v!=m_odo){ m_odo=v; emit odoChanged(); } }
    void setTrip(double v){ if (v!=m_trip){ m_trip=v; emit tripChanged(); } }
    void setLeftSignal(bool v){ if (v!=m_leftSignal){ m_leftSignal=v; emit leftSignalChanged(); } }
    void setRightSignal(bool v){ if (v!=m_rightSignal){ m_rightSignal=v; emit rightSignalChanged(); } }
    void setHeadlightsOn(bool v){ if (v!=m_headlightsOn){ m_headlightsOn=v; emit headlightsOnChanged(); } }
    void setCelOn(bool v){ if (v!=m_celOn){ m_celOn=v; emit celOnChanged(); } }
    void setTcsOn(bool v){ if (v!=m_tcsOn){ m_tcsOn=v; emit tcsOnChanged(); } }

    // helper to update multiple values at once (with light smoothing)
    void applySample(double rpm, double mph, double boost, double clt,
                     double iat, double vbat, double afr, int gear) {
        auto sm = [](double p, double c){ return p*0.7 + c*0.3; };
        setRpm(sm(m_rpm, rpm));    setSpeed(sm(m_speed, mph));
        setBoost(sm(m_boost, boost));
        setClt(sm(m_clt, clt));    setIat(sm(m_iat, iat));
        setVbat(sm(m_vbat, vbat)); setAfr(sm(m_afr, afr));
        setGear(gear);
    }

    // set individual gear ratio (1-based)
    Q_INVOKABLE void setGearRatio(int gear, double ratio);

    // optional: load /etc/keydash/keydash.ini at boot
    Q_INVOKABLE bool loadVehicleConfig(const QString& path = QStringLiteral("/etc/keydash/keydash.ini"));

public:
    Q_INVOKABLE void resetTrip() { setTrip(0); }

signals:
    void speedChanged();
    void rpmChanged();
    void boostChanged();
    void cltChanged();
    void iatChanged();
    void vbatChanged();
    void afrChanged();
    void gearChanged();
    void dateTimeChanged();
    void odoChanged();
    void tripChanged();
    // NEW signals
    void leftSignalChanged();
    void rightSignalChanged();
    void headlightsOnChanged();
    void celOnChanged();
    void tcsOnChanged();
    void useMphChanged();
    void rpmMaxChanged();
    void finalDriveChanged();
    void gearRatioChanged(int gear, double ratio);

private:
    double  m_speed=0, m_rpm=0, m_boost=0, m_clt=82, m_iat=27, m_vbat=14.2, m_afr=14.7;
    int     m_gear=5;
    QString m_dt;
    double  m_odo=13400;
    double  m_trip=0.0;
    bool   m_useMph     = true;
    int    m_rpmMax     = 8000;
    double m_finalDrive = 4.080;

    // NEW: indicator state
    bool m_leftSignal=false;
    bool m_rightSignal=false;
    bool m_headlightsOn=false;
    bool m_celOn=false;
    bool m_tcsOn=false;

    QVector<double> m_gears; // will size in ctor (e.g., 10 entries)
};
