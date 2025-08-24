/****************************************************************************
** Meta object code from reading C++ file 'dashmodel.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.9.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../dashmodel.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'dashmodel.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.9.1. It"
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
struct qt_meta_tag_ZN9DashModelE_t {};
} // unnamed namespace

template <> constexpr inline auto DashModel::qt_create_metaobjectdata<qt_meta_tag_ZN9DashModelE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "DashModel",
        "speedChanged",
        "",
        "rpmChanged",
        "boostChanged",
        "cltChanged",
        "iatChanged",
        "vbatChanged",
        "afrChanged",
        "gearChanged",
        "dateTimeChanged",
        "odoChanged",
        "tripChanged",
        "leftSignalChanged",
        "rightSignalChanged",
        "headlightsOnChanged",
        "celOnChanged",
        "tcsOnChanged",
        "setSpeed",
        "v",
        "setRpm",
        "setBoost",
        "setClt",
        "setIat",
        "setVbat",
        "setAfr",
        "setGear",
        "setDateTimeString",
        "s",
        "setOdo",
        "setTrip",
        "setLeftSignal",
        "setRightSignal",
        "setHeadlightsOn",
        "setCelOn",
        "setTcsOn",
        "applySample",
        "rpm",
        "mph",
        "boost",
        "clt",
        "iat",
        "vbat",
        "afr",
        "gear",
        "resetTrip",
        "speed",
        "dateTimeString",
        "odo",
        "trip",
        "leftSignal",
        "rightSignal",
        "headlightsOn",
        "celOn",
        "tcsOn"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'speedChanged'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'rpmChanged'
        QtMocHelpers::SignalData<void()>(3, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'boostChanged'
        QtMocHelpers::SignalData<void()>(4, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'cltChanged'
        QtMocHelpers::SignalData<void()>(5, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'iatChanged'
        QtMocHelpers::SignalData<void()>(6, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'vbatChanged'
        QtMocHelpers::SignalData<void()>(7, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'afrChanged'
        QtMocHelpers::SignalData<void()>(8, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'gearChanged'
        QtMocHelpers::SignalData<void()>(9, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'dateTimeChanged'
        QtMocHelpers::SignalData<void()>(10, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'odoChanged'
        QtMocHelpers::SignalData<void()>(11, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'tripChanged'
        QtMocHelpers::SignalData<void()>(12, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'leftSignalChanged'
        QtMocHelpers::SignalData<void()>(13, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'rightSignalChanged'
        QtMocHelpers::SignalData<void()>(14, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'headlightsOnChanged'
        QtMocHelpers::SignalData<void()>(15, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'celOnChanged'
        QtMocHelpers::SignalData<void()>(16, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'tcsOnChanged'
        QtMocHelpers::SignalData<void()>(17, 2, QMC::AccessPublic, QMetaType::Void),
        // Slot 'setSpeed'
        QtMocHelpers::SlotData<void(double)>(18, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 19 },
        }}),
        // Slot 'setRpm'
        QtMocHelpers::SlotData<void(double)>(20, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 19 },
        }}),
        // Slot 'setBoost'
        QtMocHelpers::SlotData<void(double)>(21, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 19 },
        }}),
        // Slot 'setClt'
        QtMocHelpers::SlotData<void(double)>(22, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 19 },
        }}),
        // Slot 'setIat'
        QtMocHelpers::SlotData<void(double)>(23, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 19 },
        }}),
        // Slot 'setVbat'
        QtMocHelpers::SlotData<void(double)>(24, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 19 },
        }}),
        // Slot 'setAfr'
        QtMocHelpers::SlotData<void(double)>(25, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 19 },
        }}),
        // Slot 'setGear'
        QtMocHelpers::SlotData<void(int)>(26, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 19 },
        }}),
        // Slot 'setDateTimeString'
        QtMocHelpers::SlotData<void(const QString &)>(27, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 28 },
        }}),
        // Slot 'setOdo'
        QtMocHelpers::SlotData<void(double)>(29, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 19 },
        }}),
        // Slot 'setTrip'
        QtMocHelpers::SlotData<void(double)>(30, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 19 },
        }}),
        // Slot 'setLeftSignal'
        QtMocHelpers::SlotData<void(bool)>(31, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 19 },
        }}),
        // Slot 'setRightSignal'
        QtMocHelpers::SlotData<void(bool)>(32, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 19 },
        }}),
        // Slot 'setHeadlightsOn'
        QtMocHelpers::SlotData<void(bool)>(33, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 19 },
        }}),
        // Slot 'setCelOn'
        QtMocHelpers::SlotData<void(bool)>(34, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 19 },
        }}),
        // Slot 'setTcsOn'
        QtMocHelpers::SlotData<void(bool)>(35, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 19 },
        }}),
        // Slot 'applySample'
        QtMocHelpers::SlotData<void(double, double, double, double, double, double, double, int)>(36, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 37 }, { QMetaType::Double, 38 }, { QMetaType::Double, 39 }, { QMetaType::Double, 40 },
            { QMetaType::Double, 41 }, { QMetaType::Double, 42 }, { QMetaType::Double, 43 }, { QMetaType::Int, 44 },
        }}),
        // Method 'resetTrip'
        QtMocHelpers::MethodData<void()>(45, 2, QMC::AccessPublic, QMetaType::Void),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'speed'
        QtMocHelpers::PropertyData<double>(46, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 0),
        // property 'rpm'
        QtMocHelpers::PropertyData<double>(37, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 1),
        // property 'boost'
        QtMocHelpers::PropertyData<double>(39, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 2),
        // property 'clt'
        QtMocHelpers::PropertyData<double>(40, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 3),
        // property 'iat'
        QtMocHelpers::PropertyData<double>(41, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 4),
        // property 'vbat'
        QtMocHelpers::PropertyData<double>(42, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 5),
        // property 'afr'
        QtMocHelpers::PropertyData<double>(43, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 6),
        // property 'gear'
        QtMocHelpers::PropertyData<int>(44, QMetaType::Int, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 7),
        // property 'dateTimeString'
        QtMocHelpers::PropertyData<QString>(47, QMetaType::QString, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 8),
        // property 'odo'
        QtMocHelpers::PropertyData<double>(48, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 9),
        // property 'trip'
        QtMocHelpers::PropertyData<double>(49, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 10),
        // property 'leftSignal'
        QtMocHelpers::PropertyData<bool>(50, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 11),
        // property 'rightSignal'
        QtMocHelpers::PropertyData<bool>(51, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 12),
        // property 'headlightsOn'
        QtMocHelpers::PropertyData<bool>(52, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 13),
        // property 'celOn'
        QtMocHelpers::PropertyData<bool>(53, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 14),
        // property 'tcsOn'
        QtMocHelpers::PropertyData<bool>(54, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 15),
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<DashModel, qt_meta_tag_ZN9DashModelE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject DashModel::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN9DashModelE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN9DashModelE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN9DashModelE_t>.metaTypes,
    nullptr
} };

void DashModel::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<DashModel *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->speedChanged(); break;
        case 1: _t->rpmChanged(); break;
        case 2: _t->boostChanged(); break;
        case 3: _t->cltChanged(); break;
        case 4: _t->iatChanged(); break;
        case 5: _t->vbatChanged(); break;
        case 6: _t->afrChanged(); break;
        case 7: _t->gearChanged(); break;
        case 8: _t->dateTimeChanged(); break;
        case 9: _t->odoChanged(); break;
        case 10: _t->tripChanged(); break;
        case 11: _t->leftSignalChanged(); break;
        case 12: _t->rightSignalChanged(); break;
        case 13: _t->headlightsOnChanged(); break;
        case 14: _t->celOnChanged(); break;
        case 15: _t->tcsOnChanged(); break;
        case 16: _t->setSpeed((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 17: _t->setRpm((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 18: _t->setBoost((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 19: _t->setClt((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 20: _t->setIat((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 21: _t->setVbat((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 22: _t->setAfr((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 23: _t->setGear((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 24: _t->setDateTimeString((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 25: _t->setOdo((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 26: _t->setTrip((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 27: _t->setLeftSignal((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 28: _t->setRightSignal((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 29: _t->setHeadlightsOn((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 30: _t->setCelOn((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 31: _t->setTcsOn((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 32: _t->applySample((*reinterpret_cast< std::add_pointer_t<double>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[5])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[6])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[7])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[8]))); break;
        case 33: _t->resetTrip(); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::speedChanged, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::rpmChanged, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::boostChanged, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::cltChanged, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::iatChanged, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::vbatChanged, 5))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::afrChanged, 6))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::gearChanged, 7))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::dateTimeChanged, 8))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::odoChanged, 9))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::tripChanged, 10))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::leftSignalChanged, 11))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::rightSignalChanged, 12))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::headlightsOnChanged, 13))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::celOnChanged, 14))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::tcsOnChanged, 15))
            return;
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<double*>(_v) = _t->speed(); break;
        case 1: *reinterpret_cast<double*>(_v) = _t->rpm(); break;
        case 2: *reinterpret_cast<double*>(_v) = _t->boost(); break;
        case 3: *reinterpret_cast<double*>(_v) = _t->clt(); break;
        case 4: *reinterpret_cast<double*>(_v) = _t->iat(); break;
        case 5: *reinterpret_cast<double*>(_v) = _t->vbat(); break;
        case 6: *reinterpret_cast<double*>(_v) = _t->afr(); break;
        case 7: *reinterpret_cast<int*>(_v) = _t->gear(); break;
        case 8: *reinterpret_cast<QString*>(_v) = _t->dateTimeString(); break;
        case 9: *reinterpret_cast<double*>(_v) = _t->odo(); break;
        case 10: *reinterpret_cast<double*>(_v) = _t->trip(); break;
        case 11: *reinterpret_cast<bool*>(_v) = _t->leftSignal(); break;
        case 12: *reinterpret_cast<bool*>(_v) = _t->rightSignal(); break;
        case 13: *reinterpret_cast<bool*>(_v) = _t->headlightsOn(); break;
        case 14: *reinterpret_cast<bool*>(_v) = _t->celOn(); break;
        case 15: *reinterpret_cast<bool*>(_v) = _t->tcsOn(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setSpeed(*reinterpret_cast<double*>(_v)); break;
        case 1: _t->setRpm(*reinterpret_cast<double*>(_v)); break;
        case 2: _t->setBoost(*reinterpret_cast<double*>(_v)); break;
        case 3: _t->setClt(*reinterpret_cast<double*>(_v)); break;
        case 4: _t->setIat(*reinterpret_cast<double*>(_v)); break;
        case 5: _t->setVbat(*reinterpret_cast<double*>(_v)); break;
        case 6: _t->setAfr(*reinterpret_cast<double*>(_v)); break;
        case 7: _t->setGear(*reinterpret_cast<int*>(_v)); break;
        case 8: _t->setDateTimeString(*reinterpret_cast<QString*>(_v)); break;
        case 9: _t->setOdo(*reinterpret_cast<double*>(_v)); break;
        case 10: _t->setTrip(*reinterpret_cast<double*>(_v)); break;
        case 11: _t->setLeftSignal(*reinterpret_cast<bool*>(_v)); break;
        case 12: _t->setRightSignal(*reinterpret_cast<bool*>(_v)); break;
        case 13: _t->setHeadlightsOn(*reinterpret_cast<bool*>(_v)); break;
        case 14: _t->setCelOn(*reinterpret_cast<bool*>(_v)); break;
        case 15: _t->setTcsOn(*reinterpret_cast<bool*>(_v)); break;
        default: break;
        }
    }
}

const QMetaObject *DashModel::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *DashModel::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN9DashModelE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int DashModel::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 34)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 34;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 34)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 34;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 16;
    }
    return _id;
}

// SIGNAL 0
void DashModel::speedChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void DashModel::rpmChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void DashModel::boostChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void DashModel::cltChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void DashModel::iatChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void DashModel::vbatChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}

// SIGNAL 6
void DashModel::afrChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 6, nullptr);
}

// SIGNAL 7
void DashModel::gearChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 7, nullptr);
}

// SIGNAL 8
void DashModel::dateTimeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 8, nullptr);
}

// SIGNAL 9
void DashModel::odoChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 9, nullptr);
}

// SIGNAL 10
void DashModel::tripChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 10, nullptr);
}

// SIGNAL 11
void DashModel::leftSignalChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 11, nullptr);
}

// SIGNAL 12
void DashModel::rightSignalChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 12, nullptr);
}

// SIGNAL 13
void DashModel::headlightsOnChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 13, nullptr);
}

// SIGNAL 14
void DashModel::celOnChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 14, nullptr);
}

// SIGNAL 15
void DashModel::tcsOnChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 15, nullptr);
}
QT_WARNING_POP
