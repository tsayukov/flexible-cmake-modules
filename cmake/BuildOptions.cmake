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


############################### Project options ################################

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
    "Use the `SYSTEM` option for the project's includes; compilers may disable warnings"
    ON
  )
  if (ENABLE_TREATING_INCLUDES_AS_SYSTEM)
    set(warning_guard SYSTEM)
  endif()
endif()
