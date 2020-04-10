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
add_custom_target(export_cmake_and_install.mkdir ALL
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/Release/export_cmake_and_install"
)
add_test(NAME export_cmake_and_install.g
    COMMAND "${CMAKE_COMMAND}" -T v141,host=x64 -G "Visual Studio 15 2017 Win64" -DNUGET_COMMAND=nuget
        "-DNUGET_PACKAGES_DIR=${CMAKE_SOURCE_DIR}/packages" -DCMAKE_CONFIGURATION_TYPES=Release
        "${CMAKE_SOURCE_DIR}/tests/export_cmake_and_install"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/Release/export_cmake_and_install"
)
add_test(NAME export_cmake_and_install.build
    COMMAND "${CMAKE_COMMAND}" --build . --config Release --target ALL_BUILD -- /p:PlatformToolset=v141 /p:Configuration=Release /p:Platform=x64
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/build/cmake/x64-windows/Release/export_cmake_and_install"
)
