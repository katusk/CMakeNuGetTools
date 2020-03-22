# Internal. See arguments below.
function(_nuget_single_register_as_interface)
    # Inputs
    set(options INTERFACE)
    set(oneValueArgs PACKAGE VERSION)
    set(multiValueArgs "")
    cmake_parse_arguments(_arg
        "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGV}
    )
    _nuget_helper_error_if_unparsed_args(
        "${_arg_UNPARSED_ARGUMENTS}"
        "${_arg_KEYWORDS_MISSING_VALUES}"
    )
    # Actual functionality
    _nuget_core_register("${_arg_PACKAGE}" "${_arg_VERSION}" INTERFACE)
endfunction()

# Internal. See arguments below. This should be called if IMPORT_DOT_TARGETS or IMPORT_DOT_TARGETS_AS
# is explicitly specified by the user. Default usage requirement is PRIVATE.
function(_nuget_single_import_dot_targets)
    # Inputs
    set(options IGNORE_INCLUDE_DIR PUBLIC PRIVATE IMPORT_DOT_TARGETS)
    set(oneValueArgs PACKAGE VERSION IMPORT_DOT_TARGETS_AS INCLUDE_DIR POST_INSTALL)
    set(multiValueArgs "")
    cmake_parse_arguments(_arg
        "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGV}
    )
    _nuget_helper_error_if_unparsed_args(
        "${_arg_UNPARSED_ARGUMENTS}"
        "${_arg_KEYWORDS_MISSING_VALUES}"
    )
    # Stricter validation
    if(_arg_PUBLIC)
        if(_arg_PRIVATE)
            message(FATAL_ERROR "PUBLIC and PRIVATE usage requirement options are mutually exclusive.")
        endif()
        set(USAGE_REQUIREMENT PUBLIC)
    else()
        set(USAGE_REQUIREMENT PRIVATE) # Default
    endif()
    # Actual functionality
    _nuget_core_register("${_arg_PACKAGE}" "${_arg_VERSION}" "${USAGE_REQUIREMENT}")
    _nuget_core_install("${_arg_PACKAGE}" "${_arg_VERSION}" "${_arg_POST_INSTALL}")
    _nuget_core_import_dot_targets(
        "${_arg_PACKAGE}"
        "${_arg_VERSION}"
        "${_arg_IMPORT_DOT_TARGETS_AS}"
        "${_arg_INCLUDE_DIR}"
        "${_arg_IGNORE_INCLUDE_DIR}"
    )
endfunction()

# Internal. See arguments below. This should be called by default if no import method is specified explicitly.
# NOTE: the IMPORT_CMAKE_EXPORTS option is only cosmetics for the user. The presence of IMPORT_FROM is not treated
# as a differentiator indicating an "IMPORT_CMAKE_EXPORTS" import method either: if the user explicitly provided a
# different import method, the dispatcher logic dispatches the call accordingly and IMPORT_FROM is not taken into
# account. E.g. providing IMPORT_DOT_TARGETS and IMPORT_FROM in _nuget_single_dependencies() would dispatch the call
# to _nuget_single_import_dot_targets() but IMPORT_FROM does not have any meaning there, so that function should
# raise a CMake Error. Default usage requirement is PRIVATE.
function(_nuget_single_import_cmake_exports)
    # Inputs
    set(options NO_OVERRIDE MODULE PUBLIC PRIVATE IMPORT_CMAKE_EXPORTS)
    set(oneValueArgs PACKAGE VERSION IMPORT_FROM POST_INSTALL)
    set(multiValueArgs "")
    cmake_parse_arguments(_arg
        "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGV}
    )
    _nuget_helper_error_if_unparsed_args(
        "${_arg_UNPARSED_ARGUMENTS}"
        "${_arg_KEYWORDS_MISSING_VALUES}"
    )
    # Stricter validation
    if(_arg_PUBLIC)
        if(_arg_PRIVATE)
            message(FATAL_ERROR "PUBLIC and PRIVATE usage requirement options are mutually exclusive.")
        endif()
        set(USAGE_REQUIREMENT PUBLIC)
    else()
        set(USAGE_REQUIREMENT PRIVATE) # Default
    endif()
    # Actual functionality
    _nuget_core_register("${_arg_PACKAGE}" "${_arg_VERSION}" "${USAGE_REQUIREMENT}")
    _nuget_core_install("${_arg_PACKAGE}" "${_arg_VERSION}" "${_arg_POST_INSTALL_HOOK}")
    _nuget_core_import_cmake_exports(
        "${_arg_PACKAGE}"
        "${_arg_VERSION}"
        "${_arg_IMPORT_FROM}"
        "${_arg_MODULE}"
        "${_arg_NO_OVERRIDE}"
    )
endfunction()

# Internal. Dispatcher to above functions.
function(_nuget_single_dependencies)
    # Case: INTERFACE
    list(FIND "${ARGV}" INTERFACE INTERFACE_IDX)
    if(NOT ${INTERFACE_IDX} EQUAL -1)
        _nuget_single_register_as_interface(${ARGV})
        return()
    endif()
    # Case: IMPORT_DOT_TARGETS or IMPORT_DOT_TARGETS_AS
    list(FIND "${ARGV}" IMPORT_DOT_TARGETS IMPORT_DOT_TARGETS_IDX)
    list(FIND "${ARGV}" IMPORT_DOT_TARGETS_AS IMPORT_DOT_TARGETS_AS_IDX)
    if(NOT ${IMPORT_DOT_TARGETS_IDX} EQUAL -1 OR NOT ${IMPORT_DOT_TARGETS_AS_IDX} EQUAL -1)
        _nuget_single_import_dot_targets(${ARGV})
        return()
    endif()
    # Default: no explicit import method (other than IMPORT_CMAKE_EXPORTS) provided
    _nuget_single_import_cmake_exports(${ARGV}) # Default
endfunction()

# Internal. Process each PACKAGE argument pack one-by-one. Deliberately a *function*.
function(_nuget_foreach_dependencies)
    set(ARGS_HEAD "")
    set(ARGS_TAIL ${ARGV})
    while(NOT "${ARGS_TAIL}" STREQUAL "")
        _nuget_helper_cut_arg_list(PACKAGE "${ARGS_TAIL}" ARGS_HEAD ARGS_TAIL)
        _nuget_single_dependencies(${ARGS_HEAD})
    endwhile()
endfunction()
