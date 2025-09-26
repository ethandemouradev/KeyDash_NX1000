#pragma once
#include <QObject>
#include <QUrl>
#include <QFile>
#include <QTextStream>

class FileReader : public QObject {
    Q_OBJECT
public:
        // Tiny helper exposed to QML for reading text files/URLs.
        explicit FileReader(QObject* parent=nullptr) : QObject(parent) {}
        Q_INVOKABLE QString readUrl(const QUrl &url) {
            return readTextUrl(url);
        }
        Q_INVOKABLE QString readTextUrl(const QUrl &url) const {
            const QString path = url.isLocalFile() ? url.toLocalFile() : QUrl(url).toLocalFile();
            QFile f(path);
            if (!f.open(QIODevice::ReadOnly | QIODevice::Text))
                return QString("<< failed to open: %1 >>").arg(path);
            return QString::fromUtf8(f.readAll());
        }
};
