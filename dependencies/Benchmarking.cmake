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


enable_if(ENABLE_BENCHMARKING)

macro(init_google_benchmark)
  use_cxx_standard_at_least(11)

  find_package(benchmark)
  set(BENCHMARK_TOOLS_HINTS "/usr/share/benchmark")
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
    list(APPEND BENCHMARK_TOOLS_HINTS "${benchmark_SOURCE_DIR}/tools")
  endif(NOT benchmark_FOUND)
endmacro()

macro(init_google_benchmark_tools)
  if (ENABLE_BENCHMARK_TOOLS)
    find_path(BENCHMARK_TOOLS
      NAMES
        "compare.py"
      HINTS
        ${BENCHMARK_TOOLS_HINTS}
    )
    mark_as_advanced(BENCHMARK_TOOLS)
    if (NOT BENCHMARK_TOOLS)
      message(FATAL_ERROR "Benchmark tools is not found.")
    endif()

    find_or_init_python_venv()
    message(STATUS "Installing google benchmark tools' dependencies")
    pip3_install(-r "${BENCHMARK_TOOLS}/requirements.txt")
    # Even though, `requirements.txt` doesn't have `pandas`, `compare.py` still requires it
    pip3_install(wheel pandas)
    message(STATUS "Installing google benchmark tools' dependencies - done")
  endif(ENABLE_BENCHMARK_TOOLS)
endmacro()


############################# The end of the file ##############################

init_google_benchmark()
init_google_benchmark_tools()
add_subdirectory(${BENCHMARK_DIR})
