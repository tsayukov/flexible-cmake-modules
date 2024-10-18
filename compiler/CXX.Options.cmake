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
  Semicolon lists with C++ compiler's options
#]=============================================================================]

include_guard(GLOBAL)


if (MSVC)
  include(compiler/Msvc.CXX.Options)
else()
  include(compiler/Gnu.CXX.Options)
endif()

set(CXX_OPTIONS
  ${CXX_WARNING_OPTIONS}
  ${CXX_LANGUAGE_OPTIONS}
  ${CXX_DIAGNOSTIC_OPTIONS}
)
