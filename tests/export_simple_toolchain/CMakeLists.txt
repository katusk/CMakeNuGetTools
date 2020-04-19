set(PROJECT_ROOT "${CMAKE_CURRENT_LIST_DIR}/../..")
include("${PROJECT_ROOT}/cmake/NuGetTools.cmake")

## CMake setup 1/2
cmake_minimum_required(VERSION 3.8.2 FATAL_ERROR)

## NuGet setup: call it only once before any other nuget_* calls.
nuget_initialize()

## Import toolchain file of Vcpkg from NuGet package exported from Vcpkg
# NB "... it doesn't work when you set CMAKE_TOOLCHAIN_FILE after invoking project() because project() is what actually
# kicks off the compiler detection process. So variables like CMAKE_TOOLCHAIN_FILE, CMAKE_SYSTEM_NAME, CMAKE_C_COMPILER,
# etc must be set before project() is called, otherwise CMake just uses the defaults for the host system."
# -- https://github.com/queezythegreat/arduino-cmake/issues/38
nuget_add_dependencies(
    PACKAGE flatbuffers.x64-windows.vcpkg-export
    VERSION 1.11.0-1
    CMAKE_TOOLCHAIN_FILE "scripts/buildsystems/vcpkg.cmake"
)

## CMake setup 2/2
project(flatbuffers_simple_toolchain LANGUAGES CXX)
set(CMAKE_C_COMPILER "")

## Find external dependencies
# Business as usual from this point on. The above nuget_add_dependencies() takes care of setting the CMAKE_PREFIX_PATH.
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
# From https://github.com/google/flatbuffers/blob/42c08cbca601688af921eaa9384844a632e2cde8/samples/sample_binary.cpp
add_executable(FlatbuffersSimpleToolchain sample_binary.cpp)
target_link_libraries(FlatbuffersSimpleToolchain PRIVATE GeneratedFiles)
target_include_directories(FlatbuffersSimpleToolchain PRIVATE "${FLATBUFFERS_INTERFACE_INCLUDE_DIRECTORIES}") # Only need flatbuffers/flatbuffers.h
