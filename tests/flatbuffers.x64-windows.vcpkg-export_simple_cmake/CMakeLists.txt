set(PROJECT_ROOT "${CMAKE_CURRENT_LIST_DIR}/../..")
include("${PROJECT_ROOT}/cmake/NuGetTools.cmake")

## CMake setup
cmake_minimum_required(VERSION 3.8.2 FATAL_ERROR)
project(flatbuffers_simple LANGUAGES CXX)

## Import CMake exports of flatbuffers from NuGet
nuget_dependencies(
    PACKAGE flatbuffers.x64-windows.vcpkg-export
    VERSION 1.11.0-1
    IMPORT_FROM installed/x64-windows/share/flatbuffers
)

## Find external dependencies
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
add_library(FlatbuffersSimple sample_binary.cpp)
target_link_libraries(FlatbuffersSimple PRIVATE GeneratedFiles)
target_include_directories(FlatbuffersSimple PRIVATE "${FLATBUFFERS_INTERFACE_INCLUDE_DIRECTORIES}") # Only need flatbuffers/flatbuffers.h
