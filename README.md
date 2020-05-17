# CMakeNuGetTools (WIP)

CMakeNuGetTools has CMake functions for adding NuGet package dependencies with CMake exports or a native `.targets` file, generating and merging `.nuspec` files, calling nuget pack, and more. See Examples section below, and the `tests` directory for CMake projects using the functions: relevant function names are prefixed with `nuget_`.

## Examples

You can download NuGet package dependencies and let CMake know about CMake export files in those packages via `nuget_add_dependencies()` calls:

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

If you are using a Visual Studio generator with CMake, you can also write the following. Please note this is rather not CMakeish: `.targets` files are primarily intended for Visual Studio projects.

```cmake
# Creates a "flatbuffers" build target you can link against.
nuget_add_dependencies(
    PACKAGE flatbuffers.x64-windows.vcpkg-export
    VERSION 1.11.0-1
    IMPORT_DOT_TARGETS_AS flatbuffers
    INCLUDE_DIRS "installed/x64-windows/include"
)
```

You get some helper functions for NuGet packages added via `nuget_add_dependencies()`. For example:

```cmake
nuget_get_installed_dependencies_dirs(DEPENDENCIES_DIRS)
```

You can generate `.nuspec` files using the power of CMake including the use of generator expressions via the `nuget_generate_nuspec_files()` function, see following example. This function uses the `file(GENERATE ...)` built-in of CMake and some argument parsing at its core.

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
        # Currently only DEPENDENCIES which is automatically generated based on nuget_add_dependencies() calls:
        # all packages marked explicitly as PUBLIC or INTERFACE become a dependency entry.
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

## Scope & Aims

CMakeNuGetTools aims to be the cross-platform NuGet package management solution for CMake-based C/C++ projects. At its core, it is a CMake wrapper around the [NuGet command-line interface](https://docs.microsoft.com/en-us/nuget/install-nuget-client-tools#nugetexe-cli) (NuGet CLI), that "provides all NuGet capabilities on Windows, provides most features on Mac and Linux when running under Mono".

Relying solely on the NuGet CLI means that CMakeNuGetTools is not depending on any of the existing MSBuild, Visual Studio, or dotnet CLI tooling for NuGet-related capabilities. You can use any build toolchain you want.

For extracting semantic version information for the creation of automatically versioned NuGet packages, CMakeNuGetTools currently relies on the git CLI. Features around querying version tags are optional: the git CLI is only needed if you need automatic versioning features.

## Further Plans
* Create scripts extracting individual packages from Vcpkg as *separate* NuGet packages
* Finish up semantic versioning-related functionality
* Code several small extensions to existing functionality
* Create a meta-build example with a native library project, a managed wrapper project, and a managed app project
* Write documentation
