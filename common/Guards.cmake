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
  TODO(issue #31): make this command universal
  Prevent in-source builds. Prefer to start each listfile with this function.
  Although, if this project is included as a subproject, the outer project
  is allowed to build wherever it wants.
#]=============================================================================]
function(no_in_source_builds_guard)
  if (PROJECT_IS_TOP_LEVEL AND (CMAKE_CURRENT_LIST_DIR STREQUAL CMAKE_BINARY_DIR))
    message(FATAL_ERROR
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
  endif()
endfunction()
