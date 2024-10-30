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
#[=============================================================================[
  Generation the FCM's documentation
#]=============================================================================]

find_package(Python3 REQUIRED)

file(GLOB_RECURSE cmake_modules LIST_DIRECTORIES false
  "${TEST_FCM_ROOT_DIR}/*.cmake"
  "${TEST_FCM_ROOT_DIR}/*.cmake.in"
)
list(FILTER cmake_modules EXCLUDE REGEX "^${TEST_FCM_ROOT_DIR}/__tests__")

set(wiki_repository "flexible-cmake-modules.wiki")
file(TO_NATIVE_PATH "${PROJECT_BINARY_DIR}/${wiki_repository}" wiki_native_path)

foreach (module_path IN LISTS cmake_modules)
  file(RELATIVE_PATH module_name "${TEST_FCM_ROOT_DIR}" "${module_path}")
  file(TO_NATIVE_PATH "${module_path}" module_native_path)
  add_test(NAME docs.${module_name}
    COMMAND ${Python3_EXECUTABLE} "${CMAKE_CURRENT_SOURCE_DIR}/generate.py"
      "${wiki_native_path}" "${module_native_path}"
  )
endforeach()

if (CMAKE_VERSION VERSION_LESS "3.17")
  set(remove_command "remove_directory")
else()
  set(remove_command "rm" "-rf")
endif()

cmake_host_system_information(RESULT nproc QUERY "NUMBER_OF_LOGICAL_CORES")

add_custom_target(docs
  COMMAND ${CMAKE_COMMAND} -E ${remove_command} ${wiki_native_path}
  COMMAND ${GIT_EXECUTABLE} clone
    https://github.com/tsayukov/${wiki_repository}.git
    ${wiki_native_path}
  COMMAND ${CMAKE_COMMAND} -E copy
    ${CMAKE_CURRENT_SOURCE_DIR}/Home.md
    ${wiki_native_path}/
  COMMAND ${CMAKE_CTEST_COMMAND} -j${nproc} -R docs.*
  WORKING_DIRECTORY "${PROJECT_BINARY_DIR}"
)
