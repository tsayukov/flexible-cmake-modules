#[=============================================================================[
  Author: Pavel Tsayukov
  Distributed under the MIT License. See accompanying file LICENSE or
  https://opensource.org/license/mit for details.
  ------------------------------------------------------------------------------
  Project related commands
  ------------------------------------------------------------------------------
  To prevent name clashes all project cached variables, targets, and properties
  defined by functions and macros below have a prefix followed by underscore.
  This prefix is defined by the `define_project_namespace([<prefix>])` command.
  It is recommended to name cached variables and properties in uppercase letters
  with underscores. On the contrary, it is recommended to name targets in
  lowercase letters with underscore. The prefix, aka namespace, format is
  selected accordingly, in uppercase or lowercase letters with underscores.
  In addition, normal variables are defined for all project cached variables as
  short aliases. These variables are set to the value of the corresponding
  project cached variable.

  E.g. the `project_option(ENABLE_FEATURE "Enable a cool feature" ON)` command
  is trying to set an option, aka boolean cached variable, named by
  `${NAMESPACE}_ENABLE_FEATURE`. A short alias named by `ENABLE_FEATURE`
  is also defined and set to `ON`.

  E.g. the `add_project_library(my_library INTERFACE)` command defines
  an interface library named by `${namespace}_my_library`. To use the short
  alias `my_library`, use `project_target_*` commands (see below) and pass it to
  them instead of the full target name. Typical usage:

    project_target_link_libraries(my_library INTERFACE another_library)

  All `target_*` commands have `project_target_*` counterparts. They take some
  `${target}` name and resolve it in the following way:
  (a) if the `${target}` has a `${namespace}::<target_suffix>` form, replace
     `::` to `_`, raise an error if there's no such target;
  (b) if there's a `${namespace}_${target}` target, use it;
  (c) otherwise, use the ${target}.

  Let's say we define a project target named by `${namespace}_my_library`.
  The `EXPORT_NAME` property is also added to the target and set to `my_library`.
  It is nessecary in order to use the command below to export the target as
  `${namespace}::my_library`:

    install(TARGETS ${namespace}_my_library ...)
    install(EXPORT ... NAMESCAPE ${namespace}::)

  An alias target named by `${namespace}::my_library` is also defined.
  When a consuming project gets this project via the `find_package` command
  it uses exported targets, e.g. `${namespace}::my_library`, that defined
  by `install(EXPORT ... NAMESPACE ${namespace}::)`.
  But if a consuming project gets this project via the `FetchContent` module or
  `add_subdirectory` command it has to use `${namespace}_my_library` until this
  project adds an alias defenition:

    add_library(${namespace}::my_library ALIAS ${namespace}_my_library)

  Summing up, changing the method of getting this project won't cause
  to change the command usage below in any of these cases:

    `target_link_libraries(<consuming_target> ... ${namespace}::my_library)`

  If `${NAMESPACE}_ENABLE_INSTALL` is enabled and a project target is not
  excluded from installation manually (see `add_project_*` for details),
  the project target is added to the `${PROJECT_SOURCE_DIR}` directory property
  `${NAMESPACE}_INSTALL_PROJECT_TARGETS`. So, the `install_project_targets`
  command can be used without passed project targets.
  ------------------------------------------------------------------------------
  Command groups:
  - Project namespace:
    - define_project_namespace
  - Project options and cached variables:
    - enable_if_project_variable_is_set
    - project_option
    - project_dev_option
    - project_cached_variable
  - Project target creation:
    - add_project_library
    - add_project_executable
  - `target_*` counterparts:
    - project_target_compile_definitions
    - project_target_compile_features
    - project_target_compile_options
    - project_target_include_directories
    - project_target_link_directories
    - project_target_link_libraries
    - project_target_link_options
    - project_target_precompile_headers
    - project_target_sources
  - Project target properties:
    - get_project_target_property
    - set_project_target_property
#]=============================================================================]

include_guard(GLOBAL)
__after_project_guard()


############################## Project namespace ###############################

# Define the namespace, by default it is `${PROJECT_NAME}` in the appropriate
# format, see `NAMESPACE` and `namespace` variables.
function(define_project_namespace)
  if (ARGC EQUAL "0")
    set(namespace ${PROJECT_NAME})
  else()
    set(namespace ${ARGV0})
  endif()

  string(REGEX REPLACE "[- ]" "_" namespace ${namespace})

  string(TOUPPER ${namespace} namespace)
  set(NAMESPACE ${namespace} PARENT_SCOPE)

  string(TOLOWER ${namespace} namespace)
  set(namespace ${namespace} PARENT_SCOPE)
endfunction()


##################### Project options and cached variables #####################

# Enable the rest of a listfile if the project cached variable is set
macro(enable_if_project_variable_is_set variable_suffix)
  if (NOT ${NAMESPACE}_${variable_suffix})
    return()
  endif()
endmacro()

#[=============================================================================[
  Set a project option named `${NAMESPACE}_${variable_alias}` if there is no
  such normal or cached variable set before (see CMP0077 for details). Other
  parameters of the `option` command are passed after the `variable_alias`
  parameter, except that the `value` parameter is required now.
  Use the short alias `${ALIAS}` to get the option's value where `ALIAS` is
  `${variable_alias}`.

    project_option(<variable_alias> "<help_text>" <value> [IF <condition>])

  The `condition` parameter after the `IF` keyword is a condition that is used
  inside the `if (<condition>)` command. If it is true, the project option will
  try to set to `${value}`, otherwise, to the opposite one.
