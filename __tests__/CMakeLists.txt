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
  An entry point for testing FCM
#]=============================================================================]

cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(Testing NONE)

include(cmake/TestUtils.cmake)

if (ENABLE_TESTING)
  add_subdirectory(tests)
endif()

if (ENABLE_DOCS)
  add_subdirectory(docs)
endif()
