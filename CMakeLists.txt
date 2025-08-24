cmake_minimum_required(VERSION 3.16)
project(KeyDash_NX1000 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Core Qt
find_package(Qt6 6.4 REQUIRED COMPONENTS Quick)
# Try SerialPort, but don’t fail if missing
find_package(Qt6 6.4 COMPONENTS SerialPort QUIET)

qt_standard_project_setup()

qt_add_executable(appKeyDash_NX1000
    main.cpp
    dashmodel.h dashmodel.cpp
    serialworker.h serialworker.cpp
)

qt_add_qml_module(appKeyDash_NX1000
    URI KeyDash_NX1000
    VERSION 1.0
    QML_FILES Main.qml
    RESOURCES
        assets/DashBlank.png
        assets/Tachometer_Full.png
        assets/ShiftIcon.png
        assets/CEL_On.png
        assets/TractionControl_On.png
        assets/Headlight_On.png
        assets/LeftTurnSignal_On.png
        assets/RightTurnSignal_On.png
        fonts/NeuropolX_Lite.ttf
        fonts/NeuropolX_Italic.ttf
)

target_link_libraries(appKeyDash_NX1000 PRIVATE Qt6::Quick)

# Enable SerialPort if available
if (Qt6SerialPort_FOUND)
    target_compile_definitions(appKeyDash_NX1000 PRIVATE HAVE_SERIALPORT=1)
    target_link_libraries(appKeyDash_NX1000 PRIVATE Qt6::SerialPort)
    message(STATUS "Qt6 SerialPort: ENABLED")
else()
    message(WARNING "Qt6 SerialPort: NOT FOUND – building without ECU serial I/O")
endif()
