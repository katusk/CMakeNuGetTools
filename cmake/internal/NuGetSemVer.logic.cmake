## Internal.
function(_nuget_git_parse_semantic_version
    TAG_WITHOUT_PREFIX
    MAJOR_OUT
    MINOR_OUT
    PATCH_OUT
    PRERELEASE_OUT
)
    set(REGEX_NUMBER "0|[1-9][0-9]*")
    set(REGEX_PRERELEASE "${REGEX_NUMBER}|[0-9]*[a-zA-Z-][0-9a-zA-Z]*")
    set(REGEX_SEMVER "^(${REGEX_NUMBER})\.(${REGEX_NUMBER})\.(${REGEX_NUMBER})(-${REGEX_PRERELEASE})?$")
    string(REGEX REPLACE "${REGEX_SEMVER}" "\\1" MAJOR "${TAG_WITHOUT_PREFIX}")
    _nuget_helper_error_if_empty("${MAJOR}" "Cannot parse major version part of tag outputted by Git describe: ")
    string(REGEX REPLACE "${REGEX_SEMVER}" "\\2" MINOR "${TAG_WITHOUT_PREFIX}")
    _nuget_helper_error_if_empty("${MINOR}" "Cannot parse minor version part of tag outputted by Git describe: ")
    string(REGEX REPLACE "${REGEX_SEMVER}" "\\3" PATCH "${TAG_WITHOUT_PREFIX}")
    _nuget_helper_error_if_empty("${PATCH}" "Cannot parse patch version part of tag outputted by Git describe: ")
    string(REGEX REPLACE "${REGEX_SEMVER}" "\\4" PRERELEASE "${TAG_WITHOUT_PREFIX}")
    string(LENGTH "${PRERELEASE}" PRERELEASE_LENGTH)
    if(PRERELEASE_LENGTH GREATER 0)
        string(SUBSTRING "${PRERELEASE}" 1 -1 PRERELEASE)
    endif()    
    _nuget_helper_error_if_empty("${PRERELEASE}" "Cannot parse prerelease part of tag outputted by Git describe: ")
endfunction()
