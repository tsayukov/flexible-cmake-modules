include_guard(GLOBAL)
after_project_guard()


############################### Project options ################################

#[=============================================================================[
  Allow to install all external dependencies locally (e.g. using `FetchContent`,
  or `ExternalProject` and downloading external sources into the binary
  directory), except to those that is not allowed explicitly by setting
  `${PROJECT_NAME_UPPER}_INSTALL_<dependency-name>_LOCALLY`.
  `<dependency-name>` is just a name using by the `find_package` command.
#]=============================================================================]
project_option(INSTALL_EXTERNALS_LOCALLY
  "Install external dependencies locally"
  OFF
)

project_option(ENABLE_DEVELOPER_MODE "Enable developer mode" OFF)
project_dev_option(ENABLE_TESTING "Enable testing")
project_dev_option(ENABLE_BENCHMARKING "Enable benchmarking")
project_dev_option(ENABLE_COVERAGE "Enable code coverage testing")
project_dev_option(ENABLE_FORMATTING "Enable code formatting")
# TODO: implement other developer options

project_option(ENABLE_DOCS "Enable creating documentation" OFF)

# TODO(?): For small projects it is useless to enable `ccache`
project_option(ENABLE_CCACHE "Enable ccache" OFF)

#[=============================================================================[
  Enable treating the project's include directories as system via passing the
  `SYSTEM` option to the `target_include_directories` command. This may have
  effects such as suppressing warnings or skipping the contained headers in
  dependency calculations (see compiler documentation).
#]=============================================================================]
if (NOT PROJECT_IS_TOP_LEVEL)
  project_option(ENABLE_TREATING_INCLUDES_AS_SYSTEM
    "Use the `SYSTEM` option for the project's includes, compilers may disable warnings"
    ON
  )
endif()
