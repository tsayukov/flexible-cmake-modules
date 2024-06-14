include_guard(GLOBAL)


#[=============================================================================[
  This macro must be called at the end of the current listfile.
  It checks if the `project` command is already called, prevents in-source
  builds inside the 'cmake' directory, and initialize some common variables.
#]=============================================================================]
macro(init_common)
  # This guard should be at the beginning
  after_project_guard()

  #[===========================================================================[
    The `PROJECT_IS_TOP_LEVEL` is set by the `project` command in CMake 3.21+.
    Otherwise, the custom version of that variable is used that works
    in the same way as described in the `PROJECT_IS_TOP_LEVEL` documentation.
    See: https://cmake.org/cmake/help/latest/variable/PROJECT_IS_TOP_LEVEL.html
  #]===========================================================================]
  if (CMAKE_VERSION LESS "3.21")
    string(COMPARE EQUAL
      "${CMAKE_SOURCE_DIR}" "${PROJECT_SOURCE_DIR}"
      PROJECT_IS_TOP_LEVEL
    )
  endif()

  #[===========================================================================[
    The `PROJECT_NAME_UPPER` variable is using to set other global variables.
    Let's say we have a project called 'my-project' and we'd like to set
    variables such as `MY_PROJECT_ENABLE_TESTING`. Then we can write more
    generalized code using `${PROJECT_NAME_UPPER}_ENABLE_TESTING` instead.
  #]===========================================================================]
  string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
  string(REGEX REPLACE "[- ]" "_" PROJECT_NAME_UPPER ${PROJECT_NAME_UPPER})

  # The lowercase variant, e.g. for common targets to prevent target clashes
  string(TOLOWER ${PROJECT_NAME} project_name_lower)
  string(REGEX REPLACE "[- ]" "_" project_name_lower ${project_name_lower})

  #[===========================================================================[
    Allow to install all external dependencies locally (e.g. using
    `FetchContent`, or `ExternalProject` and downloading external sources into
    the binary directory), except to those that is not allowed explicitly
    by setting `${PROJECT_NAME_UPPER}_INSTALL_<dependency-name>_LOCALLY`.
    `<dependency-name>` is just a name using by the `find_package` command.
  #]===========================================================================]
  project_option(INSTALL_EXTERNALS_LOCALLY
    "Install external dependencies locally"
    OFF
  )

  #[===========================================================================[
    Modules that should be located using the `${CMAKE_MODULE_PATH}` list, e.g.
    `Find<package>.cmake` to use the `find_package(<package>)` command.
  #]===========================================================================]
  list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/modules")

  # And this guard should be at the end
  no_in_source_builds_guard()
endmacro()


#################################### Guards ####################################

# Prevent including any listfiles before the `project` command
function(after_project_guard)
  if (NOT (PROJECT_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR))
    get_filename_component(file_name "${CMAKE_CURRENT_LIST_FILE}" NAME)
    message(FATAL_ERROR
      "\n"
      "'${file_name}' must be included in the current listfile after the `project` command.\n"
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
      "Windows (PowerShell): Remove-Item CMakeFiles, CMakeCache.txt, cmake_install.cmake -force -recurse\n"
      "Windows (Command Prompt): rmdir CMakeFiles /s /q && del /q CMakeCache.txt cmake_install.cmake\n"
      "NOTE: Build generator files may also remain, that is, 'Makefile', 'build.ninja' and so forth.\n"
    )
  endif()
endmacro()


##################### Project related functions and macros #####################

#[=============================================================================[
  Include the `${module}.cmake` file located in the `cmake` directory of
  the current project. It let us include cmake-files by name, preventing
  name collisions by using `include(${module})` when a module with
  the same name is defined in the outer score, e.g. the outer project
  sets its own `CMAKE_MODULE_PATH`.
#]=============================================================================]
macro(include_project_module module)
  include("${PROJECT_SOURCE_DIR}/cmake/${module}.cmake")
endmacro()

# Enable the rest of a listfile if the project variable is set
macro(enable_if_project_variable_is_set suffix)
  if (NOT ${PROJECT_NAME_UPPER}_${suffix})
    return()
  endif()
endmacro()

#[=============================================================================[
  Set an option named `${PROJECT_NAME_UPPER}_${name}` if there is no such
  normal or cached variable set before. This prefix `${PROJECT_NAME_UPPER}` is
  added in order to prevent name clashes with outer project options. Other
  parameters of the `option` command are passed after the `name` parameter.
  Also define a variable named `${name}` by assigning the option's boolean
  value to this variable.
#]=============================================================================]
macro(project_option name)
  option(${PROJECT_NAME_UPPER}_${name} ${ARGN})
  set(${name} ${${PROJECT_NAME_UPPER}_${name}})
endmacro()

#[=============================================================================[
  Add a library target called `${project_name_lower}_${target_alias}`, but also
  set a variable `${target_alias}` to the target name to use this variable as
  a short alias. The main goal of this macro is to prevent name clashes between
  targets if this project will be used as an embedded project, e.g. using the
  `add_subdirectory` command. All parameters of the `add_library` command are
  passed after `target_alias`.
#]=============================================================================]
macro(add_project_library target_alias)
  set(${target_alias} ${project_name_lower}_${target_alias})
  add_library(${${target_alias}} ${ARGN})
endmacro()

#[=============================================================================[
  Add an executable target called `${project_name_lower}_${target_alias}`, but
  also set a variable `${target_alias}` to the target name to use this variable
  as a short alias. The main goal of this macro is to prevent name clashes between
  targets if this project will be used as an embedded project, e.g. using the
  `add_subdirectory` command. All parameters of the `add_executable` command are
  passed after `target_alias`.
#]=============================================================================]
macro(add_project_executable target_alias)
  set(${target_alias} ${project_name_lower}_${target_alias})
  add_executable(${${target_alias}} ${ARGN})
endmacro()


############################ Dependency management #############################

# Check if `dependency_name` can be installed locally
function(can_install_locally dependency_name)
  if (DEFINED ${PROJECT_NAME_UPPER}_INSTALL_${dependency_name}_LOCALLY)
    set(allowed ${${PROJECT_NAME_UPPER}_INSTALL_${dependency_name}_LOCALLY})
  else()
    set(allowed ${${PROJECT_NAME_UPPER}_INSTALL_EXTERNALS_LOCALLY})
  endif()

  if (NOT allowed)
    message(FATAL_ERROR
      "\n"
      "'${dependency_name}' is not allowed to install locally.\n"
      "Pass `-D${PROJECT_NAME_UPPER}_INSTALL_${dependency_name}_LOCALLY=ON` if you want otherwise.\n"
      "Passing `-D${PROJECT_NAME_UPPER}_INSTALL_EXTERNALS_LOCALLY=ON` allows that for all of the external dependencies, except for those that are already set to `OFF`.\n"
    )
  endif()
endfunction()


#################### `print` macros for debugging purposes #####################

macro(print text)
  message(STATUS "--> ${text}")
endmacro()

macro(print_var variable)
  message(STATUS "--> ${variable} = \"${${variable}}\"")
endmacro()

macro(print_var_with variable hint)
  message(STATUS "--> ${hint}: ${variable} = \"${${variable}}\"")
endmacro()


init_common()
