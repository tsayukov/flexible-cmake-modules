# Flexible CMake Modules
# ------------------------------------------------------------------------------
# Author: Pavel Tsayukov
# Repository: https://github.com/tsayukov/flexible-cmake-modules
# Distributed under the MIT License. See the accompanying file LICENSE or
# https://opensource.org/license/mit for details.
# ------------------------------------------------------------------------------
#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# FOR COAUTHORS AND CONTRIBUTORS: fill in your name, contacts, and changes above
#
#[=================================================================[#github/wiki
  # Initialization of Flexible CMake Modules

  ## Table of Contents

  - [Usage](#Usage)
  - [Prefixes](#Prefixes)
    - [FCM_COMMAND_PREFIX_CONTROL](#FCM_COMMAND_PREFIX_CONTROL)
    - [FCM_PROJECT_COMMAND_PREFIX_CONTROL](#FCM_PROJECT_COMMAND_PREFIX_CONTROL)
    - [FCM_PROJECT_TARGET_PREFIX_CONTROL](#FCM_PROJECT_TARGET_PREFIX_CONTROL)
    - [FCM_PROJECT_CACHE_PREFIX_CONTROL](#FCM_PROJECT_CACHE_PREFIX_CONTROL)

  ## Usage

  ```cmake
  # CMakeLists.txt
  cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

  project(library-name CXX)

  include(cmake/FcmInit.cmake)
  ```

  You may adjust Flexible CMake Modules by setting control variables before
  including the `FcmInit` module. These control variables will be unset after
  the initialization, so they won't affect any sub-projects using FCM as well.
  Thus, be careful when using cached entries with the same names; they will be
  used by each `FcmInit` module if the normal variables are not defined.

  ## Prefixes

  The control variables that define a prefix for commands, targets, and cached
  entries must be set to a proper C identifier. If they are not, they will
  be forcibly [converted][1] to that identifier. Moreover, when the prefixes
  need to be read, they are checked, if they are still a proper C identifier,
  preventing execution of arbitrary code after configuring template CMake files.
  The check takes place using the `if` command, which cannot be overridden.

  An underscore will be added to each non-empty prefix. Note, that these control
  variables can be set to an empty string. It is the same if there are
  no prefixes at all. It is not allowed to remove the prefix for FCM's
  commands, because then they will override some CMake commands.

  ### FCM_COMMAND_PREFIX_CONTROL

  The `FCM_COMMAND_PREFIX_CONTROL` variable defines a prefix for FCM's commands.
  By default, its value is `fcm`. To get the prefix, call
  the [`fcm_get_command_prefix()`][9] command and use the `FCM_COMMAND_PREFIX`
  variable.

  ### FCM_PROJECT_COMMAND_PREFIX_CONTROL

  The `FCM_PROJECT_COMMAND_PREFIX_CONTROL` variable defines a prefix that
  is reserved for custom commands defined by the project's maintainers.
  By default, its value is a project name in lower case, converted to a proper
  C identifier. To get the prefix, call
  the [`fcm_get_project_command_prefix()`][10] command and use
  the `FCM_PROJECT_COMMAND_PREFIX` variable. It can be used in template CMake
  files, e.g., `*.cmake.in`, to define commands and call them:

  ```cmake
  # CustomCommands.cmake.in
  function(@FCM_PROJECT_COMMAND_PREFIX@do_work)
    # do some work
  endfunction()

  function(@FCM_PROJECT_COMMAND_PREFIX@do_more_work)
    # do more work
    @FCM_PROJECT_COMMAND_PREFIX@do_work()
  endfunction()
  ```

  These template files can be configured and included by calling the
  [`fcm_include()`][2] command.

  ### FCM_PROJECT_TARGET_PREFIX_CONTROL

  The `FCM_PROJECT_TARGET_PREFIX_CONTROL` defines a prefix for project-specific
  targets that is set by calling the [`fcm_add_library()`][3]
  and [`fcm_add_executable()`][4]  commands.
  By default, its value is a project name in lower case, converted to a proper
  C identifier. To get the prefix, call
  the [`fcm_get_project_target_prefix()`][11] command and use
  the `FCM_PROJECT_TARGET_PREFIX` variable.

  ### FCM_PROJECT_CACHE_PREFIX_CONTROL

  The `FCM_PROJECT_CACHE_PREFIX_CONTROL` defines a prefix for project-specific
  cached entries that is set by calling the [`fcm_cache_entry()`][6],
  [`fcm_option()`][7], and [`fcm_dev_option()`][8] commands. By default,
  its value is a project name in upper case, converted to a proper C identifier.
  To get the prefix, call the [`fcm_get_project_cache_prefix()`][12] command
  and use the `FCM_PROJECT_CACHE_PREFIX` variable.

  [1]: https://cmake.org/cmake/help/latest/command/string.html#make-c-identifier
  [2]: https://github.com/tsayukov/flexible-cmake-modules/wiki/fcm_include
  [3]: https://github.com/tsayukov/flexible-cmake-modules/wiki/Project-specific-commands#fcm_add_library
  [4]: https://github.com/tsayukov/flexible-cmake-modules/wiki/Project-specific-commands#fcm_add_executable
  [6]: https://github.com/tsayukov/flexible-cmake-modules/wiki/Project-specific-commands#fcm_cache_entry
  [7]: https://github.com/tsayukov/flexible-cmake-modules/wiki/Project-specific-commands#fcm_option
  [8]: https://github.com/tsayukov/flexible-cmake-modules/wiki/Project-specific-commands#fcm_dev_option
  [9]: https://github.com/tsayukov/flexible-cmake-modules/wiki/Getters-of-FCM-Configuration-Variables#fcm_get_command_prefix
  [10]: https://github.com/tsayukov/flexible-cmake-modules/wiki/Getters-of-FCM-Configuration-Variables#fcm_get_project_command_prefix
  [11]: https://github.com/tsayukov/flexible-cmake-modules/wiki/Getters-of-FCM-Configuration-Variables#fcm_get_project_target_prefix
  [12]: https://github.com/tsayukov/flexible-cmake-modules/wiki/Getters-of-FCM-Configuration-Variables#fcm_get_project_cache_prefix
#]=================================================================]#github/wiki

include_guard(DIRECTORY)


if (NOT PROJECT_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  message(FATAL_ERROR
    "Flexible CMake Modules must be included in a listfile "
    "that sets the project's name after the `project()` call."
  )
endif()


set(__FCM_VERSION__ "0")

set(__c_id_pattern "^[_A-Za-z][_0-9A-Za-z]*$")

string(MAKE_C_IDENTIFIER "${PROJECT_NAME}" __project_name_id)
string(TOLOWER "${__project_name_id}" __default_FCM_PROJECT_TARGET_PREFIX)
string(TOUPPER "${__project_name_id}" __default_FCM_PROJECT_CACHE_PREFIX)

set(__default_FCM_COMMAND_PREFIX "fcm")
set(__default_FCM_PROJECT_COMMAND_PREFIX ${__default_FCM_PROJECT_TARGET_PREFIX})

foreach (variable IN ITEMS
  FCM_COMMAND_PREFIX
  FCM_PROJECT_COMMAND_PREFIX
  FCM_PROJECT_TARGET_PREFIX
  FCM_PROJECT_CACHE_PREFIX
)
  if (DEFINED CACHE{${variable}_CONTROL})
    message(WARNING
      "Found the `${variable}_CONTROL` cached entry; "
      "make sure that Flexible CMake Modules are adjusted via the normal variable."
    )
  endif()

  if (NOT DEFINED ${variable}_CONTROL)
    set(${variable}_CONTROL "${__default_${variable}}")
  endif()

  if (NOT ${variable}_CONTROL STREQUAL "")
    string(MAKE_C_IDENTIFIER "${${variable}_CONTROL}_" __control_value_id)
    if (NOT __control_value_id MATCHES "${__c_id_pattern}")
      message(FATAL_ERROR
        "The `string()` or `set()` commands are corrupted, "
        "probably because someone overrode them !!! "
        "${variable}_CONTROL must be a proper C identifier."
      )
    endif()
  elseif ("${variable}_CONTROL" STREQUAL "FCM_COMMAND_PREFIX")
    message(FATAL_ERROR "`FCM_COMMAND_PREFIX` must be non-empty.")
  endif()

  set(__fcm_cache_dir "${PROJECT_BINARY_DIR}/FCM_cache/v${__FCM_VERSION__}")
  set(__fcm_overridden_variable_file "${__fcm_cache_dir}/override/${variable}")
  set(__fcm_variable_file "${__fcm_cache_dir}/${variable}")

  foreach (prefix IN ITEMS __fcm_overridden __fcm)
    if (EXISTS "${prefix}_variable_file")
      file(READ "${prefix}_variable_file" ${prefix}_value_id)
      if (NOT ${prefix}_value_id MATCHES "${__c_id_pattern}")
        message(FATAL_ERROR
          "${variable} is corrupted, probably because someone changed it !!! "
          "${variable} must be a proper C identifier."
        )
      endif()
      set(__does_${prefix}_variable_file_exist ON)
    else()
      set(__does_${prefix}_variable_file_exist OFF)
    endif()
  endforeach()

  if (__does_fcm_overridden_variable_file_exist)
    if (NOT __does_fcm_variable_file_exist)
      file(WRITE "${__fcm_variable_file}" "${__control_value_id}")
      message(STATUS "FCM: found overridden ${variable}: \"${__fcm_overridden_value_id}\"")
    endif()
    set(${variable} ${__fcm_overridden_value_id})
  elseif (__does_fcm_variable_file_exist)
    if (NOT __control_value_id STREQUAL __fcm_value_id)
      file(WRITE "${__fcm_variable_file}" "${__control_value_id}")
      message(STATUS "FCM: found ${variable}: \"${__control_value_id}\"")
    endif()
    set(${variable} ${__control_value_id})
  else()
    file(WRITE "${__fcm_variable_file}" "${__control_value_id}")
    message(STATUS "FCM: found default ${variable}: \"${__control_value_id}\"")
    set(${variable} ${__control_value_id})
  endif()

  unset(${variable}_CONTROL)
endforeach()


set(${FCM_PROJECT_CACHE_PREFIX}_CMAKE_MODULE_PATH
  "${CMAKE_CURRENT_LIST_DIR}"
  "${CMAKE_CURRENT_LIST_DIR}/modules"
  CACHE STRING
  "Search paths for CMake modules"
)
set(CMAKE_MODULE_PATH ${${FCM_PROJECT_CACHE_PREFIX}_CMAKE_MODULE_PATH})


file(RELATIVE_PATH __fcm_dir "${PROJECT_SOURCE_DIR}" "${CMAKE_CURRENT_LIST_DIR}")

foreach (module IN ITEMS FcmInclude Common)
  configure_file(
    "${PROJECT_SOURCE_DIR}/${__fcm_dir}/${module}.cmake.in"
    "${PROJECT_BINARY_DIR}/${__fcm_dir}/${module}.cmake"
    @ONLY
  )
  include("${PROJECT_BINARY_DIR}/${__fcm_dir}/${module}.cmake")
endforeach()
