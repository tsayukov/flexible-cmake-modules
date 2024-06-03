include_guard(GLOBAL)
after_project_guard()


#[=============================================================================[
  If the documentation is enabled, add the target for building the documentation
  of files that can be recursively found in the `INPUTS` parameters and to place
  the result in the `OUTPUT` parameter.

    add_docs_if_enabled(TARGET <target>
                        FORMAT <format>
                        INPUTS <files or directories> ...
                        OUTPUT <output directory>)

  See supported formats: https://www.doxygen.nl/manual/starting.html#step2.
#]=============================================================================]
function(add_docs_if_enabled)
  set(options "")
  set(one_value_keywords TARGET FORMAT OUTPUT)
  set(multi_value_keywords INPUTS)
  cmake_parse_arguments(PARSE_ARGV 0 "args"
    "${options}"
    "${one_value_keywords}"
    "${multi_value_keywords}"
  )

  enable_if_project_variable_is_set(ENABLE_DOCS)

  string(TOUPPER ${args_FORMAT} args_FORMAT)

  set(DOXYGEN_GENERATE_${args_FORMAT} YES)
  set(DOXYGEN_${args_FORMAT}_OUTPUT "${PROJECT_BINARY_DIR}/${args_OUTPUT}")

  doxygen_add_docs(
    ${args_TARGET} ${args_INPUTS}
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Generate ${args_FORMAT} documentation"
  )
endfunction()


enable_if_project_variable_is_set(ENABLE_DOCS)

set_local_root_for(Doxygen)
find_package(Doxygen)
if (NOT Doxygen_FOUND)
  can_install_locally(Doxygen)
  include(FetchContent)
  FetchContent_Declare(Doxygen
    GIT_REPOSITORY https://github.com/doxygen/doxygen
    GIT_TAG 9b424b03c9833626cd435af22a444888fbbb192d # Release_1_11_0
  )
  populate_package_locally(Doxygen)

  # Requires Python, FLEX, BISON
  execute_process_with_check("Configure Doxygen locally"
    COMMAND "${CMAKE_COMMAND}"
      -G "${CMAKE_GENERATOR}"
      -DCMAKE_INSTALL_PREFIX='${Doxygen_ROOT}'
      -B "${doxygen_BINARY_DIR}"
      -S "${doxygen_SOURCE_DIR}"
    WORKING_DIRECTORY "${doxygen_SOURCE_DIR}"
  )

  execute_process_with_check("Build and install Doxygen locally"
    COMMAND "${CMAKE_COMMAND}"
      --build "${doxygen_BINARY_DIR}"
      --config Release
      --target install
    WORKING_DIRECTORY "${doxygen_SOURCE_DIR}"
  )

  find_package(Doxygen REQUIRED)
endif()

# TODO: implement: pretty doxygen?

# Build related configuration options
# See: https://www.doxygen.nl/manual/config.html#cfg_extract_all
set(DOXYGEN_EXTRACT_ALL YES)
