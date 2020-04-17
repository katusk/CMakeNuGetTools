## Internal.
function(_nuget_pack NUSPEC_FILEPATH OUTPUT_DIRECTORY)
    # Inputs
    _nuget_helper_error_if_empty("${NUGET_COMMAND}"
        "No NuGet executable was provided; this means NuGetTools should have been disabled, and "
        "we should not ever reach a call to _nuget_pack()."
    )
    # Execute pack
    execute_process(
        COMMAND "${NUGET_COMMAND}" pack "${NUSPEC_FILEPATH}"
            -OutputDirectory "${OUTPUT_DIRECTORY}"
            -NonInteractive
        ERROR_VARIABLE
            NUGET_PACK_ERROR_VAR
        RESULT_VARIABLE
            NUGET_PACK_RESULT_VAR
    )
    _nuget_helper_error_if_not_empty(
        "${NUGET_PACK_ERROR_VAR}"
        "Running NuGet pack based on \"${NUSPEC_FILEPATH}\" encountered some errors: "
    )
    if(NOT ${NUGET_PACK_RESULT_VAR} EQUAL 0)
        message(FATAL_ERROR "NuGet pack returned with: \"${NUGET_PACK_RESULT_VAR}\"")
    endif()
endfunction()
