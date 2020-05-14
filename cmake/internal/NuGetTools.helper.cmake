## Internal. Similar to "list(SUBLIST <list> <begin> <length> <out-var>)".
function(nuget_internal_helper_list_sublist LIST BEGIN LEN OUT_SUBLIST)
    list(LENGTH LIST LIST_LENGTH)
    if(${LEN} EQUAL -1)
        set(END ${LIST_LENGTH})
    else()
        math(EXPR END "${BEGIN} + ${LEN}")
        if(${LIST_LENGTH} LESS ${END})
            set(END ${LIST_LENGTH})
        endif()
    endif()
    set(IDXS "")
    while(BEGIN LESS END)
        list(APPEND IDXS ${BEGIN})
        math(EXPR BEGIN "${BEGIN} + 1")
    endwhile()
    if("${IDXS}" STREQUAL "")
        set(SUBLIST "")
    else()
        list(GET LIST ${IDXS} SUBLIST)
    endif()
    set(${OUT_SUBLIST} "${SUBLIST}" PARENT_SCOPE)
endfunction()

## Internal. Similar to "list(TRANSFORM <list> PREPEND <arg> OUTPUT_VARIABLE <output variable>)".
function(nuget_internal_helper_list_transform_prepend LIST STRING_ARG OUT_LIST)
    set(TRANSFORMED_LIST "")
    foreach(ELEMENT IN LISTS LIST)
        string(CONCAT ELEMENT "${STRING_ARG}" "${ELEMENT}")
        list(APPEND TRANSFORMED_LIST "${ELEMENT}")
    endforeach()
    set("${OUT_LIST}" "${TRANSFORMED_LIST}" PARENT_SCOPE)
endfunction()

## Internal. If LIST is "PACKAGE flatbuffers VERSION 1.11.0 PACKAGE icu VERSION 65.1" and 
## DIVIDER is "PACKAGE", then OUT_HEAD will be "PACKAGE flatbuffers VERSION 1.11.0" and
## OUT_TAIL will be the rest of the LIST.
function(nuget_internal_helper_cut_arg_list DIVIDER LIST OUT_HEAD OUT_TAIL)
    set(ITEM_IDX 0)
    list(LENGTH LIST LIST_LENGTH)
    foreach(ITEM ${LIST})
        if(NOT ${ITEM_IDX} EQUAL 0 AND "${ITEM}" STREQUAL "${DIVIDER}")
            break()
        endif()
        math(EXPR ITEM_IDX "${ITEM_IDX} + 1")
    endforeach()
    # Cut by found DIVIDER
    set(HEAD_LENGTH "${ITEM_IDX}")
    math(EXPR TAIL_LENGTH "${LIST_LENGTH} - ${HEAD_LENGTH}")
    # list(SUBLIST LIST 0 ${HEAD_LENGTH} HEAD)
    nuget_internal_helper_list_sublist("${LIST}" 0 ${HEAD_LENGTH} HEAD)
    if(${ITEM_IDX} GREATER_EQUAL ${LIST_LENGTH})
        set(TAIL "")
    else()
        # list(SUBLIST LIST ${ITEM_IDX} ${TAIL_LENGTH} TAIL)
        nuget_internal_helper_list_sublist("${LIST}" ${ITEM_IDX} ${TAIL_LENGTH} TAIL)
    endif()
    # Return variables
    set(${OUT_HEAD} "${HEAD}" PARENT_SCOPE)
    set(${OUT_TAIL} "${TAIL}" PARENT_SCOPE)
endfunction()

## Internal. Assembles the package directory based off of the given args and the 
## NUGET_PACKAGES_DIR cache variable.
function(nuget_internal_helper_get_packages_dir PACKAGE_ID PACKAGE_VERSION OUT_PACKAGE_DIR)
    if(NUGET_EXCLUDE_VERSION)
        set(${OUT_PACKAGE_DIR}
            "${NUGET_PACKAGES_DIR}/${PACKAGE_ID}"
            PARENT_SCOPE
        )
    else()
        set(${OUT_PACKAGE_DIR}
            "${NUGET_PACKAGES_DIR}/${PACKAGE_ID}.${PACKAGE_VERSION}"
            PARENT_SCOPE
        )
    endif()
