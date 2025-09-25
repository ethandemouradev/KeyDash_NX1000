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

# ---- Executable sources ----
qt_add_executable(appKeyDash_NX1000
    main.cpp
    dashmodel.cpp
    ecu_reader.cpp
    # add your other .cpp files here as needed
)

# ---- QML module / docs/----
qt_add_qml_module(appKeyDash_NX1000
    URI KeyDash_NX1000
    VERSION 1.0
    RESOURCE_PREFIX /
    QML_FILES
        Main.qml
        pages/DashboardPage.qml
        pages/ServicePage.qml
        style/ThemedSlider.qml
        style/ThemedSwitch.qml
        style/ThemedButton.qml
        errors/Errors.js
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
        docs/Setup.md
        docs/FirstBoot.md
        docs/Navigation.md
        docs/tabs/Device.md
        docs/tabs/Tachometer.md
        docs/tabs/Display.md
        docs/tabs/Gauges.md
        docs/tabs/Performance.md
        docs/Errors.md
        docs/Troubleshooting.md
        docs/FAQ.md
        docs/customization/Customization.md
        docs/customization/Overlays.md
        docs/customization/Preferences.md
        docs/Glossary.md
        docs/SUMMARY.md
        SOURCES pages/servicepage.h pages/servicepage.cpp
)

# Headers for moc (PUBLIC so moc sees them)
target_sources(appKeyDash_NX1000
    PUBLIC
        dashmodel.h
        ecu_reader.h
        pages/ServicePage.qml
        pages/DashboardPage.qml
        errors/Errors.js
        docs/SUMMARY.md
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

# Nice to have: color diagnostics
if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(appKeyDash_NX1000 PRIVATE -fdiagnostics-color=always)
endif()
