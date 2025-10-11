#include "telemetry_router.h"


TelemetryRouter::TelemetryRouter(QObject* p): QObject(p) {}


void TelemetryRouter::setMode(Mode m){
    if (m_mode==m) return;
    m_mode=m; emit modeChanged();
    // pause live source when entering Replay
    // resume when back to Live/Sample
}


void TelemetryRouter::onLiveUpdate(){ if (m_mode!=Live || m_livePaused) return; /* emit signals */ }
void TelemetryRouter::onSampleUpdate(){ if (m_mode!=Sample) return; /* emit */ }
void TelemetryRouter::onReplayUpdate(){ if (m_mode!=Replay) return; /* emit */ }
