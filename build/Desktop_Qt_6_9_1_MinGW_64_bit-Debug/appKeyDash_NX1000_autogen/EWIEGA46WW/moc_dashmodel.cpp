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
        "useMphChanged",
        "rpmMaxChanged",
        "finalDriveChanged",
        "gearRatioChanged",
        "gear",
        "ratio",
        "z60PopupChanged",
        "connectedChanged",
        "setUseMph",
        "v",
        "setRpmMax",
        "setFinalDrive",
        "setSpeed",
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
        "setConnected",
        "applySample",
        "rpm",
        "mph",
        "boost",
        "clt",
        "iat",
        "vbat",
        "afr",
        "setGearRatio",
        "loadVehicleConfig",
        "path",
        "gearRatio",
        "resetTrip",
        "speed",
        "dateTimeString",
        "odo",
        "trip",
        "leftSignal",
        "rightSignal",
        "headlightsOn",
        "celOn",
        "tcsOn",
        "useMph",
        "rpmMax",
        "finalDrive",
        "z60Popup",
        "connected"
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
        // Signal 'useMphChanged'
        QtMocHelpers::SignalData<void()>(18, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'rpmMaxChanged'
        QtMocHelpers::SignalData<void()>(19, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'finalDriveChanged'
        QtMocHelpers::SignalData<void()>(20, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'gearRatioChanged'
        QtMocHelpers::SignalData<void(int, double)>(21, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 22 }, { QMetaType::Double, 23 },
        }}),
        // Signal 'z60PopupChanged'
        QtMocHelpers::SignalData<void()>(24, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'connectedChanged'
        QtMocHelpers::SignalData<void()>(25, 2, QMC::AccessPublic, QMetaType::Void),
        // Slot 'setUseMph'
        QtMocHelpers::SlotData<void(bool)>(26, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 27 },
        }}),
        // Slot 'setRpmMax'
        QtMocHelpers::SlotData<void(int)>(28, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 27 },
        }}),
        // Slot 'setFinalDrive'
        QtMocHelpers::SlotData<void(double)>(29, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 27 },
        }}),
        // Slot 'setSpeed'
        QtMocHelpers::SlotData<void(double)>(30, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 27 },
        }}),
        // Slot 'setRpm'
        QtMocHelpers::SlotData<void(double)>(31, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 27 },
        }}),
        // Slot 'setBoost'
        QtMocHelpers::SlotData<void(double)>(32, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 27 },
        }}),
        // Slot 'setClt'
        QtMocHelpers::SlotData<void(double)>(33, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 27 },
        }}),
        // Slot 'setIat'
        QtMocHelpers::SlotData<void(double)>(34, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 27 },
        }}),
        // Slot 'setVbat'
        QtMocHelpers::SlotData<void(double)>(35, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 27 },
        }}),
        // Slot 'setAfr'
        QtMocHelpers::SlotData<void(double)>(36, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 27 },
        }}),
        // Slot 'setGear'
        QtMocHelpers::SlotData<void(int)>(37, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 27 },
        }}),
        // Slot 'setDateTimeString'
        QtMocHelpers::SlotData<void(const QString &)>(38, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 39 },
        }}),
        // Slot 'setOdo'
        QtMocHelpers::SlotData<void(double)>(40, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 27 },
        }}),
        // Slot 'setTrip'
        QtMocHelpers::SlotData<void(double)>(41, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 27 },
        }}),
        // Slot 'setLeftSignal'
        QtMocHelpers::SlotData<void(bool)>(42, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 27 },
        }}),
        // Slot 'setRightSignal'
        QtMocHelpers::SlotData<void(bool)>(43, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 27 },
        }}),
        // Slot 'setHeadlightsOn'
        QtMocHelpers::SlotData<void(bool)>(44, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 27 },
        }}),
        // Slot 'setCelOn'
        QtMocHelpers::SlotData<void(bool)>(45, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 27 },
        }}),
        // Slot 'setTcsOn'
        QtMocHelpers::SlotData<void(bool)>(46, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 27 },
        }}),
        // Slot 'setConnected'
        QtMocHelpers::SlotData<void(bool)>(47, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 27 },
        }}),
        // Slot 'applySample'
        QtMocHelpers::SlotData<void(double, double, double, double, double, double, double, int)>(48, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Double, 49 }, { QMetaType::Double, 50 }, { QMetaType::Double, 51 }, { QMetaType::Double, 52 },
            { QMetaType::Double, 53 }, { QMetaType::Double, 54 }, { QMetaType::Double, 55 }, { QMetaType::Int, 22 },
        }}),
        // Slot 'setGearRatio'
        QtMocHelpers::SlotData<void(int, double)>(56, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 22 }, { QMetaType::Double, 23 },
        }}),
        // Slot 'loadVehicleConfig'
        QtMocHelpers::SlotData<bool(const QString &)>(57, 2, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 58 },
        }}),
        // Slot 'loadVehicleConfig'
        QtMocHelpers::SlotData<bool()>(57, 2, QMC::AccessPublic | QMC::MethodCloned, QMetaType::Bool),
        // Method 'gearRatio'
        QtMocHelpers::MethodData<double(int) const>(59, 2, QMC::AccessPublic, QMetaType::Double, {{
            { QMetaType::Int, 22 },
        }}),
        // Method 'resetTrip'
        QtMocHelpers::MethodData<void()>(60, 2, QMC::AccessPublic, QMetaType::Void),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'speed'
        QtMocHelpers::PropertyData<double>(61, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 0),
        // property 'rpm'
        QtMocHelpers::PropertyData<double>(49, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 1),
        // property 'boost'
        QtMocHelpers::PropertyData<double>(51, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 2),
        // property 'clt'
        QtMocHelpers::PropertyData<double>(52, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 3),
        // property 'iat'
        QtMocHelpers::PropertyData<double>(53, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 4),
        // property 'vbat'
        QtMocHelpers::PropertyData<double>(54, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 5),
        // property 'afr'
        QtMocHelpers::PropertyData<double>(55, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 6),
        // property 'gear'
        QtMocHelpers::PropertyData<int>(22, QMetaType::Int, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 7),
        // property 'dateTimeString'
        QtMocHelpers::PropertyData<QString>(62, QMetaType::QString, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 8),
        // property 'odo'
        QtMocHelpers::PropertyData<double>(63, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 9),
        // property 'trip'
        QtMocHelpers::PropertyData<double>(64, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 10),
        // property 'leftSignal'
        QtMocHelpers::PropertyData<bool>(65, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 11),
        // property 'rightSignal'
        QtMocHelpers::PropertyData<bool>(66, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 12),
        // property 'headlightsOn'
        QtMocHelpers::PropertyData<bool>(67, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 13),
        // property 'celOn'
        QtMocHelpers::PropertyData<bool>(68, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 14),
        // property 'tcsOn'
        QtMocHelpers::PropertyData<bool>(69, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 15),
        // property 'useMph'
        QtMocHelpers::PropertyData<bool>(70, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 16),
        // property 'rpmMax'
        QtMocHelpers::PropertyData<int>(71, QMetaType::Int, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 17),
        // property 'finalDrive'
        QtMocHelpers::PropertyData<double>(72, QMetaType::Double, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 18),
        // property 'z60Popup'
        QtMocHelpers::PropertyData<bool>(73, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 20),
        // property 'connected'
        QtMocHelpers::PropertyData<bool>(74, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 21),
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
        case 16: _t->useMphChanged(); break;
        case 17: _t->rpmMaxChanged(); break;
        case 18: _t->finalDriveChanged(); break;
        case 19: _t->gearRatioChanged((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[2]))); break;
        case 20: _t->z60PopupChanged(); break;
        case 21: _t->connectedChanged(); break;
        case 22: _t->setUseMph((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 23: _t->setRpmMax((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 24: _t->setFinalDrive((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 25: _t->setSpeed((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 26: _t->setRpm((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 27: _t->setBoost((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 28: _t->setClt((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 29: _t->setIat((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 30: _t->setVbat((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 31: _t->setAfr((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 32: _t->setGear((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 33: _t->setDateTimeString((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 34: _t->setOdo((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 35: _t->setTrip((*reinterpret_cast< std::add_pointer_t<double>>(_a[1]))); break;
        case 36: _t->setLeftSignal((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 37: _t->setRightSignal((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 38: _t->setHeadlightsOn((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 39: _t->setCelOn((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 40: _t->setTcsOn((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 41: _t->setConnected((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 42: _t->applySample((*reinterpret_cast< std::add_pointer_t<double>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[4])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[5])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[6])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[7])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[8]))); break;
        case 43: _t->setGearRatio((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[2]))); break;
        case 44: { bool _r = _t->loadVehicleConfig((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 45: { bool _r = _t->loadVehicleConfig();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 46: { double _r = _t->gearRatio((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< double*>(_a[0]) = std::move(_r); }  break;
        case 47: _t->resetTrip(); break;
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
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::useMphChanged, 16))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::rpmMaxChanged, 17))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::finalDriveChanged, 18))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)(int , double )>(_a, &DashModel::gearRatioChanged, 19))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::z60PopupChanged, 20))
            return;
        if (QtMocHelpers::indexOfMethod<void (DashModel::*)()>(_a, &DashModel::connectedChanged, 21))
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
        case 16: *reinterpret_cast<bool*>(_v) = _t->useMph(); break;
        case 17: *reinterpret_cast<int*>(_v) = _t->rpmMax(); break;
        case 18: *reinterpret_cast<double*>(_v) = _t->finalDrive(); break;
        case 19: *reinterpret_cast<bool*>(_v) = _t->z60Popup(); break;
        case 20: *reinterpret_cast<bool*>(_v) = _t->connected(); break;
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
        case 16: _t->setUseMph(*reinterpret_cast<bool*>(_v)); break;
        case 17: _t->setRpmMax(*reinterpret_cast<int*>(_v)); break;
        case 18: _t->setFinalDrive(*reinterpret_cast<double*>(_v)); break;
        case 19: _t->setZ60Popup(*reinterpret_cast<bool*>(_v)); break;
        case 20: _t->setConnected(*reinterpret_cast<bool*>(_v)); break;
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
        if (_id < 48)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 48;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 48)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 48;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 21;
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

// SIGNAL 16
void DashModel::useMphChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 16, nullptr);
}

// SIGNAL 17
void DashModel::rpmMaxChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 17, nullptr);
}

// SIGNAL 18
void DashModel::finalDriveChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 18, nullptr);
}

// SIGNAL 19
void DashModel::gearRatioChanged(int _t1, double _t2)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 19, nullptr, _t1, _t2);
}

// SIGNAL 20
void DashModel::z60PopupChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 20, nullptr);
}

// SIGNAL 21
void DashModel::connectedChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 21, nullptr);
}
QT_WARNING_POP
