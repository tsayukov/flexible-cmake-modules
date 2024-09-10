#[=============================================================================[
  Author: Pavel Tsayukov
  Distributed under the MIT License. See accompanying file LICENSE or
  https://opensource.org/license/mit for details.
  ------------------------------------------------------------------------------
  Documentation generation
  ------------------------------------------------------------------------------
  Enable the `${NAMESPACE}_ENABLE_DOCS` project option to turn
  documentation generation on. See `../Variables.cmake` for details.
  ------------------------------------------------------------------------------
  Commands:
  - add_docs
  Init commands:
  - init_doxygen
  - generate_doxygen_html_templates
  - init_doxygen_awesome
  ------------------------------------------------------------------------------
  Usage:

  # File: CMakeLists.txt

    include_project_module(dependencies/Docs)
    add_docs_if_enabled(docs FORMAT html
      INPUTS
        include
        README.md
    )

#]=============================================================================]

include_guard(GLOBAL)


enable_if(ENABLE_DOCS)

macro(init_doxygen)
  find_package(Doxygen REQUIRED OPTIONAL_COMPONENTS dot)

  # Get the path to the executable file
  get_target_property(DOXYGEN_EXECUTABLE Doxygen::doxygen IMPORTED_LOCATION)

  # Configuration
  # See: https://www.doxygen.nl/manual/config.html

  # Project related configuration options
  set(DOXYGEN_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/docs")

  # Build related configuration options
  set(DOXYGEN_EXTRACT_ALL YES)

  # Configuration options related to the input files
  set(DOXYGEN_RECURSIVE YES)
  set(DOXYGEN_USE_MDFILE_AS_MAINPAGE
    "${PROJECT_SOURCE_DIR}/README.md"
  )

  # Configuration options related to the HTML output
  set(DOXYGEN_GENERATE_TREEVIEW YES)
  set(DOXYGEN_DISABLE_INDEX NO)
  set(DOXYGEN_FULL_SIDEBAR NO)
  set(DOXYGEN_HTML_COLORSTYLE "LIGHT")

  # Configuration options related to diagram generator tools
  if (Doxygen_dot_FOUND)
    set(DOXYGEN_HAVE_DOT YES)
    set(DOXYGEN_DOT_IMAGE_FORMAT "svg")
    set(DOXYGEN_DOT_TRANSPARENT YES)
  endif()
endmacro()

function(generate_doxygen_html_templates)
  __compact_parse_arguments(
    __values
      BASE_DIRECTORY
      HEADER
      FOOTER
      CUSTOM_CSS
  )

  if (NOT ARGS_BASE_DIRECTORY)
    set(ARGS_BASE_DIRECTORY "${PROJECT_BINARY_DIR}/docs/template")
  endif()
  file(MAKE_DIRECTORY "${ARGS_BASE_DIRECTORY}")

  if (NOT ARGS_HEADER)
    set(ARGS_HEADER "header.html")
  endif()

  if (NOT ARGS_FOOTER)
    set(ARGS_FOOTER "footer.html")
  endif()

  if (NOT ARGS_CUSTOM_CSS)
    set(ARGS_CUSTOM_CSS "customdoxygen.html")
  endif()

  execute_process(COMMAND
      ${DOXYGEN_EXECUTABLE} -w html
        ${ARGS_HEADER}
        ${ARGS_FOOTER}
        ${ARGS_CUSTOM_CSS}
    WORKING_DIRECTORY "${ARGS_BASE_DIRECTORY}"
    ERROR_VARIABLE doxygen_generation_error
  )
  if (doxygen_generation_error)
    message(FATAL_ERROR
      "An error occurred while generating Doxygen template files: "
      "${doxygen_generation_error}"
    )
  endif()

  set(DOXYGEN_HTML_HEADER
    "${ARGS_BASE_DIRECTORY}/${ARGS_HEADER}"
  )

  set(DOXYGEN_TEMPLATE_DIR "${ARGS_BASE_DIRECTORY}" PARENT_SCOPE)
endfunction()

macro(init_doxygen_awesome)
  find_path(doxygen_awesome_SOURCE_DIR
      doxygen-awesome.css
    PATH_SUFFIXES
      share/doxygen-awesome-css
  )
  mark_as_advanced(doxygen_awesome_SOURCE_DIR)
  if (NOT doxygen_awesome_SOURCE_DIR)
    can_install_locally(doxygen_awesome)
    include(FetchContent)
    FetchContent_Declare(doxygen_awesome
      GIT_REPOSITORY https://github.com/jothepro/doxygen-awesome-css
      GIT_TAG 40e9b25b6174dd3b472d8868f63323a870dfeeb8 # v2.3.3
    )
    FetchContent_MakeAvailable(doxygen_awesome)
  endif()

  # Configuration

  set(DOXYGEN_HTML_EXTRA_STYLESHEET
    "${doxygen_awesome_SOURCE_DIR}/doxygen-awesome.css"
    "${doxygen_awesome_SOURCE_DIR}/doxygen-awesome-sidebar-only.css"
    "${doxygen_awesome_SOURCE_DIR}/doxygen-awesome-sidebar-only-darkmode-toggle.css"
  )

  # See: https://jothepro.github.io/doxygen-awesome-css/md_docs_2extensions.html#extension-dark-mode-toggle
  set(DOXYGEN_HTML_EXTRA_FILES
    "${doxygen_awesome_SOURCE_DIR}/doxygen-awesome-darkmode-toggle.js"
  )

  if (NOT DEFINED DOXYGEN_TEMPLATE_DIR)
    message(FATAL_ERROR
      "`DOXYGEN_TEMPLATE_DIR` is not defined, "
      "call the `generate_doxygen_html_templates` command before."
    )
  endif()

  file(APPEND "${DOXYGEN_TEMPLATE_DIR}/header.html"
[=[
<!-- Dark Mode Toggle -->
<script type="text/javascript" src="$relpath^doxygen-awesome-darkmode-toggle.js"></script>
<script type="text/javascript">
  DoxygenAwesomeDarkModeToggle.init()
</script>
]=]
  )
endmacro()

#[=============================================================================[
  Add the target for building the documentation of files that can be recursively
  found in the `INPUTS` parameters and to place the result in the `OUTPUT`
  parameter.

    add_docs(<target_suffix> FORMAT <format>
             INPUTS <files or directories> ...
             [OUTPUT <output_directory>])

  The true target name is `${namespace}_${target_suffix}`.

  See supported formats: https://www.doxygen.nl/manual/starting.html#step2.

  By default, `<output_directory>` is `${DOXYGEN_OUTPUT_DIRECTORY}/<format>`.

  Also generate install rules for documentation if `${ENABLE_INSTALL}` is set.
#]=============================================================================]
function(add_docs target_suffix)
  __compact_parse_arguments(__start_with 1
    __values FORMAT OUTPUT
    __lists INPUTS
  )

  if (NOT ARGS_OUTPUT)
    string(TOLOWER ${ARGS_FORMAT} ARGS_OUTPUT)
  endif()

  if (IS_ABSOLUTE "${ARGS_OUTPUT}")
    set(output "${ARGS_OUTPUT}")
  else()
    set(output "${DOXYGEN_OUTPUT_DIRECTORY}/${ARGS_OUTPUT}")
  endif()

  string(TOUPPER ${ARGS_FORMAT} ARGS_FORMAT)

  set(DOXYGEN_GENERATE_${ARGS_FORMAT} YES)
  set(DOXYGEN_${ARGS_FORMAT}_OUTPUT "${output}")

  doxygen_add_docs(
    ${namespace}_${target_suffix} ${ARGS_INPUTS}
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    COMMENT "Generate ${ARGS_FORMAT} documentation"
  )

  if(ENABLE_INSTALL)
    set(docs_component "${namespace}_docs")
    install(DIRECTORY
        "${output}"
      DESTINATION
        "${INSTALL_DOC_DIR}"
      COMPONENT ${docs_component} EXCLUDE_FROM_ALL
    )
    add_component_target(${docs_component})
  endif()
endfunction()


############################# The end of the file ##############################

init_doxygen()
generate_doxygen_html_templates()
init_doxygen_awesome()
