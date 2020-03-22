include(GNUInstallDirs)

install(
    DIRECTORY "${PACKAGE_DIR}"
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    # Note: empty folders are copied: https://gitlab.kitware.com/cmake/cmake/issues/17122
    FILES_MATCHING
        PATTERN "*.dll"
        PATTERN "*.pdb"
)
