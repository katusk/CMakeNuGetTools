cmake_minimum_required(VERSION 3.8.2 FATAL_ERROR)

## User-settable cache variables
set(NUGET_COMMAND "" CACHE STRING
    "NuGet executable used for package installs. Empty means NuGetTools is disabled."
)
set(NUGET_PACKAGES_DIR "${CMAKE_SOURCE_DIR}/packages" CACHE PATH
    "Path to the directory used by NuGet to store installed packages."
)
set(NUGET_DEFAULT_POST_INSTALL_HOOK "" CACHE FILEPATH
    "Path to default CMake script to be executed after a successful NuGet install if not explicitly provided for the given package."
)

## Includes
include("${CMAKE_CURRENT_LIST_DIR}/internal/NuGetTools.helper.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/internal/NuGetImport.cmake")
