/****************************************************************************
** Meta object code from reading C++ file 'ecu_reader.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.9.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../ecu_reader.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'ecu_reader.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.9.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN9EcuReaderE_t {};
} // unnamed namespace

template <> constexpr inline auto EcuReader::qt_create_metaobjectdata<qt_meta_tag_ZN9EcuReaderE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "EcuReader",
        "rpmChanged",
        "",
        "mapChanged",
        "tpsChanged",
        "battChanged",
        "iatChanged",
        "cltChanged",
        "afrChanged",
        "lambdaChanged",
        "baroChanged",
        "connectionChanged",
        "connected",
        "connectedLegacy",
        "disconnectedLegacy",
        "errorChanged",
        "msg",
        "QVariant",
        "code",
        "scanningChanged",
        "devicesChanged",
        "info",
        "message",
        "warn",
        "onReadyRead",
        "onStateChanged",
        "QBluetoothSocket::SocketState",
        "onErrorOccurred",
        "QBluetoothSocket::SocketError",
        "setConnected",
        "v",
        "onDeviceFound",
        "QBluetoothDeviceInfo",
        "onScanFinished",
        "onScanError",
        "QBluetoothDeviceDiscoveryAgent::Error",
        "error",
        "setDeviceAddress",
        "btAddr",
        "deviceAddress",
        "connectToDevice",
        "disconnectDevice",
        "isConnected",
        "loadXmlMap",
        "urlOrPath",
        "connectionError",
        "startScan",
        "stopScan",
        "connectToName",
        "nameOrSubstring",
        "rpm",
        "map",
        "tps",
        "batt",
        "iat",
        "clt",
        "afr",
        "lambda",
        "baro",
        "scanning",
        "devices"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'rpmChanged'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'mapChanged'
        QtMocHelpers::SignalData<void()>(3, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'tpsChanged'
        QtMocHelpers::SignalData<void()>(4, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'battChanged'
        QtMocHelpers::SignalData<void()>(5, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'iatChanged'
        QtMocHelpers::SignalData<void()>(6, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'cltChanged'
        QtMocHelpers::SignalData<void()>(7, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'afrChanged'
        QtMocHelpers::SignalData<void()>(8, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'lambdaChanged'
        QtMocHelpers::SignalData<void()>(9, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'baroChanged'
        QtMocHelpers::SignalData<void()>(10, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'connectionChanged'
        QtMocHelpers::SignalData<void(bool)>(11, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 12 },
        }}),
        // Signal 'connectedLegacy'
        QtMocHelpers::SignalData<void()>(13, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'disconnectedLegacy'
        QtMocHelpers::SignalData<void()>(14, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'errorChanged'
        QtMocHelpers::SignalData<void(const QString &, const QVariant &)>(15, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 16 }, { 0x80000000 | 17, 18 },
        }}),
        // Signal 'errorChanged'
        QtMocHelpers::SignalData<void(const QString &)>(15, 2, QMC::AccessPublic | QMC::MethodCloned, QMetaType::Void, {{
            { QMetaType::QString, 16 },
        }}),
        // Signal 'scanningChanged'
        QtMocHelpers::SignalData<void()>(19, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'devicesChanged'
        QtMocHelpers::SignalData<void()>(20, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'info'
        QtMocHelpers::SignalData<void(const QString &)>(21, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 22 },
        }}),
        // Signal 'warn'
        QtMocHelpers::SignalData<void(const QString &)>(23, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 22 },
        }}),
        // Slot 'onReadyRead'
        QtMocHelpers::SlotData<void()>(24, 2, QMC::AccessPrivate, QMetaType::Void),
        // Slot 'onStateChanged'
        QtMocHelpers::SlotData<void(QBluetoothSocket::SocketState)>(25, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { 0x80000000 | 26, 2 },
        }}),
        // Slot 'onErrorOccurred'
        QtMocHelpers::SlotData<void(QBluetoothSocket::SocketError)>(27, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { 0x80000000 | 28, 2 },
        }}),
        // Slot 'setConnected'
        QtMocHelpers::SlotData<void(bool)>(29, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { QMetaType::Bool, 30 },
        }}),
        // Slot 'onDeviceFound'
        QtMocHelpers::SlotData<void(const QBluetoothDeviceInfo &)>(31, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { 0x80000000 | 32, 21 },
        }}),
        // Slot 'onScanFinished'
        QtMocHelpers::SlotData<void()>(33, 2, QMC::AccessPrivate, QMetaType::Void),
        // Slot 'onScanError'
        QtMocHelpers::SlotData<void(QBluetoothDeviceDiscoveryAgent::Error)>(34, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { 0x80000000 | 35, 36 },
        }}),
        // Method 'setDeviceAddress'
        QtMocHelpers::MethodData<void(const QString &)>(37, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 38 },
        }}),
        // Method 'deviceAddress'
        QtMocHelpers::MethodData<QString() const>(39, 2, QMC::AccessPublic, QMetaType::QString),
        // Method 'connectToDevice'
        QtMocHelpers::MethodData<void()>(40, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'disconnectDevice'
        QtMocHelpers::MethodData<void()>(41, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'isConnected'
        QtMocHelpers::MethodData<bool() const>(42, 2, QMC::AccessPublic, QMetaType::Bool),
        // Method 'loadXmlMap'
        QtMocHelpers::MethodData<bool(const QString &)>(43, 2, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 44 },
        }}),
        // Method 'connectionError'
        QtMocHelpers::MethodData<QString() const>(45, 2, QMC::AccessPublic, QMetaType::QString),
        // Method 'startScan'
        QtMocHelpers::MethodData<void()>(46, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'stopScan'
        QtMocHelpers::MethodData<void()>(47, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'connectToName'
        QtMocHelpers::MethodData<void(const QString &)>(48, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 49 },
        }}),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'rpm'
        QtMocHelpers::PropertyData<int>(50, QMetaType::Int, QMC::DefaultPropertyFlags, 0),
        // property 'map'
        QtMocHelpers::PropertyData<int>(51, QMetaType::Int, QMC::DefaultPropertyFlags, 1),
        // property 'tps'
        QtMocHelpers::PropertyData<int>(52, QMetaType::Int, QMC::DefaultPropertyFlags, 2),
        // property 'batt'
        QtMocHelpers::PropertyData<double>(53, QMetaType::Double, QMC::DefaultPropertyFlags, 3),
        // property 'iat'
        QtMocHelpers::PropertyData<int>(54, QMetaType::Int, QMC::DefaultPropertyFlags, 4),
        // property 'clt'
        QtMocHelpers::PropertyData<int>(55, QMetaType::Int, QMC::DefaultPropertyFlags, 5),
        // property 'afr'
        QtMocHelpers::PropertyData<double>(56, QMetaType::Double, QMC::DefaultPropertyFlags, 6),
        // property 'lambda'
        QtMocHelpers::PropertyData<double>(57, QMetaType::Double, QMC::DefaultPropertyFlags, 7),
        // property 'baro'
        QtMocHelpers::PropertyData<int>(58, QMetaType::Int, QMC::DefaultPropertyFlags, 8),
        // property 'connected'
        QtMocHelpers::PropertyData<bool>(12, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 9),
        // property 'scanning'
        QtMocHelpers::PropertyData<bool>(59, QMetaType::Bool, QMC::DefaultPropertyFlags, 14),
        // property 'devices'
        QtMocHelpers::PropertyData<QStringList>(60, QMetaType::QStringList, QMC::DefaultPropertyFlags, 15),
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<EcuReader, qt_meta_tag_ZN9EcuReaderE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject EcuReader::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN9EcuReaderE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN9EcuReaderE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN9EcuReaderE_t>.metaTypes,
    nullptr
} };

void EcuReader::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<EcuReader *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->rpmChanged(); break;
        case 1: _t->mapChanged(); break;
        case 2: _t->tpsChanged(); break;
        case 3: _t->battChanged(); break;
        case 4: _t->iatChanged(); break;
        case 5: _t->cltChanged(); break;
        case 6: _t->afrChanged(); break;
        case 7: _t->lambdaChanged(); break;
        case 8: _t->baroChanged(); break;
        case 9: _t->connectionChanged((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 10: _t->connectedLegacy(); break;
        case 11: _t->disconnectedLegacy(); break;
        case 12: _t->errorChanged((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<QVariant>>(_a[2]))); break;
        case 13: _t->errorChanged((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 14: _t->scanningChanged(); break;
        case 15: _t->devicesChanged(); break;
        case 16: _t->info((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 17: _t->warn((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 18: _t->onReadyRead(); break;
        case 19: _t->onStateChanged((*reinterpret_cast< std::add_pointer_t<QBluetoothSocket::SocketState>>(_a[1]))); break;
        case 20: _t->onErrorOccurred((*reinterpret_cast< std::add_pointer_t<QBluetoothSocket::SocketError>>(_a[1]))); break;
        case 21: _t->setConnected((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 22: _t->onDeviceFound((*reinterpret_cast< std::add_pointer_t<QBluetoothDeviceInfo>>(_a[1]))); break;
        case 23: _t->onScanFinished(); break;
        case 24: _t->onScanError((*reinterpret_cast< std::add_pointer_t<QBluetoothDeviceDiscoveryAgent::Error>>(_a[1]))); break;
        case 25: _t->setDeviceAddress((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 26: { QString _r = _t->deviceAddress();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 27: _t->connectToDevice(); break;
        case 28: _t->disconnectDevice(); break;
        case 29: { bool _r = _t->isConnected();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 30: { bool _r = _t->loadXmlMap((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 31: { QString _r = _t->connectionError();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 32: _t->startScan(); break;
        case 33: _t->stopScan(); break;
        case 34: _t->connectToName((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        default: ;
        }
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
        case 22:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
            case 0:
                *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType::fromType< QBluetoothDeviceInfo >(); break;
            }
            break;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)()>(_a, &EcuReader::rpmChanged, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)()>(_a, &EcuReader::mapChanged, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)()>(_a, &EcuReader::tpsChanged, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)()>(_a, &EcuReader::battChanged, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)()>(_a, &EcuReader::iatChanged, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)()>(_a, &EcuReader::cltChanged, 5))
            return;
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)()>(_a, &EcuReader::afrChanged, 6))
            return;
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)()>(_a, &EcuReader::lambdaChanged, 7))
            return;
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)()>(_a, &EcuReader::baroChanged, 8))
            return;
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)(bool )>(_a, &EcuReader::connectionChanged, 9))
            return;
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)()>(_a, &EcuReader::connectedLegacy, 10))
            return;
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)()>(_a, &EcuReader::disconnectedLegacy, 11))
            return;
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)(const QString & , const QVariant & )>(_a, &EcuReader::errorChanged, 12))
            return;
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)()>(_a, &EcuReader::scanningChanged, 14))
            return;
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)()>(_a, &EcuReader::devicesChanged, 15))
            return;
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)(const QString & )>(_a, &EcuReader::info, 16))
            return;
        if (QtMocHelpers::indexOfMethod<void (EcuReader::*)(const QString & )>(_a, &EcuReader::warn, 17))
            return;
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<int*>(_v) = _t->rpm(); break;
        case 1: *reinterpret_cast<int*>(_v) = _t->map(); break;
        case 2: *reinterpret_cast<int*>(_v) = _t->tps(); break;
        case 3: *reinterpret_cast<double*>(_v) = _t->batt(); break;
        case 4: *reinterpret_cast<int*>(_v) = _t->iat(); break;
        case 5: *reinterpret_cast<int*>(_v) = _t->clt(); break;
        case 6: *reinterpret_cast<double*>(_v) = _t->afr(); break;
        case 7: *reinterpret_cast<double*>(_v) = _t->lambda(); break;
        case 8: *reinterpret_cast<int*>(_v) = _t->baro(); break;
        case 9: *reinterpret_cast<bool*>(_v) = _t->isConnected(); break;
        case 10: *reinterpret_cast<bool*>(_v) = _t->scanning(); break;
        case 11: *reinterpret_cast<QStringList*>(_v) = _t->devices(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 9: _t->setConnected(*reinterpret_cast<bool*>(_v)); break;
        default: break;
        }
    }
}

const QMetaObject *EcuReader::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *EcuReader::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN9EcuReaderE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int EcuReader::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 35)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 35;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 35)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 35;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 12;
    }
    return _id;
}

// SIGNAL 0
void EcuReader::rpmChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void EcuReader::mapChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void EcuReader::tpsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void EcuReader::battChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void EcuReader::iatChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void EcuReader::cltChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}

// SIGNAL 6
void EcuReader::afrChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 6, nullptr);
}

// SIGNAL 7
void EcuReader::lambdaChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 7, nullptr);
}

// SIGNAL 8
void EcuReader::baroChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 8, nullptr);
}

// SIGNAL 9
void EcuReader::connectionChanged(bool _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 9, nullptr, _t1);
}

// SIGNAL 10
void EcuReader::connectedLegacy()
{
    QMetaObject::activate(this, &staticMetaObject, 10, nullptr);
}

// SIGNAL 11
void EcuReader::disconnectedLegacy()
{
    QMetaObject::activate(this, &staticMetaObject, 11, nullptr);
}

// SIGNAL 12
void EcuReader::errorChanged(const QString & _t1, const QVariant & _t2)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 12, nullptr, _t1, _t2);
}

// SIGNAL 14
void EcuReader::scanningChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 14, nullptr);
}

// SIGNAL 15
void EcuReader::devicesChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 15, nullptr);
}

// SIGNAL 16
void EcuReader::info(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 16, nullptr, _t1);
}

// SIGNAL 17
void EcuReader::warn(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 17, nullptr, _t1);
}
QT_WARNING_POP
