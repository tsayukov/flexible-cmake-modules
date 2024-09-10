#[=============================================================================[
  Author: Pavel Tsayukov
  Distributed under the MIT License. See accompanying file LICENSE or
  https://opensource.org/license/mit for details.
  ------------------------------------------------------------------------------
  Memory checking tools
  ------------------------------------------------------------------------------
  See: https://valgrind.org/
  ------------------------------------------------------------------------------
  Variables:
  - VALGRIND_PATH (can be set before if the `valgrind` path cannot be found by
    CMake)
  Commands:
  - add_memory_check
  - add_unity_memory_check
#]=============================================================================]

include_guard(GLOBAL)


enable_if(ENABLE_MEMORY_CHECKING)

macro(init_valgrind)
  find_program(VALGRIND_PATH valgrind REQUIRED)
  mark_as_advanced(VALGRIND_PATH)

  if ((CMAKE_C_COMPILER_ID STREQUAL "Clang" AND NOT CMAKE_C_COMPILER_VERSION VERSION_LESS "14")
      OR (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS "14"))
    get_version(${VALGRIND_PATH} VALGRIND_VERSION)
    if (VALGRIND_VERSION VERSION_LESS "3.20")
      message(FATAL_ERROR "Only Valgrind 3.20+ works properly with Clang 14+.")
    endif()
  endif()
endmacro()

#[=============================================================================[
  Create a custom target called by `<full-target-name>_memcheck` that runs
  memory checking on the binary file corresponding to the `<full-target-name>`.
  `<full-target-name>` is a result of calling the `get_project_target_name` on
  `${target}`.
#]=============================================================================]
function(add_memory_check target)
  get_project_target_name(${target})
  add_custom_target(${target}_memcheck
    COMMAND ${VALGRIND_PATH}
      --leak-check=yes
      "$<TARGET_FILE:${target}>"
    WORKING_DIRECTORY
      "${PROJECT_BINARY_DIR}"
  )
  set_property(DIRECTORY
      "${PROJECT_SOURCE_DIR}"
    APPEND PROPERTY
      ${NAMESPACE}_MEMCHECK_TARGETS
      ${target}_memcheck
  )
endfunction()

#[=============================================================================[
  Add an unity target called `${namespace}_memcheck` by default, if no name is
  passed as the first parameter. This target runs all memcheck targets that are
  contained in the `${PROJECT_SOURCE_DIR}` directory property
  `${NAMESPACE}_MEMCHECK_TARGETS`, so this function should be called after all
  `add_memory_check` calling.
#]=============================================================================]
function(add_unity_memory_check)
  get_property(memcheck_targets
    DIRECTORY
      "${PROJECT_SOURCE_DIR}"
    PROPERTY
      ${NAMESPACE}_MEMCHECK_TARGETS
  )

  if (ARGC EQUAL "0")
    set(unity_target ${namespace}_memcheck)
  else()
    set(unity_target ${ARGV0})
  endif()

  add_custom_target(${unity_target}
    COMMAND ${CMAKE_COMMAND}
      --build "${PROJECT_BINARY_DIR}"
      --target ${memcheck_targets}
  )
endfunction()


############################# The end of the file ##############################

init_valgrind()
