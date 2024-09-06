#[=============================================================================[
  Author: Pavel Tsayukov
  Distributed under the MIT License. See accompanying file LICENSE or
  https://opensource.org/license/mit for details.
  ------------------------------------------------------------------------------
  Watchers of deprecated commands and normal variables
  ------------------------------------------------------------------------------
  Commands:
  - mark_command_as_deprecated (3.18+, see details)
  - mark_normal_variable_as_deprecated
#]=============================================================================]

include_guard(GLOBAL)


#[=============================================================================[
  For CMake version 3.18+, mark the `${command}` command as deprecated because
  of "${reason}".
  For earlier versions, a corresponding macro should be written manually after
  each definition of a deprecated command:

    # E.g. `foo` is a deprecated command now
    macro(foo)
      message(DEPRECATION "The `foo` command is deprecated.")
      _foo(${ARGV})
    endmacro()

#]=============================================================================]
macro(mark_command_as_deprecated command reason)
  cmake_language(EVAL CODE "
    macro(${command})
      message(DEPRECATION \"The `${command}` command is deprecated because of: ${reason}.\")
      _${command}(" [=[ ${ARGV} ]=] ")
    endmacro()"
  )
endmacro()

#[=============================================================================[
  Mark the `${variable}` normal variable as deprecated because of "${reason}".
  Even though this macro can be used only for normal variables, since all
  project cached variables have aliases, these aliases can be used as normal
  variables in this macro.
#]=============================================================================]
macro(mark_normal_variable_as_deprecated variable reason)
  function(__watcher_deprecated_${variable} variable access)
    if (access STREQUAL "READ_ACCESS")
      message(DEPRECATION "The `${variable}` normal variable is deprecated because of: ${reason}")
    endif()
  endfunction()

  variable_watch(${variable} __watcher_deprecated_${variable})
endmacro()
