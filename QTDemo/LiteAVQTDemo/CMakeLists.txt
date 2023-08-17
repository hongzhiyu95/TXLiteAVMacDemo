cmake_minimum_required(VERSION 3.5)

project(LiteAVQTDemo VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Widgets)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
set(CMAKE_INSTALL_RPATH "${PROJECT_SOURCE_DIR}/SDK/TXFFmpeg.xcframework/macos-arm64_x86_64/")
set(CMAKE_INSTALL_RPATH "${PROJECT_SOURCE_DIR}/SDK/TXSoundTouch.xcframework/macos-arm64_x86_64/")
set(THIRD_LIB_TRTC_DIR ${PROJECT_SOURCE_DIR}/SDK)
set(THIRD_LIB_TRTC_INCLUDE_DIR
        ${THIRD_LIB_TRTC_DIR}/TXLiteAVSDK_TRTC_Mac.framework/Headers/cpp_interface
        ${THIRD_LIB_TRTC_DIR}/TXLiteAVSDK_TRTC_Mac.framework/Headers
    )

find_library(TXLiteAVSDK_TRTC_Mac_LIB TXLiteAVSDK_TRTC_Mac ${THIRD_LIB_TRTC_DIR})
find_library(TXFFmpeg_LIB TXFFmpeg ${THIRD_LIB_TRTC_DIR}/TXFFmpeg.xcframework/macos-arm64_x86_64/)
find_library(TXSoundTouch_LIB TXSoundTouch ${THIRD_LIB_TRTC_DIR}/TXSoundTouch.xcframework/macos-arm64_x86_64/)
set(PROJECT_SOURCES
        main.cpp
        mainwindow.cpp
        mainwindow.h
        mainwindow.ui
)
set(THIRD_LIB_TRTC_LIB_LIST
       ${TXLiteAVSDK_TRTC_Mac_LIB}
       ${TXFFmpeg_LIB}
       ${TXSoundTouch_LIB}
       "-framework Accelerate"
       "-framework AudioUnit"
       "-framework AppKit"
       "-framework Foundation"
       "-framework CoreFoundation"
       "-framework Security"
       "-framework SystemConfiguration"
       "-framework CoreMedia"
       "-framework CoreAudio"
       "-framework CoreVideo"
       "-framework CoreImage"
       "-framework AVFoundation"
       "-framework AudioToolbox"
       "-framework VideoToolbox"
       "-framework MetalKit"
       "-framework Metal"
       "-framework CoreTelephony"
       "-framework CoreGraphics"
       "-framework OpenGL"
       "-framework OpenAL"
       "-framework QuartzCore"
       "-framework IOKit"


   )
if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(LiteAVQTDemo
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
    )
# Define target properties for Android with Qt 6 as:
#    set_property(TARGET LiteAVQTDemo APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
#                 ${CMAKE_CURRENT_SOURCE_DIR}/android)
# For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#target-creation
else()
    if(ANDROID)
        add_library(LiteAVQTDemo SHARED
            ${PROJECT_SOURCES}
        )
# Define properties for Android with Qt 5 after find_package() calls as:
#    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
    else()
        add_executable(LiteAVQTDemo
            ${PROJECT_SOURCES}
        )
    endif()
endif()
target_link_libraries(LiteAVQTDemo PRIVATE ${THIRD_LIB_TRTC_LIB_LIST})
target_link_libraries(LiteAVQTDemo PRIVATE Qt${QT_VERSION_MAJOR}::Widgets)
target_include_directories(LiteAVQTDemo PUBLIC ${THIRD_LIB_TRTC_INCLUDE_DIR})
set_target_properties(LiteAVQTDemo PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

install(TARGETS LiteAVQTDemo
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(QT_VERSION_MAJOR EQUAL 6)
    qt_finalize_executable(LiteAVQTDemo)
endif()
