# CMakeNuGetTools (WIP)

CMake functions for adding NuGet package dependencies with CMake exports or .targets file, generating and merging `.nuspec` files, calling nuget pack, etc. See `tests/` for CMake projects using the functions (function names are prefixed with `nuget_`).

## Examples

```cmake
# Call this once before any other nuget_* calls.
nuget_initialize()

# NuGet install icu and flatbuffers packages, and import their CMake export files.
nuget_add_dependencies(
    PACKAGE flatbuffers.x64-windows.vcpkg-export VERSION 1.11.0-1 CMAKE_PREFIX_PATHS installed/x64-windows
    PACKAGE icu.x64-windows.vcpkg-export PUBLIC VERSION 65.1.0-2 CMAKE_PREFIX_PATHS installed/x64-windows
)

# After the above nuget_add_dependencies(), you can:
find_package(ICU REQUIRED COMPONENTS data uc io)
find_package(Flatbuffers CONFIG REQUIRED)
```

If you are using a Visual Studio generator with CMake, you can also write the following. Please note this is rather not CMakeish; `.targets` files are primarily intended for Visual Studio projects.

```cmake
nuget_add_dependencies(
    PACKAGE flatbuffers.x64-windows.vcpkg-export
    VERSION 1.11.0-1
    IMPORT_DOT_TARGETS_AS flatbuffers
    INCLUDE_DIRS "installed/x64-windows/include"
)
```

You get some helper functions for NuGet packages added via nuget_add_dependencies(), e.g.:

```cmake
nuget_get_installed_dependencies_dirs(DEPENDENCIES_DIRS)
```

With `file(GENERATE` of CMake and some argument parsing you can generate `.nuspec` files using the power of CMake including the use of generator expressions:

```cmake
nuget_generate_nuspec_files(
    # CMake-specific arguments section
    CMAKE_OUTPUT_DIR ${CMAKE_BINARY_DIR}/CMakeNuGetTools
    CMAKE_CONFIGURATIONS Release Debug
    # NuSpec-related sections
    METADATA
        # Required elements
        PACKAGE ${PROJECT_NAME}
        VERSION ${PROJECT_VERSION}
        DESCRIPTION "The package."
        AUTHORS mjhowell fediggs
        # Optional elements
        PROJECT_URL https://github.com/katusk/CMakeNuGetTools
        REPOSITORY_TYPE git
        REPOSITORY_URL https://github.com/katusk/CMakeNuGetTools.git
        REPOSITORY_BRANCH dev
        REPOSITORY_COMMIT e1c65e4524cd70ee6e22abe33e6cb6ec73938cb3
        # Collection elements
        # Currently only DEPENDENCIES which is automatically generated based on nuget_add_dependencies() calls.
    # FILES node: required by our CMake implementation
    FILES
        FILE_SRC "$<TARGET_FILE:WriteNuspecSimple>" FILE_TARGET "build/native/x64-windows/bin/$<LOWER_CASE:$<CONFIG>>"
        # CMake exports
        FILE_SRC "${CMAKE_INSTALL_PREFIX}/cmake/WriteNuspecSimpleConfig.cmake" FILE_TARGET "build/native/x64-windows/cmake"
        FILE_SRC "${CMAKE_INSTALL_PREFIX}/cmake/WriteNuspecSimpleConfigVersion.cmake" FILE_TARGET "build/native/x64-windows/cmake"
        FILE_SRC "${CMAKE_INSTALL_PREFIX}/cmake/WriteNuspecSimpleTargets.cmake" FILE_TARGET "build/native/x64-windows/cmake"
        FILE_SRC "${CMAKE_INSTALL_PREFIX}/cmake/WriteNuspecSimpleTargets-$<LOWER_CASE:$<CONFIG>>.cmake" FILE_TARGET "build/native/x64-windows/cmake"
        # Only in Debug mode: .pdb file
        CMAKE_CONDITIONAL_SECTION $<CONFIG:Debug>
            FILE_SRC "$<TARGET_PDB_FILE:WriteNuspecSimple>" FILE_TARGET "build/native/x64-windows/bin/$<LOWER_CASE:$<CONFIG>>"
)
```

## TODO
* Write documentation
* Finish up semantic versioning-related functionality
* Code several small extensions to existing functionality
* Create scripts extracting individual packages from Vcpkg as separate NuGet packages
* Create a meta-build example with a native library project, a managed wrapper project, and a managed app project.
