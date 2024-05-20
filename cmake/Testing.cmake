include_guard(GLOBAL)
after_project_guard()


enable_if_project_variable_is_set(ENABLE_TESTING)

enable_testing()

# TODO: find or fetch GTest

add_subdirectory(tests)
