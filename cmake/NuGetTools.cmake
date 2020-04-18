cmake_minimum_required(VERSION 3.8.2 FATAL_ERROR)

## User-settable cache variables
set(NUGET_COMMAND "" CACHE STRING
    "NuGet executable used for package installs. Empty means NuGetTools is disabled."
)
set(NUGET_PACKAGES_DIR "${CMAKE_SOURCE_DIR}/packages" CACHE PATH
    "Path to the directory used by NuGet to store installed packages."
)

## Includes
include("${CMAKE_CURRENT_LIST_DIR}/internal/NuGetTools.helper.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/internal/NuGetImport.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/internal/NuGetPack.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/internal/NuGetGit.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/internal/NuGetSemVer.cmake")
