include_guard(GLOBAL)
after_project_guard()


#[=============================================================================[
  Prefer that the install rules are available if the project is on the top
  level, e.g. a regular project clone, building, and installing or using
  `ExternalProject`.
  Otherwise, neither when using `add_subdirectory` nor when using `FetchContent`
  is usually expected to generate install rules.
#]=============================================================================]
if ((NOT PROJECT_IS_TOP_LEVEL) OR CMAKE_SKIP_INSTALL_RULES)
  return()
endif()

# TODO: implement install rules
