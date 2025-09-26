#pragma once
#include <QString>

namespace CrashLog {
// Call once on startup (very early in main()).
void init(const QString& appName = QString(), const QString& version = QString());

// Optional helper if you want to append custom lines anywhere.
void append(const QString& line);

// (Legacy convenience) Installs the crash handler only. `init()` already does this.
void installCrashHandler();

// Full path to current session log file (e.g. .../KeyDash/crashlog.txt)
QString currentLogPath();
}
