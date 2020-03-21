## Include implementation
include("${CMAKE_CURRENT_LIST_DIR}/NuGetImport.core.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/NuGetImport.single.cmake")

## Public interface
function(nuget_dependencies)
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
    set(ARGS_HEAD "")
    set(ARGS_TAIL ${ARGV})
    while(NOT "${ARGS_TAIL}" STREQUAL "")
        _nuget_helper_cut_arg_list(PACKAGE "${ARGS_TAIL}" ARGS_HEAD ARGS_TAIL)
        _nuget_single_dependencies(${ARGS_HEAD})
    endwhile()
endfunction()
