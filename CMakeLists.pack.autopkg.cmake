include("${CMAKE_CURRENT_LIST_DIR}/cmake/NuGetTools.cmake")

nuget_merge_autopkg_files(OUTPUT "${MERGE_OUTPUT}" INPUTS ${MERGE_INPUTS})
nuget_pack_autopkg(AUTOPKG_FILEPATH "${MERGE_OUTPUT}")
