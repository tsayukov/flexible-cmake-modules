#[=============================================================================[
  Author: Pavel Tsayukov
  Distributed under the MIT License. See accompanying file LICENSE or
  https://opensource.org/license/mit for details.
  ------------------------------------------------------------------------------
  Python virtual environment creation (3.15+)
  ------------------------------------------------------------------------------
  Enable the `${NAMESPACE}_ENABLE_PYTHON_VENV` project option to turn this
  module on. Then find and create, if needed, Python virtual environment in
  `${${NAMESPACE}_PYTHON_VENV_DIR}`. See `../Variables.cmake` for details.

  Commands:
    - find_or_init_python_venv
    - pip2_install
    - pip3_install

#]=============================================================================]

include_guard(GLOBAL)


enable_if_project_variable_is_set(ENABLE_PYTHON_VENV)
requires_cmake(3.15 "Using `*_FIND_VIRTUALENV` in FindPython2 or FindPython3 modules")

#[=============================================================================[
  Try to find Python virtual environment in `${PYTHON_VENV_DIR}`. If there's no
  any, find Python and create its virtual environment. By default, use Python 3
  that was found by `find_package`. Otherwise, pass the specific version:

    find_or_init_python_venv([<version>] [<other find_package parameters>...])

  While passing parameters to this command, Python version must be the first
  one, otherwise, an error will be raised.
#]=============================================================================]
macro(find_or_init_python_venv)
  if ("${ARGC}" EQUAL "0")
    __find_or_init_python_venv_impl(Python3 REQUIRED ${ARGN})
  elseif ("${ARGV0}" MATCHES "^3")
    __find_or_init_python_venv_impl(Python3 REQUIRED ${ARGN})
  elseif ("${ARGV0}" MATCHES "^2")
    __find_or_init_python_venv_impl(Python2 REQUIRED ${ARGN})
  else()
    message(FATAL_ERROR "Python version must be the first parameter.")
  endif()
endmacro()

function(pip2_install)
  execute_process(COMMAND ${Python2_EXECUTABLE} -m pip install ${ARGN})
endfunction()

function(pip3_install)
  execute_process(COMMAND ${Python3_EXECUTABLE} -m pip install ${ARGN})
endfunction()


################################ Implementation ################################

function(__init_virtual_env_variable)
  file(TO_NATIVE_PATH "${PYTHON_VENV_DIR}" python_venv_native_path)
  # Mimic the `bin/activate` script to help `find_package` find the venv
  # See: https://docs.python.org/3/library/venv.html#how-venvs-work
  set(ENV{VIRTUAL_ENV} "${python_venv_native_path}")
endfunction()

macro(__find_or_init_python_venv_impl)
  if (("${ARGC}" EQUAL "0") OR (NOT "${ARGV0}" MATCHES "^Python(2|3)$"))
    message(FATAL_ERROR "Missing \"Python2\" or \"Python3\" argument!")
  endif()

  __init_virtual_env_variable()
  find_package(${ARGN})

  if (NOT ${ARGV0}_EXECUTABLE MATCHES "^$ENV{VIRTUAL_ENV}/")
    message(STATUS "Creating ${ARGV0} virtual environment in \"$ENV{VIRTUAL_ENV}\"")
    execute_process(COMMAND
        ${${ARGV0}_EXECUTABLE} -m venv "$ENV{VIRTUAL_ENV}"
      WORKING_DIRECTORY
        "${benchmark_compare_py}"
    )
    message(STATUS "Creating ${ARGV0} virtual environment in \"$ENV{VIRTUAL_ENV}\" - done")

    # Force `find_package` to run another search
    unset(${ARGV0}_EXECUTABLE)

    # Change the context of search
    # See: https://cmake.org/cmake/help/latest/module/FindPython2.html
    # See: https://cmake.org/cmake/help/latest/module/FindPython3.html
    set(${ARGV0}_FIND_VIRTUALENV "FIRST")

    find_package(${ARGN})
    if (NOT ${ARGV0}_EXECUTABLE MATCHES "^$ENV{VIRTUAL_ENV}/")
      message(FATAL_ERROR "${ARGV0} virtual environment is not found!")
    endif()
  endif()

  message(STATUS "Found ${ARGV0} (venv): ${${ARGV0}_EXECUTABLE}")
endmacro()
