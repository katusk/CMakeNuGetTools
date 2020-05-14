## Internal.
function(nuget_internal_git_parse_semantic_version
    TAG_WITHOUT_PREFIX
    MAJOR_OUT
    MINOR_OUT
    PATCH_OUT
    PRERELEASE_OUT
)
    set(REGEX_NUMBER "0|[1-9][0-9]*")
    set(REGEX_PRERELEASE "${REGEX_NUMBER}|[0-9]*[a-zA-Z-][0-9a-zA-Z]*")
    set(REGEX_SEMVER_CORE "(${REGEX_NUMBER})\\.(${REGEX_NUMBER})\\.(${REGEX_NUMBER})")
    set(REGEX_SEMVER_PRERELEASE "^${REGEX_SEMVER_CORE}-(${REGEX_PRERELEASE})$")
    set(REGEX_SEMVER "^${REGEX_SEMVER_CORE}(-${REGEX_PRERELEASE})?$")
    if(NOT "${TAG_WITHOUT_PREFIX}" MATCHES "${REGEX_SEMVER}")
        message(FATAL_ERROR "Cannot match \"${TAG_WITHOUT_PREFIX}\" with \"${REGEX_SEMVER}\".")
    endif()
    string(REGEX REPLACE "${REGEX_SEMVER}" "\\1" MAJOR "${TAG_WITHOUT_PREFIX}")
    string(REGEX REPLACE "${REGEX_SEMVER}" "\\2" MINOR "${TAG_WITHOUT_PREFIX}")
    string(REGEX REPLACE "${REGEX_SEMVER}" "\\3" PATCH "${TAG_WITHOUT_PREFIX}")
    if("${TAG_WITHOUT_PREFIX}" MATCHES "${REGEX_SEMVER_PRERELEASE}")
        string(REGEX REPLACE "${REGEX_SEMVER}" "\\4" PRERELEASE "${TAG_WITHOUT_PREFIX}")
    endif()
    set(${MAJOR_OUT} "${MAJOR}" PARENT_SCOPE)
    set(${MINOR_OUT} "${MINOR}" PARENT_SCOPE)
    set(${PATCH_OUT} "${PATCH}" PARENT_SCOPE)
    set(${PRERELEASE_OUT} "${PRERELEASE}" PARENT_SCOPE)
endfunction()

