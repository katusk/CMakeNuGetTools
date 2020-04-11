## Internal. Section: /package/metadata in .nuspec XML file (METADATA as section identifier CMake argument)
function(_nuget_nuspec_process_metadata_args NUSPEC_INDENT_SIZE NUSPEC_CONTENT OUT_NUSPEC_CONTENT OUT_PACKAGE_ID)
    # Inputs
    set(options METADATA)
    set(oneValueArgs PACKAGE VERSION DESCRIPTION PROJECT_URL ICON COPYRIGHT
        REPOSITORY_TYPE REPOSITORY_URL REPOSITORY_BRANCH REPOSITORY_COMMIT
    )
    set(multiValueArgs AUTHORS)
    cmake_parse_arguments(_arg
        "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN}
    )
    _nuget_helper_error_if_unparsed_args(
        "${_arg_UNPARSED_ARGUMENTS}"
        "${_arg_KEYWORDS_MISSING_VALUES}"
    )
    # See https://docs.microsoft.com/en-us/nuget/reference/nuspec#general-form-and-schema for below requirements
    if(NOT _arg_METADATA)
        message(FATAL_ERROR "METADATA identifier is not found: it is a required element (/package/metadata) of a .nuspec XML file.")
    endif()
    _nuget_helper_error_if_empty("${_arg_PACKAGE}" "PACKAGE must not be empty: it is a required element (/package/metadata/id) of a .nuspec XML file.")
    _nuget_helper_error_if_empty("${_arg_VERSION}" "VERSION must not be empty: it is a required element (/package/metadata/version) of a .nuspec XML file.")
    _nuget_helper_error_if_empty("${_arg_DESCRIPTION}" "DESCRIPTION must not be empty: it is a required element (/package/metadata/description) of a .nuspec XML file.")
    _nuget_helper_error_if_empty("${_arg_AUTHORS}" "AUTHORS must not be empty: it is a required element (/package/metadata/authors) of a .nuspec XML file.")
    # Actual functionality
    # Begin /package/metadata
    string(APPEND NUSPEC_CONTENT "\n${NUSPEC_INDENT_SIZE}<metadata>")
    set(NUSPEC_SUBELEMENT_INDENT_SIZE "${NUSPEC_INDENT_SIZE}${NUGET_NUSPEC_INDENT_SIZE}")
    # Required metadata subelements
    string(APPEND NUSPEC_CONTENT "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<id>${PACKAGE}</id>")
    string(APPEND NUSPEC_CONTENT "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<version>${VERSION}</version>")
    string(APPEND NUSPEC_CONTENT "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<description>${DESCRIPTION}</description>")
    string(REPLACE ";" "," AUTHORS "${AUTHORS}")
    string(APPEND NUSPEC_CONTENT "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<authors>${AUTHORS}</authors>")
    # Optional simple metadata subelements
    if(NOT "${PROJECT_URL}" STREQUAL "")
        string(APPEND NUSPEC_CONTENT "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<projectUrl>${PROJECT_URL}</projectUrl>")
    endif()
    if(NOT "${ICON}" STREQUAL "")
        string(APPEND NUSPEC_CONTENT "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<icon>${ICON}</icon>")
    endif()
    if(NOT "${COPYRIGHT}" STREQUAL "")
        string(APPEND NUSPEC_CONTENT "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<copyright>${COPYRIGHT}</copyright>")
    endif()
    # Optional complex metadata subelements
    # Begin /package/metadata/repository
    set(NUSPEC_REPOSITORY_CONTENT_BEGIN "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<repository")
    set(NUSPEC_REPOSITORY_CONTENT_END " />")
    set(NUSPEC_REPOSITORY_CONTENT "${NUSPEC_REPOSITORY_CONTENT_BEGIN}")
    # Attributes of /package/metadata/repository
    if(NOT "${REPOSITORY_TYPE}" STREQUAL "")
        string(APPEND NUSPEC_REPOSITORY_CONTENT " type=\"${REPOSITORY_TYPE}\"")
    endif()
    if(NOT "${REPOSITORY_URL}" STREQUAL "")
        string(APPEND NUSPEC_REPOSITORY_CONTENT " url=\"${REPOSITORY_URL}\"")
    endif()
    if(NOT "${REPOSITORY_BRANCH}" STREQUAL "")
        string(APPEND NUSPEC_REPOSITORY_CONTENT " branch=\"${REPOSITORY_BRANCH}\"")
    endif()
    if(NOT "${REPOSITORY_COMMIT}" STREQUAL "")
        string(APPEND NUSPEC_REPOSITORY_CONTENT " commit=\"${REPOSITORY_COMMIT}\"")
    endif()
    # End /package/metadata/repository
    string(APPEND NUSPEC_REPOSITORY_CONTENT "${NUSPEC_REPOSITORY_CONTENT_END}")
    if(NOT "${NUSPEC_REPOSITORY_CONTENT}" STREQUAL "${NUSPEC_REPOSITORY_CONTENT_BEGIN}${NUSPEC_REPOSITORY_CONTENT_END}")
        string(APPEND NUSPEC_CONTENT "${NUSPEC_REPOSITORY_CONTENT}")
    endif()
    # Add package dependencies that are marked as PUBLIC or INTERFACE in previous nuget_add_dependencies() calls
    _nuget_nuspec_add_dependencies("${NUSPEC_SUBELEMENT_INDENT_SIZE}" "${NUSPEC_CONTENT}" NUSPEC_CONTENT)
    # End /package/metadata
    string(APPEND NUSPEC_CONTENT "\n${NUSPEC_INDENT_SIZE}</metadata>")
    set(${OUT_NUSPEC_CONTENT} "${NUSPEC_CONTENT}" PARENT_SCOPE)
