#pragma once
#include <QString>

namespace CrashLog {
// Initialize the crash/session log. Call early in main().
void init(const QString& appName = QString(), const QString& version = QString());

// Append a line to the session log (thread-safe).
void append(const QString& line);

// Install only the crash handler; `init()` does this by default.
void installCrashHandler();

// Full path to current session log file (e.g. .../KeyDash/crashlog.txt)
QString currentLogPath();
}
