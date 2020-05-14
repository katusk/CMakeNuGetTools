## Include implementation
include("${CMAKE_CURRENT_LIST_DIR}/NuGetPack.nuspec.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/NuGetPack.nupkg.cmake")

## Internal cache variables
set(NUGET_NUSPEC_INDENT_SIZE "  " CACHE INTERNAL
    "Specifies the size of a single indentation level for generated .nuspec files."
)

## Public interface.
function(nuget_generate_nuspec_files)
    # Sanity checks
    if("${NUGET_COMMAND}" STREQUAL "")
        message(STATUS "NUGET_COMMAND is empty: CMakeNuGetTools is disabled, no .nuspec files are written.")
        return()
    endif()
    if("${ARGV}" STREQUAL "")
        message(FATAL_ERROR "No arguments provided.")
        return()
    endif()
    message(STATUS "Writing .nuspec file(s)...")
    # Begin .nuspec XML file
    set(NUSPEC_CONTENT "<?xml version=\"1.0\" encoding=\"utf-8\"?>")
    string(APPEND NUSPEC_CONTENT "\n<package xmlns=\"http://schemas.microsoft.com/packaging/2011/10/nuspec.xsd\">")
    # Process arguments
    set(ARGS_HEAD "")
    set(ARGS_TAIL ${ARGV})
    # Section: CMake-specific (without special section identifier CMake argument)
    nuget_internal_helper_cut_arg_list(METADATA "${ARGS_TAIL}" ARGS_HEAD ARGS_TAIL)
    set(NUSPEC_CMAKE_ARGS ${ARGS_HEAD})
    # Section: /package/metadata in .nuspec XML file (METADATA as section identifier CMake argument)
    nuget_internal_helper_cut_arg_list(FILES "${ARGS_TAIL}" ARGS_HEAD ARGS_TAIL)
    nuget_internal_nuspec_process_metadata_args("${NUGET_NUSPEC_INDENT_SIZE}" "${NUSPEC_CONTENT}" NUSPEC_CONTENT PACKAGE_ID ${ARGS_HEAD})
    # Section: /package/files in .nuspec XML file (FILES as section identifier CMake argument)
    nuget_internal_nuspec_process_files_args("${NUGET_NUSPEC_INDENT_SIZE}" "${NUSPEC_CONTENT}" NUSPEC_CONTENT ${ARGS_TAIL})
    # End .nuspec XML file
    string(APPEND NUSPEC_CONTENT "\n</package>")
    # Write output file(s)
    nuget_internal_nuspec_generate_output("${NUSPEC_CONTENT}" "${PACKAGE_ID}" ${NUSPEC_CMAKE_ARGS})
endfunction()

## Public interface.
function(nuget_merge_nuspec_files)
    # Inputs
    set(options "")
    set(oneValueArgs OUTPUT)
    set(multiValueArgs INPUTS)
    cmake_parse_arguments(_arg
        "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGV}
    )
    nuget_internal_helper_error_if_unparsed_args(
        "${_arg_UNPARSED_ARGUMENTS}"
        "${_arg_KEYWORDS_MISSING_VALUES}"
    )
    nuget_internal_helper_error_if_empty("${_arg_OUTPUT}" "You must provide a filepath as an OUTPUT argument.")
    nuget_internal_helper_error_if_empty("${_arg_INPUTS}" "You must provide at least one filepath to a .nuspec file as an INPUTS argument.")
    # Actual functionality
    nuget_internal_merge_n_nuspec_files("${_arg_OUTPUT}" ${_arg_INPUTS})
endfunction()

## Public interface.
function(nuget_pack)
    # Sanity checks
    if("${NUGET_COMMAND}" STREQUAL "")
        message(STATUS "NUGET_COMMAND is empty: CMakeNuGetTools is disabled, no packages are packed.")
        return()
    endif()
    # Inputs
    set(options "")
    set(oneValueArgs NUSPEC_FILEPATH OUTPUT_DIRECTORY VERSION_OVERRIDE)
    set(multiValueArgs "")
    cmake_parse_arguments(_arg
        "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGV}
    )
    nuget_internal_helper_error_if_unparsed_args(
        "${_arg_UNPARSED_ARGUMENTS}"
        "${_arg_KEYWORDS_MISSING_VALUES}"
    )
    nuget_internal_helper_error_if_empty("${_arg_NUSPEC_FILEPATH}" "You must provide a filepath to a .nuspec file as a NUSPEC_FILEPATH argument.")
    nuget_internal_helper_error_if_empty("${_arg_OUTPUT_DIRECTORY}" "You must provide an output directory where the .nupkg is created as an OUTPUT_DIRECTORY argument.")
    # Actual functionality
    nuget_internal_pack("${_arg_NUSPEC_FILEPATH}" "${_arg_OUTPUT_DIRECTORY}" "${_arg_VERSION_OVERRIDE}")
endfunction()

## Public interface.
function(nuget_pack_install)
    # Sanity checks
    if("${NUGET_COMMAND}" STREQUAL "")
        message(STATUS "NUGET_COMMAND is empty: CMakeNuGetTools is disabled, no packages are packed.")
        return()
    endif()
    # Inputs
    set(options "")
    set(oneValueArgs PACKAGE VERSION OUTPUT_DIRECTORY SOURCE)
    set(multiValueArgs "")
    cmake_parse_arguments(_arg
        "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGV}
    )
    nuget_internal_helper_error_if_unparsed_args(
        "${_arg_UNPARSED_ARGUMENTS}"
        "${_arg_KEYWORDS_MISSING_VALUES}"
    )
    nuget_internal_helper_error_if_empty("${_arg_PACKAGE}" "PACKAGE_ID must be non-empty.")
    nuget_internal_helper_error_if_empty("${_arg_VERSION}" "PACKAGE_VERSION must be non-empty.")
    nuget_internal_helper_error_if_empty("${_arg_OUTPUT_DIRECTORY}" "OUTPUT_DIRECTORY must be non-empty.")
    nuget_internal_helper_error_if_empty("${_arg_SOURCE}" "SOURCE must be non-empty.")
    # Actual functionality
    nuget_internal_pack_install("${_arg_PACKAGE}" "${_arg_VERSION}" "${_arg_OUTPUT_DIRECTORY}" "${_arg_SOURCE}")
endfunction()