endfunction()

## Internal. Section: /package/metadata/dependencies in .nuspec XML file.
## Automatically generated based on previous nuget_add_dependencies() calls.
## Only dependencies marked as PUBLIC or INTERFACE are added (ie. PRIVATE dependencies are omitted).
function(_nuget_nuspec_add_dependencies NUSPEC_INDENT_SIZE NUSPEC_CONTENT OUT_NUSPEC_CONTENT)
    # Begin /package/metadata/dependencies
    set(NUSPEC_DEPENDENCIES_CONTENT_BEGIN "\n${NUSPEC_INDENT_SIZE}<dependencies>")
    set(NUSPEC_DEPENDENCIES_CONTENT_END "\n${NUSPEC_INDENT_SIZE}</dependencies>")
    set(NUSPEC_DEPENDENCIES_CONTENT "${NUSPEC_DEPENDENCIES_CONTENT_BEGIN}")
    # For each dependency that should be in /package/metadata/dependencies
    nuget_get_dependencies(DEPENDENCIES)
    set(NUSPEC_SUBELEMENT_INDENT_SIZE "${NUSPEC_INDENT_SIZE}${NUGET_NUSPEC_INDENT_SIZE}")
    foreach(DEPENDENCY IN LISTS DEPENDENCIES)
        nuget_get_dependency_usage("${DEPENDENCY}" USAGE)
        if("${USAGE}" STREQUAL "PRIVATE")
            continue()
        endif()
        nuget_get_dependency_version("${DEPENDENCY}" VERSION)
        string(APPEND NUSPEC_DEPENDENCIES_CONTENT "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<dependency id=\"${DEPENDENCY}\" version=\"${VERSION}\" />")
    endforeach()
    # End /package/metadata/dependencies
    string(APPEND NUSPEC_DEPENDENCIES_CONTENT "${NUSPEC_DEPENDENCIES_CONTENT_END}")
    if(NOT "${NUSPEC_DEPENDENCIES_CONTENT}" STREQUAL "${NUSPEC_DEPENDENCIES_CONTENT_BEGIN}${NUSPEC_DEPENDENCIES_CONTENT_END}")
        string(APPEND NUSPEC_CONTENT "${NUSPEC_DEPENDENCIES_CONTENT}")
    endif()
    set(${OUT_NUSPEC_CONTENT} "${NUSPEC_CONTENT}" PARENT_SCOPE)
endfunction()

# Section: <files> (FILES)
# _nuget_nuspec_process_files_args("${NUGET_NUSPEC_INDENT_SIZE}" "${NUSPEC_CONTENT}" NUSPEC_CONTENT ${ARGS_TAIL})
function(_nuget_nuspec_process_files_args)
    # TODO
endfunction()

# Write output file
# Section: CMake-specific (without special identifier)
# _nuget_nuspec_generate_output("${NUSPEC_CONTENT}" "${PACKAGE_ID}" ${NUSPEC_CMAKE_ARGS})
function(_nuget_nuspec_generate_output)
    # TODO
endfunction()
