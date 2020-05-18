# CMakeNuGetTools (WIP)

CMakeNuGetTools has CMake functions for adding NuGet package dependencies with CMake exports or native `.targets` files, generating and merging `.nuspec` files, calling nuget pack, and more. See Examples section below, and the `tests` directory for CMake projects using the functions: relevant function names are prefixed with `nuget_`.

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

## Scope

CMakeNuGetTools aims to be the cross-platform NuGet package management solution for CMake-based C/C++ projects. At its core, it is a CMake wrapper around the [NuGet command-line interface](https://docs.microsoft.com/en-us/nuget/install-nuget-client-tools#nugetexe-cli) (NuGet CLI), that "provides all NuGet capabilities on Windows, provides most features on Mac and Linux when running under Mono".

Relying solely on the NuGet CLI means that CMakeNuGetTools is not depending on any of the existing MSBuild, Visual Studio, or dotnet CLI tooling for NuGet-related capabilities. You can use any build toolchain you want.

For extracting semantic version information for the creation of automatically versioned NuGet packages, CMakeNuGetTools currently relies on the git CLI. Features around querying version tags are optional: the git CLI is only needed if you need automatic versioning features.

### Context

CMakeNuGetTools was born with the following considerations in mind from the perspective of a cross-platform CMake-based C/C++ project:

* CMakeNuGetTools should only rely on the cross-platform and stand-alone NuGet CLI for NuGet-related capabilities.
* One should be able to automatically create a versioned NuGet package per platform (Windows, Linux, or macOS) from this project containing both Debug and Release native binaries that can be consumed by other CMake projects, `.vcxproj`-based C/C++ projects on Windows, and `.csproj`-based managed C# projects on all supported platforms by .NET Core. (You need PInvoke bindings for C/C# interoperability of course: we are solely talking about the NuGet infrastructure itself here.)
* One should be able to easily put additional NuGet-related customized or generated files, like `.targets` files under the `build/native`, `build`, or `buildTransitive` directories inside the NuGet package to be created. Without this, one cannot achieve some of the goals in the previous point.
* One should be able to create multiple NuGet packages with different directory layouts from this project. For example, one package containing both Debug and Release binaries in a custom directory layout, and another package containing only Release binaries conforming to the conventional NuGet package directory layout under the [`runtimes` directory](https://docs.microsoft.com/en-us/dotnet/core/rid-catalog) inside the package.
* One should be able to use multiple other NuGet packages from this project also differentiating between PUBLIC (installed and propagated as NuGet package dependency), PRIVATE (installed only), and INTERFACE (propagated as NuGet package dependency only) dependencies. For example, NuGet packages to be consumed containing only static libraries that are only used internally, or NuGet packages containing libraries only used for testing can be marked as PRIVATE; and NuGet packages containing shared libraries can be marked as PUBLIC.

## Queued Tasks
* Create scripts extracting individual packages from Vcpkg as *separate* NuGet packages
* Finish up semantic versioning-related functionality
* Code several small extensions to existing functionality
* Create a meta-build example with a native library project, a managed wrapper project, and a managed app project
* Write documentation
