#[=============================================================================[
  Author: Pavel Tsayukov
  Distributed under the MIT License. See accompanying file LICENSE or
  https://opensource.org/license/mit for details.
  ------------------------------------------------------------------------------
  Debugging
  ------------------------------------------------------------------------------
  Commands:
  - create_symlink_to_compile_commands
  - __print
  - __print_var
  - __print_var_with
#]=============================================================================]

include_guard(GLOBAL)
__after_project_guard()


#[=============================================================================[
  Create a symbolic link in `${PROJECT_SOURCE_DIR}/build/` directory to
  `compile_commands.json` if `${PROJECT_SOURCE_DIR}/build/` itself is not
  the project binary directory.
#]=============================================================================]
function(create_symlink_to_compile_commands)
  if (NOT PROJECT_BINARY_DIR STREQUAL "${PROJECT_SOURCE_DIR}/build")
    file(MAKE_DIRECTORY "${PROJECT_SOURCE_DIR}/build")
    execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
      "${PROJECT_BINARY_DIR}/compile_commands.json"
      "${PROJECT_SOURCE_DIR}/build/compile_commands.json"
    )
  endif()
endfunction()

macro(__print text)
  message("${text}")
endmacro()

macro(__print_var variable)
  message("${variable} = \"${${variable}}\"")
endmacro()

macro(__print_var_with variable hint)
  message("${hint}: ${variable} = \"${${variable}}\"")
endmacro()
