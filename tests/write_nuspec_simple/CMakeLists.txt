set(PROJECT_ROOT "${CMAKE_CURRENT_LIST_DIR}/../..")
include("${PROJECT_ROOT}/cmake/NuGetTools.cmake")
include(GNUInstallDirs)

## CMake setup
cmake_minimum_required(VERSION 3.8.2 FATAL_ERROR)
project(write_nuspec_simple LANGUAGES CXX VERSION 1.2.3)
set(CMAKE_C_COMPILER "")

## NuGet setup: call it only once before any other nuget_* calls.
nuget_initialize()

## Import CMake exports of icu/flatbuffers from NuGet package exported from Vcpkg
# Please note that strictly speaking this is not the proper way of using packages exported from Vcpkg. The reason this works:
# 1) The vcpkg.cmake toolchain file (that we do not use here) does not contain any tricky settings regarding icu/flatbuffers.
# 2) Icu/flatbuffers comes with proper CMake export files that we can simply directly use from the NuGet package (see PREFIX_PATHS below).
# See https://cmake.org/cmake/help/latest/command/find_package.html#search-procedure for determining a good PREFIX_PATHS value.
nuget_add_dependencies(
    PACKAGE flatbuffers.x64-windows.vcpkg-export VERSION 1.11.0-1 PREFIX_PATHS installed/x64-windows
    PACKAGE icu.x64-windows.vcpkg-export PUBLIC VERSION 65.1.0-2 PREFIX_PATHS installed/x64-windows
)
# You can create above icu NuGet package by e.g. (assuming you are at VCPKG_ROOT):
# 1) $ vcpkg install icu:x64-windows
# 2) $ vcpkg export icu:x64-windows --nuget --nuget-version=65.1.0-2 --nuget-id=icu.x64-windows.vcpkg-export
# 3) $ nuget add icu.x64-windows.vcpkg-export.65.1.0-2.nupkg -Source "%USERPROFILE%/.nuget/repository"

## Find external dependencies
# Business as usual from this point on. The above nuget_add_dependencies() takes care of setting the CMAKE_PREFIX_PATH.
find_package(ICU REQUIRED COMPONENTS data uc io)
# Only for flatbuffers::flatc and INTERFACE_INCLUDE_DIRECTORIES, flatbuffers.lib not needed.
find_package(Flatbuffers CONFIG REQUIRED)
get_target_property(FLATBUFFERS_INTERFACE_INCLUDE_DIRECTORIES flatbuffers::flatbuffers INTERFACE_INCLUDE_DIRECTORIES)

## Generated sources
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/generated/monster.h"
    COMMAND flatbuffers::flatc --cpp -o "${CMAKE_CURRENT_BINARY_DIR}/generated" "${CMAKE_CURRENT_SOURCE_DIR}/monster.fbs"
    # From https://github.com/google/flatbuffers/blob/3ff6cdf49181061bd545bcd3a2a292bca3e8ef6b/samples/monster.fbs
    DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/monster.fbs"
)
add_custom_target(GeneratedFilesInternal DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/generated/monster.h")
add_library(GeneratedFiles INTERFACE)
# Not to be exported. This target is for internal use only, i.e. only other internal targets can use this interface include.
target_include_directories(GeneratedFiles INTERFACE "${CMAKE_CURRENT_BINARY_DIR}/generated")
add_dependencies(GeneratedFiles GeneratedFilesInternal)

## Create executable
# From "Examining UTF-8 code units" of https://begriffs.com/posts/2019-05-23-unicode-icu.html#icu-example-programs
# Test: echo "résumé façade" | ./nomarks
# From https://github.com/google/flatbuffers/blob/42c08cbca601688af921eaa9384844a632e2cde8/samples/sample_binary.cpp
add_library(WriteNuspecSimple SHARED nomarks.c sample_binary.cpp)
# TODO: These does not seem to link against the "icu*d65.dll" icu libraries in Debug mode (a "d" is appended just before the version number).
target_link_libraries(WriteNuspecSimple PRIVATE ICU::data ICU::uc ICU::io GeneratedFiles)
target_include_directories(WriteNuspecSimple PRIVATE "${FLATBUFFERS_INTERFACE_INCLUDE_DIRECTORIES}") # Only need flatbuffers/flatbuffers.h

## Install the executable
install(TARGETS WriteNuspecSimple
    EXPORT WriteNuspecSimpleExport
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}/$<CONFIG>
    LIBRARY DESTINATION ${CMAKE_INSTALL_BINDIR}/$<CONFIG>
)

