## Include implementation
include("${CMAKE_CURRENT_LIST_DIR}/NuGetPack.nuspec.cmake")

## Internal cache variables
set(NUGET_NUSPEC_INDENT_SIZE "  " CACHE INTERNAL
    "Specifies the size of a single indentation level for generated .nuspec files."
)

## Public interface.
function(nuget_write_nuspec)
    # Sanity checks
    if("${NUGET_COMMAND}" STREQUAL "")
        message("NUGET_COMMAND is empty: CMakeNuGetTools is disabled, no .nuspec files are written.")
        return()
    endif()
    if("${ARGV}" STREQUAL "")
        message(FATAL_ERROR "No arguments provided.")
        return()
    endif()
    message("Writing .nuspec file...")

    # Begin .nuspec XML file
    set(NUSPEC_CONTENT "<?xml version=\"1.0\" encoding=\"utf-8\"?>")
    string(APPEND NUSPEC_CONTENT "\n<package xmlns=\"http://schemas.microsoft.com/packaging/2011/10/nuspec.xsd\">")

    # Process arguments
    set(ARGS_HEAD "")
    set(ARGS_TAIL ${ARGV})
    # Section: CMake-specific (without special section identifier)
    _nuget_helper_cut_arg_list(METADATA "${ARGS_TAIL}" ARGS_HEAD ARGS_TAIL)
    set(NUSPEC_CMAKE_ARGS ${ARGS_HEAD})
    # Section: /package/metadata in .nuspec XML file (METADATA as section identifier CMake argument)
    _nuget_helper_cut_arg_list(FILES "${ARGS_TAIL}" ARGS_HEAD ARGS_TAIL)
    _nuget_nuspec_process_metadata_args("${NUGET_NUSPEC_INDENT_SIZE}" "${NUSPEC_CONTENT}" NUSPEC_CONTENT PACKAGE_ID ${ARGS_HEAD})
    # Section: /package/files in .nuspec XML file (FILES as section identifier CMake argument)
    _nuget_nuspec_process_files_args("${NUGET_NUSPEC_INDENT_SIZE}" "${NUSPEC_CONTENT}" NUSPEC_CONTENT ${ARGS_TAIL})

    # End .nuspec XML file
    string(APPEND NUSPEC_CONTENT "\n</package>")

    # Write output file(s)
    _nuget_nuspec_generate_output("${NUSPEC_CONTENT}" "${PACKAGE_ID}" ${NUSPEC_CMAKE_ARGS})
endfunction()
