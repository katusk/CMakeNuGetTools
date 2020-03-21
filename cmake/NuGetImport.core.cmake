# Internal. Registers the given package, nothing more. The _nuget_core_install()
# function should be called for actually installing the package. USAGE_REQUIREMENT
# is expected to be either PUBLIC, INTERFACE, or PRIVATE.
function(_nuget_core_register
    PACKAGE_ID
    PACKAGE_VERSION
    USAGE_REQUIREMENT
)
    # Inputs
    _nuget_helper_error_if_empty("${PACKAGE_ID}" "Package ID must be provided.")
    _nuget_helper_error_if_empty("${PACKAGE_VERSION}" "Package version must be provided.")
    _nuget_helper_error_if_empty("${USAGE_REQUIREMENT}" "Usage requirement for package must be provided.")
    if(DEFINED "NUGET_PACKAGE_VERSION_${PACKAGE_ID}")
        # Safety check. Do not allow more than one package to be used within the same CMake build
        # system with the same package ID but with different version numbers. The same version
        # can be installed as many times as you want -- only the first successful NuGet install
        # invocation has the effect of fetching the package to the OutputDirectory. Additional
        # calls to NuGet install are allowed but they would not do anything as the package is
        # already installed.
        #
        # NOTE. This check fails to catch additional dependencies installed by NuGet in
        # execute_process() in _nuget_core_install(). This problem can be avoided if
        # _nuget_core_install() is invoked for all the packages that are your transitive
        # dependencies.
        if(NOT "${NUGET_PACKAGE_VERSION_${PACKAGE_ID}}" STREQUAL "${PACKAGE_VERSION}")
            message(FATAL_ERROR
                "NuGet package \"${PACKAGE_ID}\" is already registered "
                "with version ${NUGET_PACKAGE_VERSION_${PACKAGE_ID}}. "
                "You are trying to register version ${PACKAGE_VERSION}."
            )
        endif()
        # Registering the same package multiple times with different usage requirements
        # is not allowed.
        if(NOT "${NUGET_PACKAGE_USAGE_${PACKAGE_ID}}" STREQUAL "${USAGE_REQUIREMENT}")
            message(FATAL_ERROR
                "NuGet package \"${PACKAGE_ID}\" is already registered "
                "with usage requirement ${NUGET_PACKAGE_USAGE_${PACKAGE_ID}}. "
                "You are trying to register with usage ${USAGE_REQUIREMENT}."
            )
        endif()
        # Return if already registered
        return()
    endif()
    # Set internal cache variables
    set(PACKAGES_REGISTERED ${NUGET_PACKAGES_REGISTERED})
    list(APPEND PACKAGES_REGISTERED "${PACKAGE_ID}")
    set(NUGET_PACKAGES_REGISTERED "${PACKAGES_REGISTERED}" CACHE INTERNAL
        "The list of the registered NuGet packages in this build system."
    )
    set("NUGET_PACKAGE_VERSION_${PACKAGE_ID}" ${PACKAGE_VERSION} CACHE INTERNAL
        "The version of the registered package \"${PACKAGE_ID}\"."
    )
    set("NUGET_PACKAGE_USAGE_${PACKAGE_ID}" ${USAGE_REQUIREMENT} CACHE INTERNAL
        "The usage requirement of the registered package \"${PACKAGE_ID}\"."
    )
endfunction()

## Internal. Runs NuGet install with PACKAGE_ID and PACKAGE_VERSION.
## The OutputDirectory is set by the CACHE variable NUGET_PACKAGES_DIR.
##
## POST_INSTALL_HOOK is a path to a custom CMake script to be included at the
## end of this function (e.g. it can be used to install() all *.dll and *.pdb
## files from the NuGet package's directory to the ${CMAKE_INSTALL_PREFIX}/bin
## destination directory on Windows).
function(_nuget_core_install
    PACKAGE_ID
    PACKAGE_VERSION
    POST_INSTALL_HOOK
)
    # Inputs
    if(NUGET_PRERELEASE_ALLOWED)
        set(PRERELEASE_OPTION "-Prerelease")
    endif()
    if("${POST_INSTALL_HOOK}" STREQUAL "")
        set(POST_INSTALL_HOOK "${NUGET_DEFAULT_POST_INSTALL_HOOK}") # Default
    endif()
    _nuget_helper_error_if_empty("${NUGET_COMMAND}" "No NuGet executable was provided.")
    # Execute install
    #
    # NOTE. Output is not parsed for additionally installed dependencies. It does not worth
    # the coding effort. Just make sure _nuget_core_install() is explicitly called for all
    # your PUBLIC and PRIVATE transitive dependencies. I.e. the user should explicitly list
    # all dependencies that should be installed.
    execute_process(
        COMMAND "${NUGET_COMMAND}" install ${PACKAGE_ID}
            -Version ${PACKAGE_VERSION}
            -OutputDirectory "${NUGET_PACKAGES_DIR}"
            ${PRERELEASE_OPTION}
            -NonInteractive
        ERROR_VARIABLE
            NUGET_INSTALL_ERROR_VAR
        RESULT_VARIABLE
            NUGET_INSTALL_RESULT_VAR
    )
    _nuget_helper_error_if_non_empty(
        "${NUGET_INSTALL_ERROR_VAR}"
        "Running NuGet package install encountered some errors: "
    )
    if(NOT ${NUGET_INSTALL_RESULT_VAR} EQUAL 0)
        message(FATAL_ERROR "NuGet package install returned with: \"${NUGET_INSTALL_RESULT_VAR}\"")
    endif()
    # Include post-install hook
    if(NOT "${POST_INSTALL_HOOK}" STREQUAL "")
        include("${POST_INSTALL_HOOK}")
    endif()
    # Mark package as succesfully installed
    set("NUGET_PACKAGE_INSTALLED_${PACKAGE_ID}" TRUE CACHE INTERNAL
        "True if the package \"${PACKAGE_ID}\" is successfully installed."
    )
    _nuget_helper_get_package_dir(${PACKAGE_ID} ${PACKAGE_VERSION} PACKAGE_DIR)
    set("NUGET_PACKAGE_DIR_${PACKAGE_ID}" "${PACKAGE_DIR}" CACHE INTERNAL
        "Absolute path to the directory of the installed package \"${PACKAGE_ID}\"."
    )
