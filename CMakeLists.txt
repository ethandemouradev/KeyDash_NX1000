cmake_minimum_required(VERSION 3.16)
project(KeyDash_NX1000 LANGUAGES CXX)

# Build type hygiene
if(CMAKE_GENERATOR MATCHES "Ninja Multi-Config|Visual Studio")
    set(CMAKE_CONFIGURATION_TYPES "Debug;Release;RelWithDebInfo;MinSizeRel" CACHE STRING "" FORCE)
else()
    if(NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE Debug CACHE STRING "" FORCE)
    endif()
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Qt
find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Qml Quick Bluetooth Xml)
qt_standard_project_setup()

# Silence QTP0004 warning (Qt will auto-generate qmldir stubs for subdirs)
qt_policy(SET QTP0004 NEW)

# MinGW: allow huge RCC translation units, and avoid <windows.h> min/max macros
if (MINGW)
  add_compile_options(-Wa,-mbig-obj)
  add_compile_definitions(NOMINMAX=1)
endif()

# ---- Executable sources ----
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

# ---- QML module ----
# Prefix matches your QML URLs: qrc:/KeyDash_NX1000/...
qt_add_qml_module(appKeyDash_NX1000
    URI KeyDash_NX1000
    VERSION 1.0
    RESOURCE_PREFIX /

    # QML/JS files (explicit — stable, no re-glob loops)
    QML_FILES
        Main.qml
        pages/DashboardPage.qml
        pages/ServicePage.qml
        pages/ReplayPage.qml
        components/LogReplayController.qml
        style/ThemedButton.qml
        style/ThemedSlider.qml
        style/ThemedSwitch.qml
        scripts/LogParser.js
        errors/Errors.js

    # Non-QML packaged resources (explicit list to avoid GLOB mismatch)
    RESOURCES
        assets/DashBlank.png
        assets/Tachometer_Full.png
        assets/ShiftIcon.png
        assets/CEL_On.png
        assets/TractionControl_On.png
        assets/Headlight_On.png
        assets/LeftTurnSignal_On.png
        assets/RightTurnSignal_On.png
        assets/BlankBackground.png
        fonts/NeuropolX_Lite.ttf
        fonts/NeuropolX_Italic.ttf
        proto/version1_218.xml
)

target_link_libraries(appKeyDash_NX1000
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::Bluetooth
        Qt6::Xml
)

# Colored diagnostics (nice to have)
if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(appKeyDash_NX1000 PRIVATE -fdiagnostics-color=always)
endif()
