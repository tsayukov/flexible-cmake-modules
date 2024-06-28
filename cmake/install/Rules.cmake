include_guard(GLOBAL)
after_project_guard()


enable_if_project_variable_is_set(ENABLE_INSTALL)


install_cmake_configs(COMPATIBILITY "SameMajorVersion" ARCH_INDEPENDENT)
install_header_only_library(TARGETS ${my_header_only_library})
install_license()
