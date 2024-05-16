include_guard(GLOBAL)
after_project_guard()


if (NOT ${PROJECT_NAME_UPPER}_ENABLE_TESTING)
  return()
endif()

enable_testing()

# TODO: find or fetch GTest

add_subdirectory(tests)
