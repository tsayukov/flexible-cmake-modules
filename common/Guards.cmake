#[=============================================================================[
  Author: Pavel Tsayukov
  Distributed under the MIT License. See accompanying file LICENSE or
  https://opensource.org/license/mit for details.
  ------------------------------------------------------------------------------
  Guards
  ------------------------------------------------------------------------------
  Commands:
  - requires_cmake
  - no_in_source_builds_guard
#]=============================================================================]

include_guard(GLOBAL)
__after_project_guard()


#[=============================================================================[
  Check if CMake's version is not less than `${version}`, otherwise, print
  the error message with "${reason}". It may be useful if building in the
  developer mode needs higher CMake's version than building to only install
  the project.
#]=============================================================================]
function(requires_cmake version reason)
  if (CMAKE_VERSION VERSION_LESS "${version}")
    message(FATAL_ERROR
      "CMake ${version}+ is required because of the reason \"${reason}\", but "
      "the current version is ${CMAKE_VERSION}."
    )
  endif()
endfunction()

#[=============================================================================[
  Prevent in-source builds.

    no_in_source_builds_guard([RECURSIVE <directories>...])

  Check if the current listfile's directory is not the project binary directory.
  If `<directories>` are passed, check if the project binary directory doesn't
  include any of`<directories>`'s paths. If some of `<directories>`'s paths are
  a relative path, prepend the current listfile's directory to them.

  Although, if this project is included as a subproject, the outer project
  is allowed to build wherever it wants.
#]=============================================================================]
function(no_in_source_builds_guard)
  if (NOT PROJECT_IS_TOP_LEVEL)
    return()
  endif()

  __compact_parse_arguments(__lists RECURSIVE)

  set(error_message
    "In-source builds are not allowed. Instead, provide a path to build tree "
    "like so:\n"

    "cmake -B <binary-directory>\n"

    "Or use presets with an out-of-source build configuration like so:\n"

    "cmake --preset <preset-name>\n"

    "To remove files you accidentally created execute:\n"

    "NOTE: be careful if you had you own directory and files with same names! "
    "Use your version control system to restore your data.\n"

    "Linux: rm -rf CMakeFiles CMakeCache.txt cmake_install.cmake\n"

    "Windows (PowerShell): "
    "Remove-Item CMakeFiles, CMakeCache.txt, cmake_install.cmake -Force -Recurse\n"

    "Windows (Command Prompt): "
    "rmdir CMakeFiles /s /q && del /q CMakeCache.txt cmake_install.cmake\n"

    "NOTE: Build generator files may also remain, that is, 'Makefile', "
    "'build.ninja' and so forth."
  )

  if (CMAKE_CURRENT_LIST_DIR STREQUAL PROJECT_BINARY_DIR)
    message(FATAL_ERROR ${error_message})
  endif()

  foreach (dir IN LISTS ARGS_RECURSIVE)
    if (NOT IS_ABSOLUTE "${dir}")
      set(dir "${CMAKE_CURRENT_LIST_DIR}/${dir}")
    endif()
    if (PROJECT_BINARY_DIR MATCHES "^${dir}/?")
      message(FATAL_ERROR ${error_message})
    endif()
  endforeach()
endfunction()
