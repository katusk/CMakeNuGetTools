include("${CMAKE_CURRENT_LIST_DIR}/cmake/NuGetTools.cmake")

nuget_merge_nuspecs(OUTPUT "${MERGE_OUTPUT}" INPUTS ${MERGE_INPUTS})
