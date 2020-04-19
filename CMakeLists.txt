## Meta build project for running tests
cmake_minimum_required(VERSION 3.8.2 FATAL_ERROR)
project(CMakeNuGetToolsTests NONE)
enable_testing()

## Tests
# Test: NuGetTools.helper.test.cmake
add_test(NAME NuGetTools.helper.test.cmake
    COMMAND "${CMAKE_COMMAND}" -P "${CMAKE_SOURCE_DIR}/tests/NuGetTools.helper.test.cmake"
)

# Test: export_simple_cmake
# TODO: we rely on sequential execution here...
add_custom_target(export_simple_cmake.mkdir ALL
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/Release/export_simple_cmake"
)
add_test(NAME export_simple_cmake.g
    COMMAND "${CMAKE_COMMAND}" -T v141,host=x64 -G "Visual Studio 15 2017 Win64" -DNUGET_COMMAND=nuget
        "-DNUGET_PACKAGES_DIR=${CMAKE_SOURCE_DIR}/packages" -DCMAKE_CONFIGURATION_TYPES=Release
        "${CMAKE_SOURCE_DIR}/tests/export_simple_cmake"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/Release/export_simple_cmake"
)
add_test(NAME export_simple_cmake.build
    COMMAND "${CMAKE_COMMAND}" --build . --config Release --target ALL_BUILD -- /p:PlatformToolset=v141 /p:Configuration=Release /p:Platform=x64
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/Release/export_simple_cmake"
)

# Test: export_simple_dot_targets
# TODO: we rely on sequential execution here...
add_custom_target(export_simple_dot_targets.mkdir ALL
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/Release/export_simple_dot_targets"
)
add_test(NAME export_simple_dot_targets.g
    COMMAND "${CMAKE_COMMAND}" -T v141,host=x64 -G "Visual Studio 15 2017 Win64" -DNUGET_COMMAND=nuget
        "-DNUGET_PACKAGES_DIR=${CMAKE_SOURCE_DIR}/packages" -DCMAKE_CONFIGURATION_TYPES=Release
        "${CMAKE_SOURCE_DIR}/tests/export_simple_dot_targets"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/Release/export_simple_dot_targets"
)
add_test(NAME export_simple_dot_targets.build
    COMMAND "${CMAKE_COMMAND}" --build . --config Release --target ALL_BUILD -- /p:PlatformToolset=v141 /p:Configuration=Release /p:Platform=x64
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/Release/export_simple_dot_targets"
)

# Test: export_cmake_and_install
# TODO: we rely on sequential execution here...
add_custom_target(export_cmake_and_install.build.mkdir ALL
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/Release/export_cmake_and_install"
)
add_test(NAME export_cmake_and_install.g
    COMMAND "${CMAKE_COMMAND}" -T v141,host=x64 -G "Visual Studio 15 2017 Win64" -DNUGET_COMMAND=nuget
        "-DNUGET_PACKAGES_DIR=${CMAKE_SOURCE_DIR}/packages" -DCMAKE_CONFIGURATION_TYPES=Release
        "-DCMAKE_INSTALL_PREFIX=${CMAKE_SOURCE_DIR}/install/cmake/x64-windows/Release/export_cmake_and_install"
        "${CMAKE_SOURCE_DIR}/tests/export_cmake_and_install"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/Release/export_cmake_and_install"
)
add_test(NAME export_cmake_and_install.build
    COMMAND "${CMAKE_COMMAND}" --build . --config Release --target ALL_BUILD -- /p:PlatformToolset=v141 /p:Configuration=Release /p:Platform=x64
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/Release/export_cmake_and_install"
)
add_custom_target(export_cmake_and_install.install.mkdir ALL
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_SOURCE_DIR}/install/cmake/x64-windows/Release/export_cmake_and_install"
)
add_test(NAME export_cmake_and_install.install
    COMMAND "${CMAKE_COMMAND}" --build . --config Release --target INSTALL -- /p:PlatformToolset=v141 /p:Configuration=Release /p:Platform=x64
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/Release/export_cmake_and_install"
)