## Install .dlls the brute force way
nuget_get_installed_dependencies_dirs(DEPENDENCIES_DIRS)
foreach(PACKAGE_DIR IN LISTS DEPENDENCIES_DIRS)
    install(
        DIRECTORY "${PACKAGE_DIR}/installed/x64-windows/bin/"
        DESTINATION ${CMAKE_INSTALL_BINDIR}/$<CONFIG>
        CONFIGURATIONS Release
        # Note: empty folders are copied: https://gitlab.kitware.com/cmake/cmake/issues/17122
        FILES_MATCHING
            PATTERN "*.dll"
            PATTERN "*.pdb"
    )
    install(
        DIRECTORY "${PACKAGE_DIR}/installed/x64-windows/debug/bin/"
        DESTINATION ${CMAKE_INSTALL_BINDIR}/$<CONFIG>
        CONFIGURATIONS Debug
        # Note: empty folders are copied: https://gitlab.kitware.com/cmake/cmake/issues/17122
        FILES_MATCHING
            PATTERN "*.dll"
            PATTERN "*.pdb"
    )
endforeach()

## Installation of CMake Export Files
include(CMakePackageConfigHelpers)
configure_package_config_file(cmake/WriteNuspecSimpleConfig.cmake.in
    "${CMAKE_CURRENT_BINARY_DIR}/WriteNuspecSimpleConfig.cmake"
    INSTALL_DESTINATION cmake
)
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/WriteNuspecSimpleConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/WriteNuspecSimpleConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/WriteNuspecSimpleConfigVersion.cmake"
    DESTINATION cmake
)
install(EXPORT WriteNuspecSimpleExport
    FILE WriteNuspecSimpleTargets.cmake
    NAMESPACE WriteNuspecSimple::
    DESTINATION cmake
)

## Write .nuspec file(s)
nuget_write_nuspec(
    ## CMake-specific arguments section
    CMAKE_OUTPUT_DIR ${CMAKE_BINARY_DIR}/CMakeNuGetTools # Optional: defaults to ${CMAKE_BINARY_DIR}/CMakeNuGetTools/nuspec
    CMAKE_CONFIGURATIONS Release Debug                   # Optional: defaults to no restrictions given
    ## NuSpec-related section below
    METADATA
        ## Required elements
        PACKAGE ${PROJECT_NAME}
        VERSION ${PROJECT_VERSION}
        DESCRIPTION "It's *the* package."
        AUTHORS katusk cmake CMakeNuGetTools
        ## Optional elements
        PROJECT_URL https://github.com/katusk
        ICON fake.png
        COPYRIGHT katusk
        REPOSITORY_TYPE git
        REPOSITORY_URL https://github.com/katusk/whatnot.git
        REPOSITORY_BRANCH dev
        REPOSITORY_COMMIT e1c65e4524cd70ee6e22abe33e6cb6ec73938cb3
        ## Collection elements
        ## Currently only DEPENDENCIES which is automatically generated based on nuget_add_dependencies() calls.
    ## FILES node: required by our CMake implementation
    FILES
        FILE_SRC "$<TARGET_FILE:WriteNuspecSimple>" FILE_TARGET "build/native/x64-windows/bin/$<LOWER_CASE:$<CONFIG>>"
        FILE_SRC "$<TARGET_LINKER_FILE:WriteNuspecSimple>" FILE_TARGET "build/native/x64-windows/lib/$<LOWER_CASE:$<CONFIG>>"
        # CMake exports
        FILE_SRC "${CMAKE_INSTALL_PREFIX}/cmake/WriteNuspecSimpleConfig.cmake" FILE_TARGET "build/native/x64-windows/cmake"
        FILE_SRC "${CMAKE_INSTALL_PREFIX}/cmake/WriteNuspecSimpleConfigVersion.cmake" FILE_TARGET "build/native/x64-windows/cmake"
        FILE_SRC "${CMAKE_INSTALL_PREFIX}/cmake/WriteNuspecSimpleTargets.cmake" FILE_TARGET "build/native/x64-windows/cmake"
        FILE_SRC "${CMAKE_INSTALL_PREFIX}/cmake/WriteNuspecSimpleTargets-$<LOWER_CASE:$<CONFIG>>.cmake" FILE_TARGET "build/native/x64-windows/cmake"
        # Only in Debug mode: .pdb file
        CMAKE_CONDITIONAL_SECTION $<CONFIG:Debug>
            FILE_SRC "$<TARGET_PDB_FILE:WriteNuspecSimple>" FILE_TARGET "build/native/x64-windows/bin/$<LOWER_CASE:$<CONFIG>>"
)
