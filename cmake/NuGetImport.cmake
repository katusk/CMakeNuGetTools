## Include implementation
include("${CMAKE_CURRENT_LIST_DIR}/NuGetImport.core.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/NuGetImport.single.cmake")

## Public interface. Needs to be macro for properly setting CMAKE_MODULE_PATH
## or CMAKE_PREFIX_PATH.
macro(nuget_dependencies)
    # Sanity checks
    if("${NUGET_COMMAND}" STREQUAL "")
        message(WARNING "NuGetTools for CMake is disabled: returning without doing anything.")
        return()
    endif()
    if("${ARGV}" STREQUAL "")
        message(FATAL_ERROR "No arguments provided.")
        return()
    endif()
    # Process each PACKAGE argument pack one-by-one
    set(nuget_dependencies_ARGS_HEAD "")
    set(nuget_dependencies_ARGS_TAIL ${ARGV})
    while(NOT "${nuget_dependencies_ARGS_TAIL}" STREQUAL "")
        _nuget_helper_cut_arg_list(
            PACKAGE
            "${nuget_dependencies_ARGS_TAIL}"
            nuget_dependencies_ARGS_HEAD
            nuget_dependencies_ARGS_TAIL
        )
        _nuget_single_dependencies(${nuget_dependencies_ARGS_HEAD})
        list(FIND nuget_dependencies_ARGS_HEAD PACKAGE nuget_dependecies_PACKAGE_IDX)
        math(EXPR nuget_dependecies_PACKAGE_ID_IDX "${nuget_dependecies_PACKAGE_IDX} + 1")
        list(GET nuget_dependencies_ARGS_HEAD ${nuget_dependecies_PACKAGE_ID_IDX} nuget_dependecies_PACKAGE_ID)
        _nuget_core_import_cmake_exports_set_cmake_paths("${nuget_dependecies_PACKAGE_ID}")
    endwhile()
    unset(nuget_dependencies_ARGS_HEAD)
    unset(nuget_dependencies_ARGS_TAIL)
    unset(nuget_dependecies_PACKAGE_IDX)
    unset(nuget_dependecies_PACKAGE_ID_IDX)
    unset(nuget_dependecies_PACKAGE_ID)
endmacro()
