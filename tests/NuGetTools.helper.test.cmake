## Simply run:
## $ cmake -P tests/NuGetTools.helper.test.cmake
cmake_minimum_required(VERSION 3.8.2 FATAL_ERROR)
set(PROJECT_ROOT "${CMAKE_CURRENT_LIST_DIR}/..")
include("${PROJECT_ROOT}/cmake/NuGetTools.helper.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Helper.cmake")

## Test input
set(TEST_PACKAGE_LIST_HEAD PACKAGE flatbuffers VERSION 1.11.0)
set(TEST_PACKAGE_LIST_TAIL PACKAGE icu VERSION 65.1)
set(TEST_PACKAGE_LIST "${TEST_PACKAGE_LIST_HEAD};${TEST_PACKAGE_LIST_TAIL}")

## Test cases
function(test__nuget_helper_cut_arg_list_1)
    _nuget_helper_cut_arg_list(PACKAGE "${TEST_PACKAGE_LIST}" HEAD TAIL)
    message("test__nuget_helper_cut_arg_list_1(PACKAGE \"${TEST_PACKAGE_LIST}\" \"${HEAD}\" \"${TAIL}\")")
    assert("${TEST_PACKAGE_LIST_HEAD}" STREQUAL "${HEAD}")
    assert("${TEST_PACKAGE_LIST_TAIL}" STREQUAL "${TAIL}")
endfunction()

function(test__nuget_helper_cut_arg_list_2)
    list(JOIN TEST_PACKAGE_LIST " " TEST_PACKAGE_STRING)
    _nuget_helper_cut_arg_list(PACKAGE ${TEST_PACKAGE_STRING} HEAD TAIL)
    message("test__nuget_helper_cut_arg_list_2(PACKAGE \"${TEST_PACKAGE_STRING}\" \"${HEAD}\" \"${TAIL}\")")
    assert("${TEST_PACKAGE_STRING}" STREQUAL "${HEAD}")
    assert("" STREQUAL "${TAIL}")
endfunction()

function(test__nuget_helper_cut_arg_list_3)
    set(TEST_LIST_GARBAGE CONFIG MODULE)
    set(TAIL "${TEST_PACKAGE_LIST_HEAD};${TEST_PACKAGE_LIST_TAIL};${TEST_LIST_GARBAGE}")
    _nuget_helper_cut_arg_list(PACKAGE "${TAIL}" HEAD TAIL)
    message("test__nuget_helper_cut_arg_list_3(PACKAGE _ \"${HEAD}\" \"${TAIL}\")")
    assert("${TEST_PACKAGE_LIST_HEAD}" STREQUAL "${HEAD}")
    assert("${TEST_PACKAGE_LIST_TAIL};${TEST_LIST_GARBAGE}" STREQUAL "${TAIL}")
    _nuget_helper_cut_arg_list(PACKAGE "${TAIL}" HEAD TAIL)
    message("test__nuget_helper_cut_arg_list_3(PACKAGE _ \"${HEAD}\" \"${TAIL}\")")
    assert("${TEST_PACKAGE_LIST_TAIL};${TEST_LIST_GARBAGE}" STREQUAL "${HEAD}")
    assert("" STREQUAL "${TAIL}")
    _nuget_helper_cut_arg_list(PACKAGE "${TAIL}" HEAD TAIL)
    message("test__nuget_helper_cut_arg_list_3(PACKAGE _ \"${HEAD}\" \"${TAIL}\")")
    assert("" STREQUAL "${HEAD}")
    assert("" STREQUAL "${TAIL}")
    message("test__nuget_helper_cut_arg_list_3(PACKAGE _ \"${HEAD}\" \"${TAIL}\")")
    assert("" STREQUAL "${HEAD}")
    assert("" STREQUAL "${TAIL}")
endfunction()

## Invoke test cases
test__nuget_helper_cut_arg_list_1()
test__nuget_helper_cut_arg_list_2()
test__nuget_helper_cut_arg_list_3()
