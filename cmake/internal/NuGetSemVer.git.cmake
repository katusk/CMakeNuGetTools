## Internal.
function(_nuget_git_parse_git_describe
    GIT_TAG_PREFIX
    TAG_WITHOUT_PREFIX_OUT
    COMMITS_SINCE_MOST_RECENT_TAG_OUT
    MOST_RECENT_COMMIT_ABBREV_OUT
)
    # Prerequisites check; find_package results should be cached, next line is fine here.
    find_package(Git)
    if(NOT Git_FOUND)
        message(FATAL_ERROR "Git was not found: cannot describe most recent tag.")
    endif()
    # Describe most recent tag; e.g. "v0.1-36-g9cba053". Error if not found.
    # NOTE: consider using "--first-parent"; see:
    # https://git-scm.com/docs/git-describe#Documentation/git-describe.txt---first-parent
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
    # Due to "--long" in the above below is also emitted even if most recent commit has the tag
    # (COMMITS_SINCE_MOST_RECENT_TAG is going to be 0 if that is the case).
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

## Internal.
function(_nuget_git_get_current_branch_name BRANCH_NAME_OUT)
    find_package(Git)
    if(NOT Git_FOUND)
        message(FATAL_ERROR "Git was not found: cannot get name of current branch.")
    endif()
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        OUTPUT_STRIP_TRAILING_WHITESPACE
        OUTPUT_VARIABLE GIT_BRANCH_OUTPUT
        ERROR_VARIABLE GIT_BRANCH_ERROR_VAR
        RESULT_VARIABLE GIT_BRANCH_RESULT_VAR
    )
    _nuget_helper_error_if_not_empty("${GIT_BRANCH_ERROR_VAR}" "Running Git rev-parse --abbrev-ref HEAD encountered some errors: ")
    if(NOT ${GIT_BRANCH_RESULT_VAR} EQUAL 0)
        message(FATAL_ERROR "Git rev-parse --abbrev-ref HEAD returned with: \"${GIT_BRANCH_RESULT_VAR}\"")
    endif()
    set(${BRANCH_NAME_OUT} "${GIT_BRANCH_RESULT_VAR}" PARENT_SCOPE)
endfunction()

## Internal.
function(_nuget_git_get_current_commit_sha1 HEAD_COMMIT_SHA1_OUT)
    find_package(Git)
    if(NOT Git_FOUND)
        message(FATAL_ERROR "Git was not found: cannot get SHA-1 of HEAD.")
    endif()
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-parse --verify HEAD
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        OUTPUT_STRIP_TRAILING_WHITESPACE
        OUTPUT_VARIABLE GIT_HEAD_COMMIT_OUTPUT
        ERROR_VARIABLE GIT_HEAD_COMMIT_ERROR_VAR
        RESULT_VARIABLE GIT_HEAD_COMMIT_RESULT_VAR
    )
    _nuget_helper_error_if_not_empty("${GIT_HEAD_COMMIT_ERROR_VAR}" "Running Git rev-parse --verify HEAD encountered some errors: ")
    if(NOT ${GIT_HEAD_COMMIT_RESULT_VAR} EQUAL 0)
        message(FATAL_ERROR "Git rev-parse --verify HEAD returned with: \"${GIT_HEAD_COMMIT_RESULT_VAR}\"")
    endif()
    set(${HEAD_COMMIT_SHA1_OUT} "${GIT_HEAD_COMMIT_RESULT_VAR}" PARENT_SCOPE)
endfunction()

## Internal.
function(_nuget_git_get_remote_url REMOTE_URL_OUT)
    find_package(Git)
    if(NOT Git_FOUND)
        message(FATAL_ERROR "Git was not found: cannot get URL of remote.")
    endif()
    execute_process(
        COMMAND ${GIT_EXECUTABLE} ls-remote --get-url
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        OUTPUT_STRIP_TRAILING_WHITESPACE
        OUTPUT_VARIABLE GIT_REMOTE_URL_OUTPUT
        ERROR_VARIABLE GIT_REMOTE_URL_ERROR_VAR
        RESULT_VARIABLE GIT_REMOTE_URL_RESULT_VAR
    )
    _nuget_helper_error_if_not_empty("${GIT_REMOTE_URL_ERROR_VAR}" "Running Git ls-remote --get-url encountered some errors: ")
    if(NOT ${GIT_REMOTE_URL_RESULT_VAR} EQUAL 0)
        message(FATAL_ERROR "Git ls-remote --get-url returned with: \"${GIT_REMOTE_URL_RESULT_VAR}\"")
    endif()
    set(${REMOTE_URL_OUT} "${GIT_REMOTE_URL_RESULT_VAR}" PARENT_SCOPE)
endfunction()

# 1. get semver as is with commits ahead added (if not at tag then postfix with "snapshot" -- param...)...
# 2. get repository metadata
# 3. get prev two with prerelease naming method
#    - list of branch name regexes (empty means default) & list of prerelease prefixes (empty if no prerel at all for that branch) & list of flags: postfix with git commit?

# TODO:
# Check prerelease logic...
# <!--Default version-->
# <SemVer>$(GitSemVerMajor).$(GitSemVerMinor).$(GitSemVerPatch)</SemVer>
# <!--Any other branch-->
# <GitSemVerDashLabel>pre$(GitCommit)</GitSemVerDashLabel>
# <!-- Packages for feature branches are marked as "alpha" (ex., 2.1.0-alpha426e8bcf) -->
# <GitSemVerDashLabel Condition="$(GitBranch.Contains('feature'))">alpha$(GitCommit)</GitSemVerDashLabel>
# <!-- Packages for release branches are marked as "rc", release candidates (ex., 2.1.0-rc426e8bcf) -->
# <GitSemVerDashLabel Condition="$(GitBranch.Contains('release'))">rc$(GitCommit)</GitSemVerDashLabel>
# <!-- Packages for the master branch have no suffix (ex., 2.1.0) -->
# <GitSemVerDashLabel Condition="$(GitBranch.Contains('master'))"></GitSemVerDashLabel>
# <PackageVersion Condition="'$(GitSemVerDashLabel)' != ''">$(SemVer)-$(GitSemVerDashLabel)</PackageVersion>
# <PackageVersion Condition="'$(GitSemVerDashLabel)' == ''">$(SemVer)</PackageVersion>
# major, minor, patch, prerelease
# ^(${REGEX_NUMBER})\.(${REGEX_NUMBER})\.(${REGEX_NUMBER})(-)?$

# TODO: separate function for (nuget_git_get_repository_metadata):
# also return _type as git
# REPOSITORY_URL https://github.com/katusk/whatnot.git
# REPOSITORY_BRANCH dev
# REPOSITORY_COMMIT e1c65e4524cd70ee6e22abe33e6cb6ec73938cb3
