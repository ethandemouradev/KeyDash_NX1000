cmake_minimum_required(VERSION 3.16)
project(KeyDash_NX1000 LANGUAGES CXX)

# ---------------- Build type hygiene ----------------
if(CMAKE_GENERATOR MATCHES "Ninja Multi-Config|Visual Studio")
    set(CMAKE_CONFIGURATION_TYPES "Debug;Release;RelWithDebInfo;MinSizeRel" CACHE STRING "" FORCE)
else()
    if(NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE Debug CACHE STRING "" FORCE)
    endif()
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ---------------- Qt ----------------
find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Qml Quick Bluetooth Xml SerialPort SerialBus)
qt_standard_project_setup()
qt_policy(SET QTP0004 NEW)  # silence QTP0004 warning

# MinGW: allow huge RCC translation units, and avoid <windows.h> min/max macros
if (MINGW)
  add_compile_options(-Wa,-mbig-obj)
  add_compile_definitions(NOMINMAX=1)
endif()

# ---------------- Executable target ----------------
qt_add_executable(appKeyDash_NX1000
    main.cpp
    dashmodel.cpp
    ecu_reader.cpp
    crashlog.cpp
)

# Public headers (for moc/includes only — do NOT list QML here)
target_sources(appKeyDash_NX1000
    PUBLIC
        dashmodel.h
        ecu_reader.h
        crashlog.h
        FileReader.h
)

# New C++ sources for multi-ECU support
# (Add/remove lines here as you add more protocols/transports)
target_sources(appKeyDash_NX1000 PRIVATE
    # core/
    core/signal_types.h
    core/itransport.h
    core/iecuprotocol.h
    core/ecu_manager.cpp
    core/ecu_manager.h

    # transports/
    transports/serial_transport.cpp
    transports/serial_transport.h
    transports/can_transport.cpp
    transports/can_transport.h

    # protocols/
    protocols/demo_protocol.cpp
    protocols/demo_protocol.h
    protocols/obd2_elm327.cpp
    protocols/obd2_elm327.h
    protocols/ecumaster_classic.cpp
    protocols/ecumaster_classic.h

    # controllers/
    controllers/connection_controller.cpp
    controllers/connection_controller.h
)

# Include dirs for the new subfolders
target_include_directories(appKeyDash_NX1000 PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/core
    ${CMAKE_CURRENT_SOURCE_DIR}/transports
    ${CMAKE_CURRENT_SOURCE_DIR}/protocols
    ${CMAKE_CURRENT_SOURCE_DIR}/controllers
)

# ---------------- QML module ----------------
# Prefix matches your QML URLs: qrc:/KeyDash_NX1000/...
qt_add_qml_module(appKeyDash_NX1000
    URI KeyDash_NX1000
    VERSION 1.0
    RESOURCE_PREFIX /

    QML_FILES
        Main.qml
        pages/DashboardPage.qml
        pages/ServicePage.qml
        pages/ReplayPage.qml
        pages/SettingsECUPage.qml
        components/LogReplayController.qml
        components/LeftInfoColumn.qml
        style/ThemedButton.qml
        style/ThemedSlider.qml
        style/ThemedSwitch.qml
        scripts/LogParser.js
        errors/Errors.js

    # Non-QML packaged resources
    RESOURCES
        assets/DashBackground.png
        assets/Tachometer_Full.png
        assets/ShiftIcon.png
        assets/CEL_On.png
        assets/TractionControl_On.png
        assets/Headlight_On.png
        assets/LeftTurnSignal_On.png
        assets/RightTurnSignal_On.png
        assets/BlankBackground.png
        assets/icons/boost.png
        assets/icons/lambda.png
        assets/icons/coolant.png
        assets/icons/battery.png
        assets/icons/therm.png
        fonts/NeuropolX_Lite.ttf
        fonts/NeuropolX_Italic.ttf
        proto/version1_218.xml
        SOURCES controllers/connection_controller.h
        SOURCES controllers/connection_controller.cpp
        SOURCES protocols/ecumaster_classic.h protocols/ecumaster_classic.cpp
        SOURCES protocols/demo_protocol.h
        SOURCES protocols/demo_protocol.cpp
        QML_FILES theme/Theme.qml
)

# ---------------- Link Qt libs ----------------
target_link_libraries(appKeyDash_NX1000
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::Bluetooth
        Qt6::Xml
        Qt6::SerialPort
        Qt6::SerialBus
)

# ---------------- Nice diagnostics ----------------
if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(appKeyDash_NX1000 PRIVATE -fdiagnostics-color=always)
endif()
