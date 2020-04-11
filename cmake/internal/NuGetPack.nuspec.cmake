## Internal. Section: /package/metadata in .nuspec XML file (METADATA as section identifier CMake argument).
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
    string(APPEND NUSPEC_CONTENT "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<id>${_arg_PACKAGE}</id>")
    string(APPEND NUSPEC_CONTENT "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<version>${_arg_VERSION}</version>")
    string(APPEND NUSPEC_CONTENT "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<description>${_arg_DESCRIPTION}</description>")
    string(REPLACE ";" "," AUTHORS "${_arg_AUTHORS}")
    string(APPEND NUSPEC_CONTENT "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<authors>${AUTHORS}</authors>")
    # Optional simple metadata subelements
    if(NOT "${_arg_PROJECT_URL}" STREQUAL "")
        string(APPEND NUSPEC_CONTENT "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<projectUrl>${_arg_PROJECT_URL}</projectUrl>")
    endif()
    if(NOT "${_arg_ICON}" STREQUAL "")
        string(APPEND NUSPEC_CONTENT "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<icon>${_arg_ICON}</icon>")
    endif()
    if(NOT "${_arg_COPYRIGHT}" STREQUAL "")
        string(APPEND NUSPEC_CONTENT "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<copyright>${_arg_COPYRIGHT}</copyright>")
    endif()
    # Optional complex metadata subelements
    # Begin /package/metadata/repository
    set(NUSPEC_REPOSITORY_CONTENT_BEGIN "\n${NUSPEC_SUBELEMENT_INDENT_SIZE}<repository")
    set(NUSPEC_REPOSITORY_CONTENT_END " />")
    set(NUSPEC_REPOSITORY_CONTENT "${NUSPEC_REPOSITORY_CONTENT_BEGIN}")
    # Attributes of /package/metadata/repository
    if(NOT "${_arg_REPOSITORY_TYPE}" STREQUAL "")
        string(APPEND NUSPEC_REPOSITORY_CONTENT " type=\"${_arg_REPOSITORY_TYPE}\"")
    endif()
    if(NOT "${_arg_REPOSITORY_URL}" STREQUAL "")
        string(APPEND NUSPEC_REPOSITORY_CONTENT " url=\"${_arg_REPOSITORY_URL}\"")
    endif()
    if(NOT "${_arg_REPOSITORY_BRANCH}" STREQUAL "")
        string(APPEND NUSPEC_REPOSITORY_CONTENT " branch=\"${_arg_REPOSITORY_BRANCH}\"")
    endif()
    if(NOT "${_arg_REPOSITORY_COMMIT}" STREQUAL "")
        string(APPEND NUSPEC_REPOSITORY_CONTENT " commit=\"${_arg_REPOSITORY_COMMIT}\"")
    endif()
    # End /package/metadata/repository
    string(APPEND NUSPEC_REPOSITORY_CONTENT "${NUSPEC_REPOSITORY_CONTENT_END}")
    if(NOT "${NUSPEC_REPOSITORY_CONTENT}" STREQUAL "${NUSPEC_REPOSITORY_CONTENT_BEGIN}${NUSPEC_REPOSITORY_CONTENT_END}")
        string(APPEND NUSPEC_CONTENT "${NUSPEC_REPOSITORY_CONTENT}")
    endif()
    # Optional collection metadata subelements
    # Section: /package/metadata/dependencies -- add package dependencies that are marked as PUBLIC or INTERFACE
    # in previous nuget_add_dependencies() calls.
    _nuget_nuspec_add_dependencies("${NUSPEC_SUBELEMENT_INDENT_SIZE}" "${NUSPEC_CONTENT}" NUSPEC_CONTENT)
    # End /package/metadata
    string(APPEND NUSPEC_CONTENT "\n${NUSPEC_INDENT_SIZE}</metadata>")
    set(${OUT_NUSPEC_CONTENT} "${NUSPEC_CONTENT}" PARENT_SCOPE)
    set(${OUT_PACKAGE_ID} "${_arg_PACKAGE}" PARENT_SCOPE)
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

