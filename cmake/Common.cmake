include_guard(GLOBAL)


# Prevent including any listfiles before the `project()` command
function(after_project_guard)
  if (NOT (PROJECT_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR))
    get_filename_component(file_name "${CMAKE_CURRENT_LIST_FILE}" NAME)
    message(FATAL_ERROR
      "\n"
      "'${file_name}' must be included in the current listfile after the `project()` command.\n"
    )
  endif()
endfunction()


#[=============================================================================[
  Prevent in-source builds. Prefer to start each listfile with this macro.
  Although, if this project is included as a subproject, the outer project
  is allowed to build wherever it wants.
#]=============================================================================]
macro(no_in_source_builds_guard)
  if (PROJECT_IS_TOP_LEVEL AND (CMAKE_CURRENT_LIST_DIR STREQUAL CMAKE_BINARY_DIR))
    message(FATAL_ERROR
      "\n"
      "In-source builds are not allowed. Instead, provide a path to build tree like so:\n"
      "cmake -B <binary-directory>\n"
      "Or use presets with an out-of-source build configuration like so:\n"
      "cmake --preset <preset-name>\n"
      "To remove files you accidentally created execute:\n"
      "NOTE: be careful if you had you own directory and files with same names! Use your version control system to restore your data.\n"
      "Linux: rm -rf CMakeFiles CMakeCache.txt cmake_install.cmake\n"
      # TODO: check that this command works well in Windows
      "Windows: rmdir CMakeFiles /s /q && del /q CMakeCache.txt cmake_install.cmake\n"
      "NOTE: Build generator files may also remain, that is, 'Makefile', 'build.ninja' and so forth.\n"
    )
  endif()
endmacro()


#[=============================================================================[
  Include the '<module>.cmake' file located in the 'cmake' directory of
  the current project. It let us include cmake-files by name, preventing
  name collisions by using `include(<module>)` when a module with
  the same name is defined in the outer score, e.g. the outer project
  sets its own `CMAKE_MODULE_PATH`.
#]=============================================================================]
macro(include_project_module module)
  include("${PROJECT_SOURCE_DIR}/cmake/${module}.cmake")
endmacro()


#[=============================================================================[
  The `PROJECT_IS_TOP_LEVEL` is set by `project()` in CMake 3.21+.
  Otherwise, the custom version of that variable is used that works in the same
  way as described in the `PROJECT_IS_TOP_LEVEL` documentation.
  See: https://cmake.org/cmake/help/latest/variable/PROJECT_IS_TOP_LEVEL.html
#]=============================================================================]
if (CMAKE_VERSION LESS 3.21)
  string(COMPARE EQUAL
    "${CMAKE_SOURCE_DIR}" "${PROJECT_SOURCE_DIR}"
    PROJECT_IS_TOP_LEVEL
  )
endif()


after_project_guard()
no_in_source_builds_guard()
