## Internal.
function(_nuget_git_describe_parse
    GIT_TAG_PREFIX
    TAG_WITHOUT_PREFIX_OUT
    COMMITS_SINCE_MOST_RECENT_TAG_OUT
    MOST_RECENT_COMMIT_ABBREV_OUT
)
    # Prerequisites check
    find_package(Git)
    if(NOT Git_FOUND)
        message(FATAL_ERROR "Git was not found: cannot describe tags.")
    endif()
    # Describe most recent tag; e.g. "v0.1-36-g9cba053". Error if not found.
    execute_process(
        COMMAND ${GIT_EXECUTABLE} describe --tags --long --match "${GIT_TAG_PREFIX}*"
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        OUTPUT_STRIP_TRAILING_WHITESPACE
        OUTPUT_VARIABLE GIT_DESCRIBE_OUTPUT
        ERROR_VARIABLE GIT_DESCRIBE_ERROR_VAR
        RESULT_VARIABLE GIT_DESCRIBE_RESULT_VAR
    )
    _nuget_helper_error_if_not_empty("${GIT_DESCRIBE_ERROR_VAR}" "Running Git describe encountered some errors: ")
    if(NOT ${GIT_DESCRIBE_RESULT_VAR} EQUAL 0)
        message(FATAL_ERROR "Git describe returned with: \"${GIT_DESCRIBE_RESULT_VAR}\"")
    endif()
    # Parse output of Git describe
    set(REGEX_NUMBER "0|[1-9][0-9]*")
    set(REGEX_SHA "[0-9a-f]+")
    set(REGEX_GIT_DESCRIBE "^${GIT_TAG_PREFIX}(.*)-(${REGEX_NUMBER})-(${REGEX_SHA})$")
    string(REGEX REPLACE "${REGEX_GIT_DESCRIBE}" "\\1" TAG_WITHOUT_PREFIX "${GIT_DESCRIBE_OUTPUT}")
    _nuget_helper_error_if_empty("${TAG_WITHOUT_PREFIX}" "Cannot parse tag part of Git describe's output: ")
    string(REGEX REPLACE "${REGEX_GIT_DESCRIBE}" "\\2" COMMITS_SINCE_MOST_RECENT_TAG "${GIT_DESCRIBE_OUTPUT}")
    _nuget_helper_error_if_empty("${COMMITS_SINCE_MOST_RECENT_TAG}"
        "Cannot parse number of commits since most recent tag part of Git describe's output: "
    )
    string(REGEX REPLACE "${REGEX_GIT_DESCRIBE}" "\\3" MOST_RECENT_COMMIT_ABBREV "${GIT_DESCRIBE_OUTPUT}")
    _nuget_helper_error_if_empty("${MOST_RECENT_COMMIT_ABBREV}"
        "Cannot parse most recent abbreviated commit part of Git describe's output: "
    )
    set(${TAG_WITHOUT_PREFIX_OUT} "${TAG_WITHOUT_PREFIX}" PARENT_SCOPE)
    set(${COMMITS_SINCE_MOST_RECENT_TAG_OUT} "${COMMITS_SINCE_MOST_RECENT_TAG}" PARENT_SCOPE)
    set(${MOST_RECENT_COMMIT_ABBREV_OUT} "${MOST_RECENT_COMMIT_ABBREV}" PARENT_SCOPE)
endfunction()

# TODO:
# set(REGEX_PRERELEASE "${REGEX_NUMBER}|[0-9]*[a-zA-Z-][0-9a-zA-Z]*")
# Check prerelease logic...
# major, minor, patch, prerelease
# ^(${REGEX_NUMBER})\.(${REGEX_NUMBER})\.(${REGEX_NUMBER})(-)?$

# TODO: separate function(s) for:
# REPOSITORY_URL https://github.com/katusk/whatnot.git
# REPOSITORY_BRANCH dev
# REPOSITORY_COMMIT e1c65e4524cd70ee6e22abe33e6cb6ec73938cb3