# Internal. Section: /package/files in .nuspec XML file (FILES as section identifier CMake argument).
function(_nuget_nuspec_process_files_args NUSPEC_INDENT_SIZE NUSPEC_CONTENT OUT_NUSPEC_CONTENT)
    # Input
    list(GET ARGN 0 MAYBE_FILES_IDENTIFIER)
    set(EMPTY_FILES_NODE_ERROR_MESSAGE
        "FILES must not be empty: although the files node is not a required element (/package/files) of a .nuspec XML file, "
        "the implementation of the nuget_write_nuspec() CMake command requires you to generate a non-empty files node."
    )
    if(NOT "${MAYBE_FILES_IDENTIFIER}" STREQUAL "FILES")
        message(FATAL_ERROR ${EMPTY_FILES_NODE_ERROR_MESSAGE})
    endif()
    # Begin /package/files
    set(NUSPEC_FILES_CONTENT_BEGIN "\n${NUSPEC_INDENT_SIZE}<files>")
    set(NUSPEC_FILES_CONTENT_END "\n${NUSPEC_INDENT_SIZE}</files>")
    set(APPEND NUSPEC_FILES_CONTENT "${NUSPEC_FILES_CONTENT_BEGIN}")
    set(ARGS_HEAD "")
    _nuget_helper_list_sublist("${ARGN}" 1 -1 ARGS_TAIL)
    set(NUSPEC_SUBELEMENT_INDENT_SIZE "${NUSPEC_INDENT_SIZE}${NUGET_NUSPEC_INDENT_SIZE}")
    while(NOT "${ARGS_TAIL}" STREQUAL "")
        _nuget_helper_cut_arg_list(CMAKE_INCLUDE_CONDITION "${ARGS_TAIL}" ARGS_HEAD ARGS_TAIL)
        list(GET ARGS_HEAD 0 MAYBE_CMAKE_INCLUDE_CONDITION_IDENTIFIER)
        if("${MAYBE_CMAKE_INCLUDE_CONDITION_IDENTIFIER}" STREQUAL "CMAKE_INCLUDE_CONDITION")
            list(GET ARGS_HEAD 1 CMAKE_INCLUDE_CONDITION)
            _nuget_helper_list_sublist("${ARGS_HEAD}" 2 -1 ARGS_HEAD)
        endif()
        _nuget_nuspec_add_files_conditionally("${NUSPEC_SUBELEMENT_INDENT_SIZE}" "${NUSPEC_FILES_CONTENT}" NUSPEC_FILES_CONTENT
            "${CMAKE_INCLUDE_CONDITION}" ${ARGS_HEAD}
        )
    endwhile()
    # End /package/files
    string(APPEND NUSPEC_FILES_CONTENT "${NUSPEC_FILES_CONTENT_END}")
    if("${NUSPEC_FILES_CONTENT}" STREQUAL "${NUSPEC_FILES_CONTENT_BEGIN}${NUSPEC_FILES_CONTENT_END}")
        message(FATAL_ERROR ${EMPTY_FILES_NODE_ERROR_MESSAGE})
    endif()
    string(APPEND NUSPEC_CONTENT "${NUSPEC_FILES_CONTENT}")
    set(${OUT_NUSPEC_CONTENT} "${NUSPEC_CONTENT}" PARENT_SCOPE)
endfunction()

# Internal.
function(_nuget_nuspec_add_files_conditionally NUSPEC_INDENT_SIZE NUSPEC_CONTENT OUT_NUSPEC_CONTENT CMAKE_INCLUDE_CONDITION)
    string(APPEND NUSPEC_CONTENT "$<${CMAKE_INCLUDE_CONDITION}:")
    set(ARGS_HEAD "")
    set(ARGS_TAIL ${ARGN})
    while(NOT "${ARGS_TAIL}" STREQUAL "")
        _nuget_helper_cut_arg_list(FILE_SRC "${ARGS_TAIL}" ARGS_HEAD ARGS_TAIL)
        _nuget_nuspec_add_file_conditionally("${NUSPEC_INDENT_SIZE}" "${NUSPEC_CONTENT}" NUSPEC_CONTENT
            "${CMAKE_INCLUDE_CONDITION}" ${ARGS_HEAD}
        )
    endwhile()
    string(APPEND NUSPEC_CONTENT ">")
    set(${OUT_NUSPEC_CONTENT} "${NUSPEC_CONTENT}" PARENT_SCOPE)
endfunction()

