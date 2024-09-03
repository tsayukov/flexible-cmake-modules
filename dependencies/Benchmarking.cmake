#[=============================================================================[
  Author: Pavel Tsayukov
  Distributed under the MIT License. See accompanying file LICENSE or
  https://opensource.org/license/mit for details.
  ------------------------------------------------------------------------------
  Benchmarking library
  ------------------------------------------------------------------------------
  Specify other benchmarking library if you want so. Otherwise, you may also
  want to specify a particular version of the google benchmark library in the
  `find_package(benchmark <version>)` command and use other GIT_TAG in the
  `FetchContent_Declare()` command.

  Enable the `${NAMESPACE}_ENABLE_DEVELOPER_MODE` or
  `${NAMESPACE}_ENABLE_BENCHMARKING` project option to turn benchmarking on.
  See `../Variables.cmake` for details.
#]=============================================================================]

include_guard(GLOBAL)
cxx_standard_guard()


enable_if_project_variable_is_set(ENABLE_BENCHMARKING)

use_cxx_standard_at_least(11)

find_package(benchmark)
if (NOT benchmark_FOUND)
  can_install_locally(benchmark)
  use_cxx_standard_at_least(14)

  include(FetchContent)
  FetchContent_Declare(
    benchmark
    GIT_REPOSITORY https://github.com/google/benchmark
    GIT_TAG a4cf155615c63e019ae549e31703bf367df5b471 # v1.8.4
  )

  set(BENCHMARK_ENABLE_INSTALL OFF)
  set(BENCHMARK_INSTALL_DOCS OFF)
  set(BENCHMARK_ENABLE_GTEST_TESTS OFF)

  FetchContent_MakeAvailable(benchmark)
endif(NOT benchmark_FOUND)

if (ENABLE_BENCHMARK_TOOLS)
  if (NOT DEFINED benchmark_SOURCE_DIR)
    set(benchmark_SOURCE_DIR "")
  endif()

  find_path(benchmark_tools
    NAMES
      "compare.py"
    HINTS
      "/usr/share/benchmark"
      "${benchmark_SOURCE_DIR}/tools"
  )
  mark_as_advanced(benchmark_tools)
  if (NOT benchmark_tools)
    message(FATAL_ERROR "Benchmark tools is not found.")
  endif()

  find_or_init_python_venv()
  pip3_install(-r "${benchmark_tools}/requirements.txt")
  # Even though, `requirements.txt` doesn't have `pandas`, `compare.py` still requires it
  pip3_install(wheel pandas)
endif(ENABLE_BENCHMARK_TOOLS)

add_subdirectory(${BENCHMARK_DIR})