endfunction()

## Internal. Only Visual Studio generators are compatible. Creates a CMake build target
## named IMPORT_AS (if non-empty, otherwise: PACKAGE_ID) from the PACKAGE_ID package with
## PACKAGE_VERSION version using the "${NUGET_DOT_TARGETS_DIR}/${PACKAGE_ID}.targets"
## file within the package. INCLUDE_DIR relative to the package directory is ignored if
## IGNORE_INCLUDE_DIR is set. INCLUDE_DIR is required for better Visual Studio editing
## experience.
function(_nuget_core_import_dot_targets
    PACKAGE_ID
    PACKAGE_VERSION
    IMPORT_AS
    INCLUDE_DIR
    IGNORE_INCLUDE_DIR
)
    # Compatibility check
    if(NOT CMAKE_GENERATOR MATCHES "^Visual Studio")
        message(FATAL_ERROR
            "You are trying to import the \"${PACKAGE_ID}\" NuGet package via a "
            ".targets file whereas your CMake generator is \"${CMAKE_GENERATOR}\". "
            "Only Visual Studio generators are compatible with this import method."
        )
    endif()
    # Inputs
    if("${IMPORT_AS}" STREQUAL "")
        set(IMPORT_AS "${PACKAGE_ID}")
    endif()
    if("${INCLUDE_DIR}" STREQUAL "")
        set(INCLUDE_DIR "build/native/include") # Default
    endif()
    set(INCLUDE_DIR "${NUGET_PACKAGE_DIR_${PACKAGE_ID}}/${INCLUDE_DIR}")
    if(TARGET ${IMPORT_AS})
        message(FATAL_ERROR
            "You are trying to import the \"${PACKAGE_ID}\" NuGet package "
            "with an already existing target name \"${IMPORT_AS}\"."
        )
    endif()
    # NOTE. The fallback "build/${PACKAGE_ID}.targets" is deliberately not tried.
    # One should always place the native .target file under "build/native/".
    set(DOT_TARGETS_FILE
        "${NUGET_PACKAGE_DIR_${PACKAGE_ID}}/build/native/${PACKAGE_ID}.targets" # Default (and non-settable)
    )
    if(NOT EXISTS "${DOT_TARGETS_FILE}")
        message(FATAL_ERROR "The file \"${DOT_TARGETS_FILE}\" does not exist.")
    endif()

    # Create build target
    add_library(${IMPORT_AS} INTERFACE IMPORTED GLOBAL)
    set_property(TARGET ${IMPORT_AS} PROPERTY INTERFACE_LINK_LIBRARIES "${DOT_TARGETS_FILE}")
    if(NOT IGNORE_INCLUDE_DIR)
        # Experience shows that the Visual Studio editor does not recognize anything included
        # unless you set this property. Building your target would work regardless of setting
        # this property if the imported .targets file is written properly.
        set_property(TARGET ${IMPORT_AS} PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${INCLUDE_DIR}")
    endif()
endfunction()

## Internal. Prepends the IMPORT_FROM relative-to-package-directory path to the CMAKE_PREFIX_PATH
## if AS_MODULE is FALSE and NO_OVERRIDE is FALSE. If AS_MODULE is TRUE then the CMAKE_MODULE_PATH
## is modified. If NO_OVERRIDE is TRUE, the operation becomes an append instead of a prepend.
function(_nuget_core_import_cmake_exports
    PACKAGE_ID
    PACKAGE_VERSION
    IMPORT_FROM
    AS_MODULE
    NO_OVERRIDE
)
    # Inputs
    if("${IMPORT_FROM}" STREQUAL "")
        set(IMPORT_FROM "build/native/cmake") # Default
    endif()
    set(IMPORT_FROM "${NUGET_PACKAGE_DIR_${PACKAGE_ID}}/${IMPORT_FROM}")

    # Modify prefix or module path
    # See https://cmake.org/cmake/help/latest/command/find_package.html#search-procedure
    if(AS_MODULE)
        if(NO_OVERRIDE)
            set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${IMPORT_FROM}")
            # list(APPEND CMAKE_MODULE_PATH "${IMPORT_FROM}")
        else()
            set(CMAKE_MODULE_PATH "${IMPORT_FROM}" ${CMAKE_MODULE_PATH})
            # list(INSERT CMAKE_MODULE_PATH 0 "${IMPORT_FROM}")
        endif()
    else()
        if(NO_OVERRIDE)
            set(CMAKE_PREFIX_PATH ${CMAKE_MODULE_PATH} "${IMPORT_FROM}")
            # list(APPEND CMAKE_PREFIX_PATH "${IMPORT_FROM}")
        else()
            set(CMAKE_PREFIX_PATH "${IMPORT_FROM}" ${CMAKE_MODULE_PATH})
            # list(INSERT CMAKE_PREFIX_PATH 0 "${IMPORT_FROM}")
        endif()
    endif()
endfunction()