# Internal.
function(_nuget_nuspec_add_file_conditionally NUSPEC_INDENT_SIZE NUSPEC_CONTENT OUT_NUSPEC_CONTENT CMAKE_INCLUDE_CONDITION)
    # Inputs
    # See https://docs.microsoft.com/en-us/nuget/reference/nuspec#file-element-attributes
    set(options "")
    set(oneValueArgs FILE_SRC FILE_TARGET)
    set(multiValueArgs FILE_EXCLUDE)
    cmake_parse_arguments(_arg
        "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN}
    )
    _nuget_helper_error_if_unparsed_args(
        "${_arg_UNPARSED_ARGUMENTS}"
        "${_arg_KEYWORDS_MISSING_VALUES}"
    )
    _nuget_helper_error_if_empty("${_arg_FILE_SRC}"
        "FILE_SRC must not be empty: it is a required element (src) of "
        "a .nuspec XML file's /package/files/file element."
    )
    # Actual functionality
    string(APPEND NUSPEC_CONTENT "\n${NUSPEC_INDENT_SIZE}<file")
    string(APPEND NUSPEC_CONTENT " src=\"${_arg_FILE_SRC}\"")
    if(NOT "${_arg_FILE_TARGET}" STREQUAL "")
        string(APPEND NUSPEC_CONTENT " target=\"${_arg_FILE_TARGET}\"")
    endif()
    if(NOT "${_arg_FILE_EXCLUDE}" STREQUAL "")
        string(APPEND NUSPEC_CONTENT " exclude=\"${_arg_FILE_EXCLUDE}\"")
    endif()
    string(APPEND NUSPEC_CONTENT " />")
    set(${OUT_NUSPEC_CONTENT} "${NUSPEC_CONTENT}" PARENT_SCOPE)
endfunction()

# Internal. Section: CMake-specific (without special section identifier CMake argument).
# Write output .nuspec XML file(s) conditionally for provided configurations in CMAKE_CONFIGURATIONS intersected with
# the available configurations in the current build system this function is actually called from. No error is raised if
# a given configuration is not available -- the output file is simply not generated for that in the current build system.
# Not raising an error if a given configuration is unavailable makes it possible to reuse the same nuget_write_nuspec()
# calls across different build systems without adjustments or writing additional code for generating the values of the
# CMAKE_CONFIGURATIONS argument.
function(_nuget_nuspec_generate_output NUSPEC_CONTENT PACKAGE_ID)
    # Inputs
    _nuget_helper_error_if_empty("${NUSPEC_CONTENT}" "NUSPEC_CONTENT to be written is empty: cannot generate .nuspec file's content.")
    _nuget_helper_error_if_empty("${PACKAGE_ID}" "PACKAGE_ID to be written is empty: cannot generate .nuspec filename.")
    set(options "")
    set(oneValueArgs CMAKE_OUTPUT_DIR CMAKE_CONFIGURATIONS)
    set(multiValueArgs "")
    cmake_parse_arguments(_arg
        "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN}
    )
    _nuget_helper_error_if_unparsed_args(
        "${_arg_UNPARSED_ARGUMENTS}"
        "${_arg_KEYWORDS_MISSING_VALUES}"
    )
    if("${_arg_CMAKE_OUTPUT_DIR}" STREQUAL "")
        set(OUTPUT_FILE "${CMAKE_BINARY_DIR}/CMakeNuGetTools/nuspec/${PACKAGE_ID}.nuspec")
    else()
        set(OUTPUT_FILE "${_arg_CMAKE_OUTPUT_DIR}/${PACKAGE_ID}.nuspec")
    endif()
    # Actual functionality
    if("${_arg_CMAKE_CONFIGURATIONS}" STREQUAL "")
        file(GENERATE OUTPUT "${OUTPUT_FILE}" CONTENT "${NUSPEC_CONTENT}")
    else()
        set(CONDITIONS "$<OR:")
        foreach(CONFIGURATION IN LISTS _arg_CMAKE_CONFIGURATIONS)
            string(APPEND CONDITIONS "${CONDITIONS_SEPARATOR}$<CONFIG:${CONFIGURATION}>")
            set(CONDITIONS_SEPARATOR ",")
        endforeach()
        string(APPEND CONDITIONS ">")
        file(GENERATE OUTPUT "${OUTPUT_FILE}" CONTENT "${NUSPEC_CONTENT}" CONDITION "${CONDITIONS}")
    endif()
endfunction()
