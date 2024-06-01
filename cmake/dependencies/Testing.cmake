include_guard(GLOBAL)
after_project_guard()
cxx_standard_guard()


enable_if_project_variable_is_set(ENABLE_TESTING)

enable_testing()

#[=============================================================================[
  TODO(?): specify other testing library if you want so.
  Otherwise, you may also want to specify a particular version of GTest
  in the `find_package(GTest <version>)` command and use other URL
  in the `FetchContent_Declare()` command.
#]=============================================================================]

use_cxx_standard_at_least(14)

find_package(GTest)
if (NOT GTest_FOUND)
  can_install_locally(GTest)
  include(FetchContent)
  FetchContent_Declare(
    GTest
    URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
  )

  if (CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    # Prevent overriding the parent project's compiler/linker settings
    set(gtest_force_shared_crt ON)
  endif()

  set(INSTALL_GTEST OFF)

  # TODO(?): set `ON` if testing your project uses GMock
  set(BUILD_GMOCK OFF)

  FetchContent_MakeAvailable(GTest)
endif()

# Get the `gtest_add_tests()` and `gtest_discover_tests()` command
include(GoogleTest)

add_subdirectory(tests)
