## Helpers
function(assert LHS RELATION RHS)
    if(NOT "${LHS}" ${RELATION} "${RHS}")
        message(FATAL_ERROR "Assertion \"${LHS}\" ${RELATION} \"${RHS}\" does not hold.")
    endif()
endfunction()
