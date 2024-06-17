include_guard(GLOBAL)
after_project_guard()


enable_if_project_variable_is_set(ENABLE_INSTALL)


install_cmake_configs(ARCH_INDEPENDENT)

install(TARGETS
    ${my_header_only_library}
    ${cxx_standard}
  EXPORT "${PACKAGE_NAME}Targets"
  INCLUDES DESTINATION "${INSTALL_INCLUDE_DIR}"
)

install(EXPORT
    "${PACKAGE_NAME}Targets"
  NAMESPACE ${namespace_lower}::
  DESTINATION "${INSTALL_CMAKE_DIR}"
)

install(DIRECTORY
    "${PROJECT_SOURCE_DIR}/include/"
  TYPE INCLUDE
  FILES_MATCHING
    PATTERN "*.h"
    PATTERN "*.hpp"
)
