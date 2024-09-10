#[=============================================================================[
  Author: Pavel Tsayukov
  Distributed under the MIT License. See accompanying file LICENSE or
  https://opensource.org/license/mit for details.
  ------------------------------------------------------------------------------
  Internal variables and commands
  ------------------------------------------------------------------------------
  Variables:
  - PROJECT_IS_TOP_LEVEL (until CMake 3.21)
  Commands:
  - __after_project_guard
  - __parse_and_remove_injected_options
  - __parse_and_remove_injected_one_value_parameters
  - __compact_parse_arguments
  - __xor
#]=============================================================================]

include_guard(GLOBAL)


#[=============================================================================[
  For internal use.
  Prevent including any listfiles before the `project` command in the current
  project root listfile.
#]=============================================================================]
function(__after_project_guard)
  if (NOT PROJECT_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    get_filename_component(file_name "${CMAKE_CURRENT_LIST_FILE}" NAME)
    message(FATAL_ERROR
      "\"${file_name}\" must be included in the current listfile after "
      "the `project` command."
    )
  endif()
endfunction()

__after_project_guard()

#[=============================================================================[
  The `PROJECT_IS_TOP_LEVEL` is set by the `project` command in CMake 3.21+.
  Otherwise, the custom version of that variable is used that works
  in the same way as described in the `PROJECT_IS_TOP_LEVEL` documentation.
  See: https://cmake.org/cmake/help/latest/variable/PROJECT_IS_TOP_LEVEL.html
#]=============================================================================]
if (CMAKE_VERSION LESS "3.21")
  string(COMPARE EQUAL
    "${CMAKE_SOURCE_DIR}" "${PROJECT_SOURCE_DIR}"
    PROJECT_IS_TOP_LEVEL
  )
endif()

#[=============================================================================[
  For internal use. Use this command in functions.
  Find the first appearance of passed options in an outer function's `${ARGN}`,
  set each variable called by option's name to `ON` if found, otherwise, set
  the variable to `OFF`. Remove the first appearance of each option from
  the outer function's `${ARGN}`.
#]=============================================================================]
macro(__parse_and_remove_injected_options)
  foreach (__option IN LISTS ${ARGN})
    set(${__option} OFF)
    if (NOT ARGC EQUAL "0")
      list(FIND ARGN "${__option}" __option_index)
      if (NOT __option_index EQUAL "-1")
        set(${__option} ON)
        list(REMOVE_AT ARGN ${__option_index})
      endif()
    endif()
  endforeach()
endmacro()

#[=============================================================================[
  For internal use. Use this command in functions.
  Find the first appearance of passed one-value keys in an outer function's
  `${ARGN}`, set each variable called by key's name to the value following it
  for each found key, raise an error, if no such value is found, otherwise, set
  the variable to an empty string. Remove the first appearance of each key-value
  pair from the outer function's `${ARGN}`.
#]=============================================================================]
macro(__parse_and_remove_injected_one_value_parameters)
  list(LENGTH ARGN __length)
  math(EXPR __last_index "__length - 1")
  foreach (__key IN LISTS ${ARGN})
    set(${__key} "")
    if (NOT ARGC EQUAL "0")
      list(FIND ARGN "${__key}" __key_index)
      if (__key_index GREATER_EQUAL __last_index)
        message(FATAL_ERROR
          "`${__key}` cannot be the last parameter, "
          "because a value is expected after it."
        )
      endif()
      if (NOT __key_index EQUAL "-1")
        math(EXPR __value_index "${__key_index} + 1")
        list(GET ARGN ${__value_index} ${__key})
        list(REMOVE_AT ARGN ${__key_index} ${__value_index})
      endif()
    endif()
  endforeach()
endmacro()

#[=============================================================================[
  For internal use. Use this command in functions.
  The compact version of parsing of a function's parameters.

    __compact_parse_arguments([__start_with <N>] [__prefix <prefix>]
                              [__options <options>]
                              [__values <one_value_keywords>]
                              [__lists <multi_value_keywords>])

  See: https://cmake.org/cmake/help/latest/command/cmake_parse_arguments.html
#]=============================================================================]
macro(__compact_parse_arguments)
  set(options "")
  set(one_value_keywords
    __start_with
    __prefix
  )
  set(multi_value_keywords
    __options
    __values
    __lists
  )
  cmake_parse_arguments("__ARGS"
    "${options}"
    "${one_value_keywords}"
    "${multi_value_keywords}"
    ${ARGN}
  )

  if (NOT __ARGS___prefix)
    set(__ARGS___prefix "ARGS")
  endif()

  if (NOT __ARGS___start_with)
    set(__ARGS___start_with "0")
  endif()

  set(options ${__ARGS___options})
  set(one_value_keywords ${__ARGS___values})
  set(multi_value_keywords ${__ARGS___lists})
  cmake_parse_arguments(PARSE_ARGV ${__ARGS___start_with} "${__ARGS___prefix}"
    "${options}"
    "${one_value_keywords}"
    "${multi_value_keywords}"
  )
endmacro()

# For internal use.
# Exclusive OR. Use the `__xor_result` variable to get the result.
function(__xor lhs rhs)
  if (((NOT "${lhs}") AND "${rhs}") OR ("${lhs}" AND (NOT "${rhs}")))
    set(__xor_result ON PARENT_SCOPE)
  else()
    set(__xor_result OFF PARENT_SCOPE)
  endif()
endfunction()
