set(PROJECT_ROOT "${CMAKE_CURRENT_LIST_DIR}/../..")
include("${PROJECT_ROOT}/cmake/NuGetTools.cmake")

## CMake setup
cmake_minimum_required(VERSION 3.8.2 FATAL_ERROR)
project(flatbuffers_simple LANGUAGES CXX)
set(CMAKE_C_COMPILER "")

## NuGet setup: call it only once before any other nuget_* calls.
nuget_init()

## Import flatbuffers via .targets file from NuGet package exported from Vcpkg. 
## Using .targets files is not CMake'ish at all but possible with Visual Studio generators...
set(FLATBUFFERS_PACKAGE_ID flatbuffers.x64-windows.vcpkg-export)
nuget_dependencies(
    PACKAGE ${FLATBUFFERS_PACKAGE_ID}
    VERSION 1.11.0-1
    IMPORT_DOT_TARGETS_AS flatbuffers
    INCLUDE_DIRS "installed/x64-windows/include"
)

## We are onto non-CMake way of doing things: no find_package() call here... A target has been created by
## the previous command that you can use to link against.
# find_package(Flatbuffers CONFIG REQUIRED)

## Generated sources
set(FLATC_COMMAND "${NUGET_DEPENDENCY_DIR_${FLATBUFFERS_PACKAGE_ID}}/installed/x64-windows/tools/flatbuffers/flatc.exe")
add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/generated/monster.h"
    COMMAND "${FLATC_COMMAND}" --cpp -o "${CMAKE_CURRENT_BINARY_DIR}/generated" "${CMAKE_CURRENT_SOURCE_DIR}/monster.fbs"
    # From https://github.com/google/flatbuffers/blob/3ff6cdf49181061bd545bcd3a2a292bca3e8ef6b/samples/monster.fbs
    DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/monster.fbs"
)
add_custom_target(GeneratedFilesInternal DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/generated/monster.h")
add_library(GeneratedFiles INTERFACE)
# Not to be exported. This target is for internal use only, i.e. only other internal targets can use this interface include.
target_include_directories(GeneratedFiles INTERFACE "${CMAKE_CURRENT_BINARY_DIR}/generated")
add_dependencies(GeneratedFiles GeneratedFilesInternal)

## Create executable
# From https://github.com/google/flatbuffers/blob/42c08cbca601688af921eaa9384844a632e2cde8/samples/sample_binary.cpp
add_executable(FlatbuffersSimple sample_binary.cpp)
target_link_libraries(FlatbuffersSimple PRIVATE GeneratedFiles flatbuffers)