## Internal. BRANCH_NAME_REGEXES, PRERELEASE_PREFIX_LABELS, and PRERELEASE_POSTFIX_FLAGS should contain the same number
## of elements. For each branch_regex in BRANCH_NAME_REGEXES in order: if branch_regex matches the current branch name, 
## then the corresponding prefix_label from PRERELEASE_PREFIX_LABELS is used as a prerelease prefix (if prefix_label
## is empty, then the prerelease part is omitted completely except when the most recent tag from git has a prerelease
## part which then be used). If prefix_label is not empty, and the corresponding element of PRERELEASE_POSTFIX_FLAGS is
## TRUE, then the prerelease label is postfixed with the abbreviated hash of the current commit.
function(nuget_internal_git_get_semantic_version_applying_rules
    GIT_TAG_PREFIX
    BRANCH_NAME_REGEXES
    PRERELEASE_PREFIX_LABELS
    PRERELEASE_POSTFIX_FLAGS
    BRANCH_OUT
    MAJOR_OUT
    MINOR_OUT
    PATCH_OUT
    PRERELEASE_OUT
)
    # Inputs
    list(LENGTH BRANCH_NAME_REGEXES BRANCH_NAME_REGEXES_LENGTH)
    list(LENGTH PRERELEASE_PREFIX_LABELS PRERELEASE_PREFIX_LABELS_LENGTH)
    list(LENGTH PRERELEASE_POSTFIX_FLAGS PRERELEASE_POSTFIX_FLAGS_LENGTH)
    if(NOT BRANCH_NAME_REGEXES_LENGTH EQUAL PRERELEASE_PREFIX_LABELS_LENGTH)
        message(FATAL_ERROR "Number of provided branch name regexes and prerelease prefix labels differ.")
    endif()
    if(NOT BRANCH_NAME_REGEXES_LENGTH EQUAL PRERELEASE_POSTFIX_FLAGS_LENGTH)
        message(FATAL_ERROR "Number of provided branch name regexes and prerelease postfix flags differ.")
    endif()
    # Query version tag
    nuget_internal_git_parse_git_describe("${GIT_TAG_PREFIX}" TAG_WITHOUT_PREFIX COMMITS_SINCE_MOST_RECENT_TAG MOST_RECENT_COMMIT_ABBREV)
    nuget_internal_git_parse_semantic_version("${TAG_WITHOUT_PREFIX}" MAJOR MINOR PATCH PRERELEASE)
    math(EXPR PATCH "${PATCH} + ${COMMITS_SINCE_MOST_RECENT_TAG}")
    nuget_git_get_current_branch_name(BRANCH_NAME)
    # Apply mapping rules
    set(ITER 0)
    foreach(BRANCH_NAME_REGEX IN LISTS BRANCH_NAME_REGEXES)
        string(REGEX MATCH "${BRANCH_NAME_REGEX}" BRANCH_MATCH "${BRANCH_NAME}")
        if(NOT "${BRANCH_MATCH}" STREQUAL "")
            list(GET PRERELEASE_PREFIX_LABELS ${ITER} PRERELEASE_PREFIX_LABEL)
            string(REGEX MATCH "[^ \t\r\n]+" MATCH_PRERELEASE_PREFIX_LABEL "${PRERELEASE_PREFIX_LABEL}")
            if(NOT "${MATCH_PRERELEASE_PREFIX_LABEL}" STREQUAL "")
                set(PRERELEASE "${PRERELEASE_PREFIX_LABEL}")
            endif()
            if(NOT "${PRERELEASE}" STREQUAL "")
                list(GET PRERELEASE_POSTFIX_FLAGS ${ITER} PRERELEASE_POSTFIX_FLAG)
                # MOST_RECENT_COMMIT_ABBREV is used as postfix without adding the "+" glue character: "If you upload a SemVer
                # v2.0.0-specific package to nuget.org, the package is invisible to older clients and available to only the
                # following NuGet clients" -- and we want to maintain backwards compatibility. Quote from:
                # https://docs.microsoft.com/en-us/nuget/concepts/package-versioning#semantic-versioning-200
                # Also see: https://semver.org/#spec-item-10
                if(PRERELEASE_POSTFIX_FLAG)
                    set(PRERELEASE "${PRERELEASE}${MOST_RECENT_COMMIT_ABBREV}")
                endif()
            endif()
            break()
        endif()
        math(EXPR ITER "${ITER} + 1")
    endforeach()
    set(${BRANCH_OUT} "${BRANCH_NAME}" PARENT_SCOPE)
    set(${MAJOR_OUT} "${MAJOR}" PARENT_SCOPE)
    set(${MINOR_OUT} "${MINOR}" PARENT_SCOPE)
    set(${PATCH_OUT} "${PATCH}" PARENT_SCOPE)
    set(${PRERELEASE_OUT} "${PRERELEASE}" PARENT_SCOPE)
endfunction()

# Internal.
function(nuget_internal_git_get_semantic_version_with_prerelease_override
    GIT_TAG_PREFIX
    PRERELEASE_LABEL
    MAJOR_OUT
    MINOR_OUT
    PATCH_OUT
    PRERELEASE_OUT
)
    # Query version tag
    nuget_internal_git_parse_git_describe("${GIT_TAG_PREFIX}" TAG_WITHOUT_PREFIX COMMITS_SINCE_MOST_RECENT_TAG MOST_RECENT_COMMIT_ABBREV)
    nuget_internal_git_parse_semantic_version("${TAG_WITHOUT_PREFIX}" MAJOR MINOR PATCH PRERELEASE)
    math(EXPR PATCH "${PATCH} + ${COMMITS_SINCE_MOST_RECENT_TAG}")
    # Overwrite prerelease part
    if(NOT "${PRERELEASE_LABEL}" STREQUAL "")
        set(PRERELEASE "${PRERELEASE_LABEL}")
    endif()
    set(${MAJOR_OUT} "${MAJOR}" PARENT_SCOPE)
    set(${MINOR_OUT} "${MINOR}" PARENT_SCOPE)
    set(${PATCH_OUT} "${PATCH}" PARENT_SCOPE)
    set(${PRERELEASE_OUT} "${PRERELEASE}" PARENT_SCOPE)
endfunction()
