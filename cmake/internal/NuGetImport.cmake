## Include implementation
include("${CMAKE_CURRENT_LIST_DIR}/NuGetImport.core.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/NuGetImport.single.cmake")

## Public interface. Needs to be macro for properly setting CMAKE_MODULE_PATH
## and CMAKE_PREFIX_PATH. It is assumed to be called from directory scope
## (or from another macro that is in dir. scope etc.).
macro(nuget_dependencies)
    # Sanity checks
    if("${NUGET_COMMAND}" STREQUAL "")
        message(WARNING "NuGetTools for CMake is disabled: doing nothing.")
        return()
    endif()
    if("${ARGV}" STREQUAL "")
        message(FATAL_ERROR "No arguments provided.")
        return()
    endif()
    # Reset last registered packages list. This is about to be filled in with
    # packages registered via only this single nuget_dependencies() call.
    set(NUGET_LAST_DEPENDENCIES_REGISTERED "" CACHE INTERNAL "")
    # Process each PACKAGE argument pack one-by-one. This is a *function* call.
    _nuget_foreach_dependencies(${ARGV})
    # Foreach's loop_var should not introduce a new real variable: we are safe macro-wise.
    foreach(PACKAGE_ID IN LISTS NUGET_LAST_DEPENDENCIES_REGISTERED)
        # Set CMAKE_MODULE_PATH and CMAKE_PREFIX_PATH via a *macro* call. Since
        # nuget_dependencies() is a macro as well, no new scopes are introduced
        # between the call of nuget_dependencies() and setting those variables.
        # I.e. CMake's find_package() will respect those set variables within the
        # same scope (or below directory scopes for example).
        _nuget_core_import_cmake_exports_set_cmake_paths("${PACKAGE_ID}")
    endforeach()
    # NOTE: Make sure we did not introduce new normal variables here. Then we are safe macro-wise.
    # (NUGET_LAST_DEPENDENCIES_REGISTERED is an internal *cache* variable so that does not count.)
endmacro()
