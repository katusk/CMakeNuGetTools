## Simply run:
## $ cmake -P tests/NuGetSemVer.test.cmake
cmake_minimum_required(VERSION 3.8.2 FATAL_ERROR)
set(PROJECT_ROOT "${CMAKE_CURRENT_LIST_DIR}/..")
include("${PROJECT_ROOT}/cmake/NuGetTools.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/TestHelpers.cmake")

# Run stuff
nuget_git_get_current_branch_name(BRANCH)
message("-- BRANCH: ${BRANCH}")

nuget_git_get_current_commit_sha1(COMMIT)
message("-- COMMIT: ${COMMIT}")

nuget_git_get_remote_url(REMOTE_URL)
message("-- REMOTE_URL: ${REMOTE_URL}")

nuget_git_get_semantic_version(
    TAG_PREFIX "v" 
    PRERELEASE_LABEL "snapshot"
    FULL FULL_VERSION
    CORE CORE_VERSION
    MAJOR MAJOR_VERSION
    MINOR MINOR_VERSION
    PATCH PATCH_VERSION
    PRERELEASE PRERELEASE_VERSION
)
message("-- nuget_git_get_semantic_version:
FULL: ${FULL_VERSION}
CORE: ${CORE_VERSION}
MAJOR: ${MAJOR_VERSION}
MINOR: ${MINOR_VERSION}
PATCH: ${PATCH_VERSION}
PRERELEASE: ${PRERELEASE_VERSION}")

nuget_git_get_mapped_semantic_version(
    TAG_PREFIX "v" 
    BRANCH_NAME_REGEXES "^feature.*$" "^release.*" "^master$" ".*"
    PRERELEASE_PREFIX_LABELS "alpha" "rc" " " "pre"
    PRERELEASE_POSTFIX_FLAGS 1 1 0 1
    BRANCH CURRENT_BRANCH
    FULL FULL_VERSION
    CORE CORE_VERSION
    MAJOR MAJOR_VERSION
    MINOR MINOR_VERSION
    PATCH PATCH_VERSION
    PRERELEASE PRERELEASE_VERSION
)
message("-- nuget_git_get_mapped_semantic_version:
BRANCH: ${CURRENT_BRANCH}
FULL: ${FULL_VERSION}
CORE: ${CORE_VERSION}
MAJOR: ${MAJOR_VERSION}
MINOR: ${MINOR_VERSION}
PATCH: ${PATCH_VERSION}
PRERELEASE: ${PRERELEASE_VERSION}")
message("---------------------------")
