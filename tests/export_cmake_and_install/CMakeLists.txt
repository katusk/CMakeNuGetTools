set(PROJECT_ROOT "${CMAKE_CURRENT_LIST_DIR}/../..")
include("${PROJECT_ROOT}/cmake/NuGetTools.cmake")
include(GNUInstallDirs)

## CMake setup
cmake_minimum_required(VERSION 3.8.2 FATAL_ERROR)
project(icu_cmake_and_install LANGUAGES C)
set(CMAKE_CXX_COMPILER "")

## NuGet setup: call it only once before any other nuget_* calls.
nuget_initialize()

## Import CMake exports of icu from NuGet package exported from Vcpkg
# Please note that strictly speaking this is not the proper way of using packages exported from Vcpkg. The reason this works:
# 1) The vcpkg.cmake toolchain file (that we do not use here) does not contain any tricky settings regarding icu.
# 2) Icu comes with proper CMake export files that we can simply directly use from the NuGet package (see PREFIX_PATHS below).
# See https://cmake.org/cmake/help/latest/command/find_package.html#search-procedure for determining a good PREFIX_PATHS value.
nuget_add_dependencies(
    PACKAGE icu.x64-windows.vcpkg-export
    VERSION 65.1.0-2
    PREFIX_PATHS installed/x64-windows
)
# You can create above NuGet package by e.g. (assuming you are at VCPKG_ROOT):
# 1) $ vcpkg install icu:x64-windows
# 2) $ vcpkg export icu:x64-windows --nuget --nuget-version=65.1.0-2 --nuget-id=icu.x64-windows.vcpkg-export
# 3) $ nuget add icu.x64-windows.vcpkg-export.65.1.0-2.nupkg -Source "%USERPROFILE%/.nuget/repository"

## Find external dependencies
# Business as usual from this point on. The above nuget_add_dependencies() takes care of setting the CMAKE_PREFIX_PATH.
find_package(ICU REQUIRED COMPONENTS data uc io)

## Create executable
# From "Examining UTF-8 code units" of https://begriffs.com/posts/2019-05-23-unicode-icu.html#icu-example-programs
# Test: echo "résumé façade" | ./nomarks
add_executable(nomarks nomarks.c)
# TODO: These does not seem to link against the "icu*d65.dll" icu libraries in Debug mode (a "d" is appended just before the version number).
target_link_libraries(nomarks PRIVATE ICU::data ICU::uc ICU::io)

## Install the executable
install(TARGETS nomarks
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

## Install .dlls the brute force way
nuget_get_installed_dependencies_dirs(DEPENDENCIES_DIRS)
foreach(PACKAGE_DIR IN LISTS DEPENDENCIES_DIRS)
    install(
        DIRECTORY "${PACKAGE_DIR}/installed/x64-windows/bin/"
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        CONFIGURATIONS Release
        # Note: empty folders are copied: https://gitlab.kitware.com/cmake/cmake/issues/17122
        FILES_MATCHING
            PATTERN "*.dll"
            PATTERN "*.pdb"
    )
    install(
        DIRECTORY "${PACKAGE_DIR}/installed/x64-windows/debug/bin/"
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        CONFIGURATIONS Debug
        # Note: empty folders are copied: https://gitlab.kitware.com/cmake/cmake/issues/17122
        FILES_MATCHING
            PATTERN "*.dll"
            PATTERN "*.pdb"
    )
endforeach()
