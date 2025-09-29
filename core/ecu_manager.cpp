#include "ecu_manager.h"
#include "core/itransport.h"

EcuManager::EcuManager(QObject *parent) : QObject(parent) {}
EcuManager::~EcuManager() { stop(); }

void EcuManager::setTransport(ITransport *t) { m_t = t; }
void EcuManager::setProtocol(IECUProtocol *p) {
    if (m_p) { m_p->stop(); m_p.reset(); }
    m_p.reset(p);
    if (m_p) {
        connect(m_p.data(), &IECUProtocol::sig, this, &EcuManager::sig);
        connect(m_p.data(), &IECUProtocol::statusChanged, this, &EcuManager::statusChanged);
    }
}

bool EcuManager::start() {
    if (!m_p) return false;
    if (!m_p->probe(m_t)) return false;
    return m_p->start(m_t);
}

void EcuManager::stop() { if (m_p) m_p->stop(); }
