include("${CMAKE_CURRENT_LIST_DIR}/cmake/NuGetTools.cmake")

nuget_merge_nuspec_files(OUTPUT "${MERGE_OUTPUT}" INPUTS ${MERGE_INPUTS})
