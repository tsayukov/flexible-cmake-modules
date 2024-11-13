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
  Semicolon lists with C compiler's options
#]=============================================================================]

include_guard(GLOBAL)


if (MSVC)
  include(compiler/Msvc.C.Options)
else()
  include(compiler/Gnu.C.Options)
endif()

set(C_OPTIONS
  ${C_WARNING_OPTIONS}
  ${C_LANGUAGE_OPTIONS}
  ${C_DIAGNOSTIC_OPTIONS}
)
