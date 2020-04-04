cmake_minimum_required(VERSION 3.8.2 FATAL_ERROR)
project(CMakeNuGetToolsTests NONE)
enable_testing()

# Tests
add_test(NAME NuGetTools.helper.test.cmake COMMAND "${CMAKE_COMMAND}" -P "${CMAKE_SOURCE_DIR}/tests/NuGetTools.helper.test.cmake")
