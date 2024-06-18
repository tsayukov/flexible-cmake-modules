include_guard(GLOBAL)
after_project_guard()
no_in_source_builds_guard()
variable_init_guard()


#[=============================================================================[
  Check if `CMAKE_CXX_STANDARD` is set to at least `standard` and in the very
  first call define the `${cxx_standard}` target as an interface library with
  the corresponding standard which other targets can link against.
  The `${cxx_standard}` should be treated as the least supported standard of
  this library. The first time this macro should be called in the root listfile
  to define the `${cxx_standard}`. Use its next calls to check if some
  dependency's requirement is not greater than the `${cxx_standard}`.
#]=============================================================================]
macro(use_cxx_standard_at_least standard)
  if (NOT CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD ${standard})
  endif()

  cmake_cxx_standard_is_not_less_than(${standard})

  if (NOT TARGET ${cxx_standard})
    add_project_library(cxx_standard INTERFACE)
    target_compile_features(${cxx_standard}
      INTERFACE
        cxx_std_${CMAKE_CXX_STANDARD}
    )
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
  endif()
endmacro()

# Helper comparison
function(cmake_cxx_standard_is_not_less_than value)
  set(lhs ${CMAKE_CXX_STANDARD})
  set(rhs ${value})

  if (lhs EQUAL "98")
    set(lhs 9)
  endif()
  if (rhs EQUAL "98")
    set(rhs 9)
  endif()

  if (lhs LESS rhs)
    message(FATAL_ERROR
      "\n"
      "The library requires the C++ standard ${CMAKE_CXX_STANDARD}. Got: ${value}.\n"
    )
  endif()
endfunction()

# Raise an error if the `${cxx_standard}` target is not defined
macro(cxx_standard_guard)
  if (NOT TARGET ${cxx_standard})
    message(FATAL_ERROR
      "\n"
      "The `${cxx_standard}` target must be defined.\n"
      "Hint: call the `use_cxx_standard_at_least(<standard>)` command in the root listfile of the current library before this code has been processed.\n"
    )
  endif()
endmacro()


############################ C++ extensions toggle #############################

macro(enable_cxx_extensions)
  set_target_properties(${cxx_standard}
    PROPERTIES
      CXX_EXTENSIONS ON
  )
  set(CMAKE_CXX_EXTENSIONS ON)
endmacro()

macro(disable_cxx_extensions)
  set_target_properties(${cxx_standard}
    PROPERTIES
      CXX_EXTENSIONS OFF
  )
  set(CMAKE_CXX_EXTENSIONS OFF)
endmacro()