# Test: write_nuspec_simple
# TODO: we rely on sequential execution here...
add_custom_target(write_nuspec_simple.mkdir ALL
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/MultiConfig/write_nuspec_simple"
)
add_test(NAME write_nuspec_simple.g
    COMMAND "${CMAKE_COMMAND}" -T v141,host=x64 -G "Visual Studio 15 2017 Win64" -DNUGET_COMMAND=nuget
        "-DNUGET_PACKAGES_DIR=${CMAKE_SOURCE_DIR}/packages" "-DCMAKE_CONFIGURATION_TYPES=Release;Debug"
        "-DCMAKE_INSTALL_PREFIX=${CMAKE_SOURCE_DIR}/install/cmake/x64-windows/MultiConfig/write_nuspec_simple"
        "${CMAKE_SOURCE_DIR}/tests/write_nuspec_simple"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/MultiConfig/write_nuspec_simple"
)
add_test(NAME write_nuspec_simple.release.build
    COMMAND "${CMAKE_COMMAND}" --build . --config Release --target ALL_BUILD -- /p:PlatformToolset=v141 /p:Configuration=Release /p:Platform=x64
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/MultiConfig/write_nuspec_simple"
)
add_test(NAME write_nuspec_simple.debug.build
    COMMAND "${CMAKE_COMMAND}" --build . --config Debug --target ALL_BUILD -- /p:PlatformToolset=v141 /p:Configuration=Debug /p:Platform=x64
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/MultiConfig/write_nuspec_simple"
)
add_custom_target(write_nuspec_simple.install.mkdir ALL
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_SOURCE_DIR}/install/cmake/x64-windows/MultiConfig/write_nuspec_simple"
)
add_test(NAME write_nuspec_simple.release.install
    COMMAND "${CMAKE_COMMAND}" --build . --config Release --target INSTALL -- /p:PlatformToolset=v141 /p:Configuration=Release /p:Platform=x64
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/MultiConfig/write_nuspec_simple"
)
add_test(NAME write_nuspec_simple.debug.install
    COMMAND "${CMAKE_COMMAND}" --build . --config Debug --target INSTALL -- /p:PlatformToolset=v141 /p:Configuration=Debug /p:Platform=x64
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/MultiConfig/write_nuspec_simple"
)
add_test(NAME write_nuspec_simple.mergeandpack
    COMMAND "${CMAKE_COMMAND}"
        "-DMERGE_OUTPUT=CMakeNuGetTools/write_nuspec_simple.nuspec"
        "-DMERGE_INPUTS=CMakeNuGetTools/write_nuspec_simple.Release.nuspec;CMakeNuGetTools/write_nuspec_simple.Debug.nuspec"
        -DNUGET_COMMAND=nuget
        "-DNUPKG_OUTPUT_DIRECTORY=${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/MultiConfig/write_nuspec_simple/CMakeNuGetTools/nupkg"
        -P "${CMAKE_SOURCE_DIR}/CMakeLists.pack.cmake"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/MultiConfig/write_nuspec_simple"
)

# Test: export_simple_toolchain
# TODO: we rely on sequential execution here...
add_custom_target(export_simple_toolchain.mkdir ALL
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/Release/export_simple_toolchain"
)
add_test(NAME export_simple_toolchain.g
    COMMAND "${CMAKE_COMMAND}" -T v141,host=x64 -G "Visual Studio 15 2017 Win64" -DNUGET_COMMAND=nuget
        "-DNUGET_PACKAGES_DIR=${CMAKE_SOURCE_DIR}/packages" -DCMAKE_CONFIGURATION_TYPES=Release
        "${CMAKE_SOURCE_DIR}/tests/export_simple_toolchain"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/Release/export_simple_toolchain"
)
add_test(NAME export_simple_toolchain.build
    COMMAND "${CMAKE_COMMAND}" --build . --config Release --target ALL_BUILD -- /p:PlatformToolset=v141 /p:Configuration=Release /p:Platform=x64
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/Release/export_simple_toolchain"
)

# Test: NuGetTools.helper.test.cmake
add_test(NAME NuGetSemVer.test.cmake
    COMMAND "${CMAKE_COMMAND}" -P "${CMAKE_SOURCE_DIR}/tests/NuGetSemVer.test.cmake"
)
