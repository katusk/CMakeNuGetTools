## Simply call this by executing the following on the command line:
## $ cmake -P build.cmake

# Set working directory
set(WORKDIR "${CMAKE_CURRENT_LIST_DIR}/build/meta/x64-windows")
execute_process(COMMAND "${CMAKE_COMMAND}" -E make_directory "${WORKDIR}")

# Run tests
execute_process(COMMAND "${CMAKE_COMMAND}" -G "Visual Studio 15 2017 Win64" "${CMAKE_CURRENT_LIST_DIR}"
    WORKING_DIRECTORY "${WORKDIR}"
)
execute_process(COMMAND "${CMAKE_COMMAND}" --build . --config Release
    WORKING_DIRECTORY "${WORKDIR}"
)
execute_process(COMMAND "${CMAKE_CTEST_COMMAND}" -C Release --verbose
    WORKING_DIRECTORY "${WORKDIR}"
)
