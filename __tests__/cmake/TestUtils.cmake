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
  Helper commands for testing CMake modules
#]=============================================================================]

include_guard(GLOBAL)


function(test_add_cmake_module_test)
  # TODO: impl
endfunction()

macro(test_internal_include_template)
  # TODO: impl
endmacro()

macro(test_enable_catch_fatal_error)
  set(__FCM_DEBUG_CATCH_FATAL_ERROR__ "__FCM_DEBUG_CATCH_FATAL_ERROR__")
endmacro()

function(test_push_error_message
  text
)
  set_property(DIRECTORY
      "${PROJECT_SOURCE_DIR}"
    PROPERTY
      TEST_FCM_ERROR_MESSAGE "${text}"
  )
endfunction()

macro(test_pop_error_message
  output_variable
)
  get_property(${output_variable}
    DIRECTORY "${PROJECT_SOURCE_DIR}"
    PROPERTY TEST_FCM_ERROR_MESSAGE
  )
  set_property(DIRECTORY
      "${PROJECT_SOURCE_DIR}"
    PROPERTY
      TEST_FCM_ERROR_MESSAGE ""
  )
endmacro()

macro(message)
  if ("${ARGC}" GREATER "2")
    if ("${ARGV0}" STREQUAL "FATAL_ERROR"
          AND "${ARGV1}" STREQUAL "__FCM_DEBUG_CATCH_FATAL_ERROR__")
      set(__ARGV ${ARGV})
      list(SUBLIST __ARGV 2 -1 __ARGV)
      list(JOIN __ARGV "" __ARGV)
      test_push_error_message("${__ARGV}")
      unset(__ARGV)
    else()
      _message(${ARGV})
    endif()
  else()
    _message(${ARGV})
  endif()
endmacro()

################################ Init variables ################################

# TODO: impl
