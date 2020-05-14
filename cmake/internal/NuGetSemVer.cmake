## Include implementation
include("${CMAKE_CURRENT_LIST_DIR}/NuGetSemVer.git.cmake")

## Public interface.
function(nuget_git_get_semantic_version)
    set(options "")
    set(oneValueArgs TAG_PREFIX PRERELEASE_LABEL FULL CORE MAJOR MINOR PATCH PRERELEASE)
    set(multiValueArgs "")
    cmake_parse_arguments(_arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGV})
    nuget_internal_helper_error_if_unparsed_args("${_arg_UNPARSED_ARGUMENTS}" "${_arg_KEYWORDS_MISSING_VALUES}")
    nuget_internal_git_get_semantic_version_with_prerelease_override(
        "${_arg_TAG_PREFIX}"
        "${_arg_PRERELEASE_LABEL}"
        MAJOR
        MINOR
        PATCH
        PRERELEASE
    )
    if(NOT "${_arg_FULL}" STREQUAL "")
        if(NOT "${PRERELEASE}" STREQUAL "")
            set(${_arg_FULL} "${MAJOR}.${MINOR}.${PATCH}-${PRERELEASE}" PARENT_SCOPE)
        else()
            set(${_arg_FULL} "${MAJOR}.${MINOR}.${PATCH}" PARENT_SCOPE)
        endif()
    endif()
    if(NOT "${_arg_CORE}" STREQUAL "")
        set(${_arg_CORE} "${MAJOR}.${MINOR}.${PATCH}" PARENT_SCOPE)
    endif()
    if(NOT "${_arg_MAJOR}" STREQUAL "")
        set(${_arg_MAJOR} "${MAJOR}" PARENT_SCOPE)
    endif()
    if(NOT "${_arg_MINOR}" STREQUAL "")
        set(${_arg_MINOR} "${MINOR}" PARENT_SCOPE)
    endif()
    if(NOT "${_arg_PATCH}" STREQUAL "")
        set(${_arg_PATCH} "${PATCH}" PARENT_SCOPE)
    endif()
    if(NOT "${_arg_PRERELEASE}" STREQUAL "")
        set(${_arg_PRERELEASE} "${PRERELEASE}" PARENT_SCOPE)
    endif()
endfunction()

## Public interface.
function(nuget_git_get_mapped_semantic_version)
    set(options "")
    set(oneValueArgs TAG_PREFIX
        BRANCH FULL CORE MAJOR MINOR PATCH PRERELEASE
    )
    set(multiValueArgs BRANCH_NAME_REGEXES PRERELEASE_PREFIX_LABELS PRERELEASE_POSTFIX_FLAGS)
    cmake_parse_arguments(_arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGV})
    nuget_internal_helper_error_if_unparsed_args("${_arg_UNPARSED_ARGUMENTS}" "${_arg_KEYWORDS_MISSING_VALUES}")
    nuget_internal_git_get_semantic_version_applying_rules(
        "${_arg_TAG_PREFIX}"
        "${_arg_BRANCH_NAME_REGEXES}"
        "${_arg_PRERELEASE_PREFIX_LABELS}"
        "${_arg_PRERELEASE_POSTFIX_FLAGS}"
        BRANCH
        MAJOR
        MINOR
        PATCH
        PRERELEASE
    )
    if(NOT "${_arg_BRANCH}" STREQUAL "")
        set(${_arg_BRANCH} "${BRANCH}" PARENT_SCOPE)
    endif()
    if(NOT "${_arg_FULL}" STREQUAL "")
        if(NOT "${PRERELEASE}" STREQUAL "")
            set(${_arg_FULL} "${MAJOR}.${MINOR}.${PATCH}-${PRERELEASE}" PARENT_SCOPE)
        else()
            set(${_arg_FULL} "${MAJOR}.${MINOR}.${PATCH}" PARENT_SCOPE)
        endif()
    endif()
    if(NOT "${_arg_CORE}" STREQUAL "")
        set(${_arg_CORE} "${MAJOR}.${MINOR}.${PATCH}" PARENT_SCOPE)
    endif()
    if(NOT "${_arg_MAJOR}" STREQUAL "")
        set(${_arg_MAJOR} "${MAJOR}" PARENT_SCOPE)
    endif()
    if(NOT "${_arg_MINOR}" STREQUAL "")
        set(${_arg_MINOR} "${MINOR}" PARENT_SCOPE)
    endif()
    if(NOT "${_arg_PATCH}" STREQUAL "")
        set(${_arg_PATCH} "${PATCH}" PARENT_SCOPE)
    endif()
    if(NOT "${_arg_PRERELEASE}" STREQUAL "")
        set(${_arg_PRERELEASE} "${PRERELEASE}" PARENT_SCOPE)
    endif()
endfunction()
