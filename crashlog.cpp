// ---- Windows & DbgHelp must be included correctly and only on Windows ----
#ifdef _WIN32
#ifndef NOMINMAX
#define NOMINMAX
#endif
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
// Target a modern SDK so MinGW headers expose all types
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0601  // Windows 7+; raise if you need newer APIs
#endif

#include <windows.h>  // HANDLE, ULONG, ULONG64, CONTEXT, WINBOOL, etc.
#include <dbghelp.h>  // MiniDumpWriteDump & MINIDUMP_* types
#endif

#include "crashlog.h"

#include <QCoreApplication>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <QSysInfo>
#include <QTextStream>
#include <QtGlobal>
#include <mutex>

namespace {

QFile g_file;
QTextStream g_ts;
std::mutex g_mutex;
QString g_logPath;
QString g_currentBaseName = QStringLiteral("crashlog"); // base for .txt and (Win) .dmp

// ---------- paths & rotation (cross-platform) ----------
QString logRootFor(const QString &appName) {
    const QString base = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir d(base);
    if (!appName.isEmpty()) {
        d.mkpath(appName);
        d.cd(appName);
    } else {
        QDir().mkpath(base);
    }
    return d.absolutePath();
}

QString timestampNow() {
    return QDateTime::currentDateTime().toString(QStringLiteral("yyyyMMdd-HHmmss"));
}

// Rotate plain baseName.ext -> baseName-YYYYmmdd-HHMMSS.ext (if exists)
QString rotateIfExists(const QString &dir, const QString &baseName, const QString &ext) {
    const QString plain = QDir(dir).filePath(QStringLiteral("%1.%2").arg(baseName, ext));
    QFileInfo fi(plain);
    if (!fi.exists())
        return QString();

    const QString archived =
        QDir(dir).filePath(QStringLiteral("%1-%2.%3").arg(baseName, timestampNow(), ext));

    QFile f(plain);
    if (!f.rename(archived)) {
        if (QFile::copy(plain, archived))
            f.remove();
        else
            return QString();
    }
    return archived;
}

// Keep only newest maxOld archived files named baseName-*.ext
void pruneArchives(const QString &dir, const QString &baseName, const QString &ext, int maxOld) {
    QDir d(dir);
    const QString pattern = QStringLiteral("%1-*.%2").arg(baseName, ext);
    QFileInfoList files = d.entryInfoList({pattern}, QDir::Files, QDir::Time); // newest first
    for (int i = maxOld; i < files.size(); ++i)
        QFile::remove(files.at(i).absoluteFilePath());
}

#ifdef _WIN32
using MiniDumpWriteDump_t = BOOL(WINAPI *)(HANDLE, DWORD, HANDLE, MINIDUMP_TYPE,
                                          PMINIDUMP_EXCEPTION_INFORMATION,
                                          PMINIDUMP_USER_STREAM_INFORMATION,
                                          PMINIDUMP_CALLBACK_INFORMATION);

// Safe wrapper that loads DbgHelp on demand
static BOOL WriteMiniDumpDynamic(HANDLE hProcess, DWORD pid, HANDLE hFile,
                                 MINIDUMP_TYPE type,
                                 PMINIDUMP_EXCEPTION_INFORMATION exInfo) {
    HMODULE hDbg = LoadLibraryW(L"DbgHelp.dll");
    if (!hDbg)
        return FALSE;
    auto pMiniDumpWriteDump =
        reinterpret_cast<MiniDumpWriteDump_t>(GetProcAddress(hDbg, "MiniDumpWriteDump"));
    if (!pMiniDumpWriteDump) {
        FreeLibrary(hDbg);
        return FALSE;
    }
    BOOL ok = pMiniDumpWriteDump(hProcess, pid, hFile, type, exInfo, nullptr, nullptr);
    FreeLibrary(hDbg);
    return ok;
}

// Make dump path next to the log: .../crashlog.dmp
static QString dumpPathForCurrentRun() {
    QFileInfo fi(g_logPath);
    return fi.dir().filePath(QStringLiteral("%1.dmp").arg(g_currentBaseName));
}

// Unhandled exception → write minidump + note in log
static LONG WINAPI unhandledExceptionFilter(EXCEPTION_POINTERS *ex) {
    const QString dumpPath = dumpPathForCurrentRun();
    HANDLE hFile = CreateFileW(reinterpret_cast<LPCWSTR>(dumpPath.utf16()),
                                         GENERIC_WRITE, FILE_SHARE_READ, nullptr,
                                         CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (hFile != INVALID_HANDLE_VALUE) {
        ::MINIDUMP_EXCEPTION_INFORMATION mdei{}; // use GLOBAL type from DbgHelp
        mdei.ThreadId = GetCurrentThreadId();
        mdei.ExceptionPointers = ex;
        mdei.ClientPointers = FALSE;

        WriteMiniDumpDynamic(
            GetCurrentProcess(), GetCurrentProcessId(), hFile,
            (MINIDUMP_TYPE)(MiniDumpWithIndirectlyReferencedMemory | MiniDumpScanMemory),
            &mdei);
        CloseHandle(hFile);

               // also rotate/prune dumps (keep newest 5)
        QFileInfo fi(g_logPath);
        pruneArchives(fi.dir().absolutePath(), g_currentBaseName, QStringLiteral("dmp"), 5);
    }

           // Flush a final line to the text log
    {
        std::lock_guard<std::mutex> lk(g_mutex);
        if (g_ts.device()) {
            g_ts << "\n=== Unhandled exception (minidump written) ===\n";
            g_ts.flush();
        }
    }
    return EXCEPTION_EXECUTE_HANDLER;
}
#endif // _WIN32

// ---------- Qt message handler (to crashlog.txt) ----------
void qtMsgHandler(QtMsgType type, const QMessageLogContext &ctx, const QString &msg) {
    const char *lvl = "";
    switch (type) {
    case QtDebugMsg:   lvl = "DEBUG"; break;
    case QtInfoMsg:    lvl = "INFO";  break;
    case QtWarningMsg: lvl = "WARN";  break;
    case QtCriticalMsg:lvl = "ERROR"; break;
    case QtFatalMsg:   lvl = "FATAL"; break;
    }
    const QString stamp =
        QDateTime::currentDateTime().toString(QStringLiteral("yyyy-MM-dd hh:mm:ss.zzz"));
    const QString where = (ctx.file && *ctx.file)
                              ? QStringLiteral(" (%1:%2)").arg(ctx.file).arg(ctx.line)
                              : QString();

    {
        std::lock_guard<std::mutex> lk(g_mutex);
        if (g_ts.device()) {
            g_ts << "[" << stamp << "][" << lvl << "] " << msg << where << "\n";
            g_ts.flush();
        }
    }

    if (type == QtFatalMsg) {
        fprintf(stderr, "%s\n", msg.toLocal8Bit().constData());
        fflush(stderr);
        abort();
    }
}

} // anonymous namespace

// ==================== Public API ====================
namespace CrashLog {

void init(const QString &appName, const QString &version) {
    const QString app =
        appName.isEmpty() ? QCoreApplication::applicationName() : appName;
    const QString dir = logRootFor(app);

           // 1) Rotate previous run’s .txt/.dmp and keep newest 5 archives
    rotateIfExists(dir, g_currentBaseName, QStringLiteral("txt"));
#ifdef _WIN32
    rotateIfExists(dir, g_currentBaseName, QStringLiteral("dmp"));
#endif
    pruneArchives(dir, g_currentBaseName, QStringLiteral("txt"), 5);
#ifdef _WIN32
    pruneArchives(dir, g_currentBaseName, QStringLiteral("dmp"), 5);
#endif

           // 2) Open fresh crashlog.txt
    g_logPath = QDir(dir).filePath(QStringLiteral("%1.txt").arg(g_currentBaseName));
    g_file.setFileName(g_logPath);
    g_file.open(QIODevice::WriteOnly | QIODevice::Text);
    g_ts.setDevice(&g_file);

           // 3) Header
    g_ts << "========== Crash/Session Log ==========\n";
    g_ts << "App: " << app << "\n";
    g_ts << "Version: "
         << (version.isEmpty() ? QCoreApplication::applicationVersion() : version) << "\n";
    g_ts << "Qt: " << QT_VERSION_STR << "\n";
    g_ts << "OS: " << QSysInfo::prettyProductName() << " ("
         << QSysInfo::currentCpuArchitecture() << ")\n";
    g_ts << "Start: " << QDateTime::currentDateTime().toString(Qt::ISODateWithMs) << "\n";
    g_ts << "Log file: " << g_logPath << "\n";
    g_ts << "=======================================\n";
    g_ts.flush();

           // 4) Hook Qt logging
    qInstallMessageHandler(qtMsgHandler);

#ifdef _WIN32
    // 5) Install crash handler (minidump)
    SetErrorMode(SEM_FAILCRITICALERRORS | SEM_NOGPFAULTERRORBOX | SEM_NOOPENFILEERRORBOX);
    SetUnhandledExceptionFilter(unhandledExceptionFilter);
#endif
}

void installCrashHandler() {
#ifdef _WIN32
    SetUnhandledExceptionFilter(unhandledExceptionFilter);
#endif
}

void append(const QString &line) {
    std::lock_guard<std::mutex> lk(g_mutex);
    if (g_ts.device()) {
        g_ts << line << "\n";
        g_ts.flush();
    }
}

QString currentLogPath() { return g_logPath; }

} // namespace CrashLog
