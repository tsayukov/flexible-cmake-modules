include_guard(GLOBAL)
after_project_guard()


#[=============================================================================[
  Set `variable` to `ON` if the developer mode is enable, e.g. by passing
  `-D<PROJECT_NAME>_ENABLE_DEVELOPER_MODE=ON`, where `<MY_PROJECT>` is your
  project name written in uppercase with underscores instead of dashes and
  whitespaces.
  Note, if `variable` is already set, this macro has no effect.
#]=============================================================================]
macro(dev_option variable help_text)
  option(${variable} "${help_text}" ${${PROJECT_NAME_UPPER}_ENABLE_DEVELOPER_MODE})
endmacro()


option(${PROJECT_NAME_UPPER}_ENABLE_DOCS "Enable creating documentation" OFF)

option(${PROJECT_NAME_UPPER}_ENABLE_DEVELOPER_MODE "Enable developer mode" OFF)
dev_option(${PROJECT_NAME_UPPER}_ENABLE_TESTING "Enable testing")
dev_option(${PROJECT_NAME_UPPER}_ENABLE_BENCHMARKING "Enable benchmarking")
dev_option(${PROJECT_NAME_UPPER}_ENABLE_COVERAGE "Enable code coverage testing")
dev_option(${PROJECT_NAME_UPPER}_ENABLE_FORMATTING "Enable code formatting")
# TODO: implement other developer options
