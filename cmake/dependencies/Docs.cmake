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

find_package(Doxygen REQUIRED)
find_path(DoxygenAwesome_SOURCE_DIR
    doxygen-awesome.css
  PATH_SUFFIXES
    share/doxygen-awesome-css
)
mark_as_advanced(CLEAR DoxygenAwesome_SOURCE_DIR)
if (NOT DoxygenAwesome_SOURCE_DIR)
  can_install_locally(DoxygenAwesome)
  include(FetchContent)
  FetchContent_Declare(DoxygenAwesome
    GIT_REPOSITORY https://github.com/jothepro/doxygen-awesome-css
    GIT_TAG 40e9b25b6174dd3b472d8868f63323a870dfeeb8 # v2.3.3
  )
  FetchContent_MakeAvailable(DoxygenAwesome)
endif()


# Build related configuration options
# See: https://www.doxygen.nl/manual/config.html#cfg_extract_all
set(DOXYGEN_EXTRACT_ALL YES)
set(DOXYGEN_GENERATE_TREEVIEW YES)
set(DOXYGEN_HAVE_DOT YES)
set(DOXYGEN_DOT_IMAGE_FORMAT svg)
set(DOXYGEN_DOT_TRANSPARENT YES)
set(DOXYGEN_HTML_EXTRA_STYLESHEET "${DoxygenAwesome_SOURCE_DIR}/doxygen-awesome.css")