endfunction()

## Internal.
function(nuget_internal_helper_error_if_empty VARIABLE)
    if("${VARIABLE}" STREQUAL "")
        message(FATAL_ERROR ${ARGN})
    endif()
endfunction()

## Internal.
function(nuget_internal_helper_error_if_not_empty VARIABLE)
    if(NOT "${VARIABLE}" STREQUAL "")
        message(FATAL_ERROR ${ARGN} "\"${VARIABLE}\"")
    endif()
endfunction()

## Internal.
function(nuget_internal_helper_error_if_unparsed_args
    UNPARSED_ARGUMENTS
    KEYWORDS_MISSING_VALUES
)
    nuget_internal_helper_error_if_not_empty(
        "${UNPARSED_ARGUMENTS}"
        "UNPARSED_ARGUMENTS: "
    )
    nuget_internal_helper_error_if_not_empty(
        "${KEYWORDS_MISSING_VALUES}"
        "KEYWORDS_MISSING_VALUES: "
    )
endfunction()

## Internal.
function(nuget_internal_helper_get_cache_variables_with_prefix_and_type PREFIX TYPE OUT_VARIABLES)
    get_cmake_property(QUERIED_VARIABLES CACHE_VARIABLES)
    set(PREFIX_FILTERED_VARIABLES "")
    foreach(QUERIED_VARIABLE IN LISTS QUERIED_VARIABLES)
        string(REGEX MATCH "^${PREFIX}.*" MATCHED_VARIABLE "${QUERIED_VARIABLE}")
        if(NOT "${MATCHED_VARIABLE}" STREQUAL "")
            list(APPEND PREFIX_FILTERED_VARIABLES "${MATCHED_VARIABLE}")
        endif()
    endforeach()
    set(PREFIX_AND_TYPE_FILTERED_VARIABLES "")
    foreach(PREFIX_FILTERED_VARIABLE IN LISTS PREFIX_FILTERED_VARIABLES)
        get_property(PREFIX_FILTERED_VARIABLE_TYPE CACHE "${PREFIX_FILTERED_VARIABLE}" PROPERTY TYPE)
        if("${PREFIX_FILTERED_VARIABLE_TYPE}" STREQUAL "${TYPE}")
            list(APPEND PREFIX_AND_TYPE_FILTERED_VARIABLES "${PREFIX_FILTERED_VARIABLE}")
        elseif("${TYPE}" MATCHES "[ \r\n\t]*")
            list(APPEND PREFIX_AND_TYPE_FILTERED_VARIABLES "${PREFIX_FILTERED_VARIABLE}")
        endif()
    endforeach()
    set("${OUT_VARIABLES}" "${PREFIX_AND_TYPE_FILTERED_VARIABLES}" PARENT_SCOPE)
endfunction()

## Internal.
function(nuget_internal_helper_get_internal_cache_variables_with_prefix PREFIX OUT_VARIABLES)
    nuget_internal_helper_get_cache_variables_with_prefix_and_type("${PREFIX}" INTERNAL OUT_VARIABLES_INTERNAL)
    set("${OUT_VARIABLES}" "${OUT_VARIABLES_INTERNAL}" PARENT_SCOPE)
endfunction()

## Internal.
function(nuget_internal_helper_unset_cache_variables_with_prefix_and_type PREFIX TYPE)
    nuget_internal_helper_get_cache_variables_with_prefix_and_type("${PREFIX}" "${TYPE}" OUT_VARIABLES)
    foreach(OUT_VARIABLE IN LISTS OUT_VARIABLES)
        unset("${OUT_VARIABLE}" CACHE)
    endforeach()
endfunction()
