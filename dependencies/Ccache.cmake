#[=============================================================================[
  Author: Pavel Tsayukov
  Distributed under the MIT License. See accompanying file LICENSE or
  https://opensource.org/license/mit for details.
  ------------------------------------------------------------------------------
  Ccache support for fast recompilation
  ------------------------------------------------------------------------------
  Enable the `${NAMESPACE}_ENABLE_CCACHE` project option to turn ccache on.
  See `../Variables.cmake` for details.

  See supported languages:
  - https://ccache.dev/
  - https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER_LAUNCHER.html
  ------------------------------------------------------------------------------
  Commands:
  - use_ccache
  Init commands:
  - init_ccache
#]=============================================================================]

include_guard(GLOBAL)


enable_if(ENABLE_CCACHE)

macro(init_ccache)
  find_program(CCACHE_PATH ccache)
  mark_as_advanced(CCACHE_PATH)
  __enable_if_ccache_is_found()
endmacro()

# Set `CMAKE_${LANG}_COMPILER_LAUNCHER` if `ccache` is found and supports `${LANG}
function(use_ccache LANG)
  if (NOT LANG MATCHES "^((OBJ)?C(XX)?|ASM.*|CUDA)$")
    message(AUTHOR_WARNING "${LANG} is not supported by ccache.")
    return()
  endif()

  __enable_if_ccache_is_found()
  set(CMAKE_${LANG}_COMPILER_LAUNCHER
    "${CCACHE_PATH}" CACHE FILEPATH "${LANG} compiler launcher" FORCE
  )
endfunction()

function(__enable_if_ccache_is_found)
  if (NOT CCACHE_PATH)
    message(AUTHOR_WARNING
      "Ccache is not found, that will may increase the re-compilation time. "
      "Pass `-DCCACHE_PATH=path/to/bin` to specify the path to the `ccache` "
      "binary file."
    )
    return()
  endif()
endfunction()


############################# The end of the file ##############################

init_ccache()