#]=============================================================================]
function(project_option variable_alias help_text value)
  set(options "")
  set(one_value_keywords "")
  set(multi_value_keywords IF)
  cmake_parse_arguments(PARSE_ARGV 3 "ARGS"
    "${options}"
    "${one_value_keywords}"
    "${multi_value_keywords}"
  )

  set(variable ${NAMESPACE}_${variable_alias})

  if (value)
    set(not_value OFF)
  else()
    set(not_value ON)
  endif()

  if (DEFINED ARGS_IF)
    if (${ARGS_IF})
      option(${variable} "${help_text}" ${value})
    else()
      option(${variable} "${help_text}" ${not_value})
    endif()
  else()
    option(${variable} "${help_text}" ${value})
  endif()

  set(${variable_alias} ${${variable}} PARENT_SCOPE)
endfunction()

#[=============================================================================[
  Set a project option named by `${NAMESPACE}_${variable_alias}` to `ON`
  if the developer mode is enable, e.g. by passing
  `-D${NAMESPACE}_ENABLE_DEVELOPER_MODE=ON`.
  Note, if this project option is already set, this macro has no effect.
  Use the short alias `${ALIAS}` to get the option's value where `ALIAS`
  is `${variable_alias}`.
#]=============================================================================]
macro(project_dev_option variable_alias help_text)
  project_option(${variable_alias} "${help_text}" ${ENABLE_DEVELOPER_MODE})
endmacro()

#[=============================================================================[
  Set a project cached variable named by `${NAMESPACE}_${variable_alias}`
  if there is no such cached variable set before (see CMP0126 for details).
  Use the short alias `${ALIAS}` to get the cached variable's value where
  `ALIAS` is `${variable_alias}`.
#]=============================================================================]
function(project_cached_variable variable_alias value type docstring)
  set(${NAMESPACE}_${variable_alias} ${value} CACHE ${type}
    "${docstring}" ${ARGN}
  )
  set(${variable_alias} ${${NAMESPACE}_${variable_alias}} PARENT_SCOPE)
endfunction()


########################### Project target creation ############################

#[=============================================================================[
  Add a project library target called by `${namespace}_${target_suffix}`.
  All parameters of the `add_library` command are passed after `target_suffix`.
  Set the `EXCLUDE_FROM_INSTALLATION` option to exclude the target from
  installation.
#]=============================================================================]
function(add_project_library target_suffix)
  __process_injected_option(EXCLUDE_FROM_INSTALLATION)

  set(target ${namespace}_${target_suffix})
  add_library(${target} ${ARGN})
  add_library(${namespace}::${target_suffix} ALIAS ${target})
  set_target_properties(${target} PROPERTIES EXPORT_NAME ${target_suffix})

  if (ENABLE_INSTALL AND NOT EXCLUDE_FROM_INSTALLATION)
    append_install_project_target(${target})
  endif()
endfunction()

#[=============================================================================[
  Add an executable target called by `${namespace}_${target_suffix}`.
  All parameters of the `add_executable` command are passed after `target_suffix`.
  Set the `EXCLUDE_FROM_INSTALLATION` option to exclude the target from
  installation.
#]=============================================================================]
function(add_project_executable target_suffix)
  __process_injected_option(EXCLUDE_FROM_INSTALLATION)

  set(target ${namespace}_${target_suffix})
  add_executable(${target} ${ARGN})
  add_executable(${namespace}::${target_suffix} ALIAS ${target})
  set_target_properties(${target} PROPERTIES EXPORT_NAME ${target_suffix})

  if (ENABLE_INSTALL AND NOT EXCLUDE_FROM_INSTALLATION)
    append_install_project_target(${target})
  endif()
endfunction()


########################### `target_*` counterparts ############################

function(project_target_compile_definitions target)
  __get_project_target_name(${target})
  target_compile_definitions(${target} ${ARGN})
endfunction()

function(project_target_compile_features target)
  __get_project_target_name(${target})
  target_compile_features(${target} ${ARGN})
endfunction()

function(project_target_compile_options target)
  __get_project_target_name(${target})
  target_compile_options(${target} ${ARGN})
endfunction()

function(project_target_include_directories target)
  __get_project_target_name(${target})
  if (ENABLE_TREATING_INCLUDES_AS_SYSTEM)
    set(warning_guards "SYSTEM")
  else()
    set(warning_guards "")
  endif()
  target_include_directories(${target} ${warning_guards} ${ARGN})
endfunction()

function(project_target_link_directories target)
  __get_project_target_name(${target})
  target_link_directories(${target} ${ARGN})
endfunction()

function(project_target_link_libraries target)
  __get_project_target_name(${target})
  target_link_libraries(${target} ${ARGN})
endfunction()

function(project_target_link_options target)
  __get_project_target_name(${target})
  target_link_options(${target} ${ARGN})
endfunction()

function(project_target_precompile_headers target)
  __get_project_target_name(${target})
  target_precompile_headers(${target} ${ARGN})
endfunction()

function(project_target_sources target)
  __get_project_target_name(${target})
  target_sources(${target} ${ARGN})
endfunction()

function(__get_project_target_name target)
  if ("${target}" MATCHES "^${namespace}::")
    string(REPLACE "::" "_" target ${target})
    if (NOT TARGET "${target}")
      message(FATAL_ERROR "There is no such project target \"${target}\".")
    endif()
  elseif (TARGET "${namespace}_${target}")
    set(target ${namespace}_${target})
  endif()
  set(target ${target} PARENT_SCOPE)
endfunction()


########################## Project target properties ###########################

macro(get_project_target_property variable target project_property)
  get_target_property("${variable}" ${target} ${NAMESPACE}_${project_property})
endmacro()

macro(set_project_target_property target project_property value)
  set_target_properties(${target}
    PROPERTIES
      ${NAMESPACE}_${project_property} "${value}"
  )
endmacro()
