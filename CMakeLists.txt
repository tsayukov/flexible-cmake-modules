# TODO(?): specify the CMake minimum version at least 3.14
cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

# TODO(?): specify your basic project properties
project(my-header-only-library
  VERSION 0.1.0
  DESCRIPTION "A brief description of the library"
  HOMEPAGE_URL "https://127.0.0.1"
  LANGUAGES CXX
)

#[=============================================================================[
  This listfile provides common macros, functions, and variables
  and must be included in this way first after the `project()` command.
  After that, use the `include_project_module` macro to include other listfiles
  related to the project.
#]=============================================================================]
include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/Common.cmake")
no_in_source_builds_guard()

include_project_module(BuildOptions)
include_project_module(CompilerOptions)

# TODO(?): set the required standard of the library
use_cxx_standard_at_least(14)
# TODO(?): disable or enable C++ extensions
disable_cxx_extensions()

include_project_module(Externals)

# TODO: add_library and friends

include_project_module(DeveloperMode)

# TODO: set package name?
include_project_module(InstallRules)
