#[=============================================================================[
  Author: Pavel Tsayukov
  Distributed under the MIT License. See accompanying file LICENSE or
  https://opensource.org/license/mit for details.
  ------------------------------------------------------------------------------
  Include common variables and commands
  ------------------------------------------------------------------------------
  This module includes other submodules divided by subject:
  - Watchers of deprecated commands and normal variables,
    see `common/Watchers.cmake` for detais;
  - Guards, see `common/Guards.cmake` for details;
  - Project related commands, see `common/Project.cmake` for details;
  - Host information, see `common/HostInfo.cmake` for details;
  - Debugging, see `common/Debug.cmake` for details;

  See `Variables.cmake` to learn about existing project cached variables. That
  listfile is intended for editing existing cached variables or/and adding
  additional ones.

  Included submodules:
  - see `compiler/Common.cmake` for details;
  - see `dependencies/Common.cmake` for details;
  - see `install/Common.cmake` for details;
  - see `modules/Common.cmake` for details.

  Usage:

  # File: CMakeLists.txt
    cmake_minimum_required(VERSION 3.14 FATAL_ERROR)
    project(my_project_name CXX)

    include("${PROJECT_SOURCE_DIR}/cmake/Common.cmake")
    no_in_source_builds_guard()

    # Next, see compiler/Common.cmake usage

#]=============================================================================]

include_guard(GLOBAL)


#[=============================================================================[
  For internal use.
  This macro must be called at the end of the current listfile. It checks if the
  `project` command is already called, prevents in-source builds inside the
  'cmake' directory, and initialize some common variables, project options, and
  project cached variables.
#]=============================================================================]
macro(__init_common)
  include_project_module(common/Internal)

  # This guard should be at the beginning
  __after_project_guard()

  include_project_module(common/Watchers)
  include_project_module(common/Guards)
  include_project_module(common/Project)
  include_project_module(common/HostInfo)
  include_project_module(common/Debug)

  requires_cmake(3.14 "These modules are supported only by CMake 3.14+")

  # Init the project cached variables
  include_project_module(Variables)

  # Include other Commons after Variables
  include_project_module(compiler/Common)
  include_project_module(dependencies/Common)
  include_project_module(install/Common)
  include_project_module(modules/Common)

  # And these guards should be at the end
  no_in_source_builds_guard()
  no_in_source_builds_guard(common)
endmacro()

#[=============================================================================[
  Include the `${module}.cmake` file located in the `cmake` directory of
  the current project. It let us include listfiles by name, preventing
  name collisions by using `include(${module})` when a module with
  the same name is defined in the outer score, e.g. the outer project
  sets its own `CMAKE_MODULE_PATH`.
#]=============================================================================]
macro(include_project_module module)
  include("${PROJECT_SOURCE_DIR}/cmake/${module}.cmake")
endmacro()


########################### The end of the listfile ############################

__init_common()
