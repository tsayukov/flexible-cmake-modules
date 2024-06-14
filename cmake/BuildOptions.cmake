include_guard(GLOBAL)
after_project_guard()


#[=============================================================================[
  Set a project option named `${name}` to `ON` if the developer mode is enable,
  e.g. by passing `-D${PROJECT_NAME_UPPER}_ENABLE_DEVELOPER_MODE=ON`, where
  `${PROJECT_NAME_UPPER}` is the project name written in uppercase with
  underscores instead of dashes and whitespaces. Note, if the project option
  `${name}` is already set, this macro has no effect.
#]=============================================================================]
macro(project_dev_option name help_text)
  project_option(${name} "${help_text}" ${ENABLE_DEVELOPER_MODE})
endmacro()


# TODO(?): For small projects it is useless to enable `ccache`
project_option(ENABLE_CCACHE "Enable ccache" OFF)

project_option(ENABLE_DOCS "Enable creating documentation" OFF)

project_option(ENABLE_DEVELOPER_MODE "Enable developer mode" OFF)
project_dev_option(ENABLE_TESTING "Enable testing")
project_dev_option(ENABLE_BENCHMARKING "Enable benchmarking")
project_dev_option(ENABLE_COVERAGE "Enable code coverage testing")
project_dev_option(ENABLE_FORMATTING "Enable code formatting")
# TODO: implement other developer options
