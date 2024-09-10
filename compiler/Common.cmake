#[=============================================================================[
  Author: Pavel Tsayukov
  Distributed under the MIT License. See accompanying file LICENSE or
  https://opensource.org/license/mit for details.
  ------------------------------------------------------------------------------
  Define commands, variables, and targets to work with enabled languages
  ------------------------------------------------------------------------------
  Commands for language `${lang}` (e.g. `c`, `cxx`, in lower case):
  - Common commands:
    - get_${lang}_compiler_version
  - C/C++ standard:
    - use_${lang}_standard_at_least
  - C/C++ extensions toggle:
    - enable_${lang}_extensions
    - disable_${lang}_extensions
  - Interface C/C++ library (use `target_link_libraries` to link against them):
    - ${namespace}_${lang}_standard
  - Normal variables as lists (use `target_compile_options` to include them):
    - CXX_OPTIONS
    - CXX_WARNING_OPTIONS
    - CXX_ERROR_OPTIONS
    - CXX_LANGUAGE_OPTIONS
    - CXX_DIAGNOSTIC_OPTIONS

  Usage:

  # File: CMakeLists.txt
    cmake_minimum_required(VERSION 3.14 FATAL_ERROR)
    project(my_project_name CXX) # enable C++ language

    include("${PROJECT_SOURCE_DIR}/cmake/Common.cmake")
    no_in_source_builds_guard()

    use_cxx_standard_at_least(20)
    disable_cxx_extensions()

    add_subdirectory(externals)

    add_project_library(my_library)
    project_target_link_libraries(my_library
      PUBLIC
        my_project_name::cxx_standard
    )
    project_target_compile_options(my_library
      PRIVATE
        ${CXX_OPTIONS}
    )
    # other target commands

  # File: externals/CMakeLists.txt
    no_in_source_builds_guard()

    use_cxx_standard_at_least(17) # okay
    # include an external library that requires at least the standard C++17

    use_cxx_standard_at_least(20) # okay
    # include an external library that requires at least the standard C++20

    use_cxx_standard_at_least(23) # error!
    # include an external library that requires at least the standard C++23

  Setting `CMAKE_CXX_STANDARD` to `23` before the first calling of the
  `use_cxx_standard_at_least` command can eliminate that error, but probably
  this is not what you want. If an external library your project depends on
  requires at least the standard C++23, your project should require the same.

  Still, toggling between different `CMAKE_CXX_STANDARD` for different builds is
  a good way to test your project against different standard, no less than the
  least required.
#]=============================================================================]

include_guard(GLOBAL)
__variable_init_guard()


# For internal use: this macro must be called at the end of the current listfile.
# It defines commands and variables to work with enabled languages.
macro(__init_compiler_common)
  include_project_module(dependencies/Ccache)

  get_property(__languages GLOBAL PROPERTY ENABLED_LANGUAGES)
  foreach (__lang IN LISTS __languages)
    string(TOUPPER "${__lang}" __LANG)
    string(TOLOWER "${__lang}" __lang)

    __include_compiler_commands(${__lang} ${__LANG})
    __include_compiler_options(${__lang} ${__LANG})

    if (ENABLE_CCACHE)
      use_ccache(${__LANG})
    endif()
  endforeach()
endmacro()


# For internal use: define common commands to work with `${lang}` compiler
macro(__include_compiler_commands lang LANG)
  ############################# Common commands ################################

  #[===========================================================================[
    Helper function for optional getting the major, minor, or/and patch version
    of `${compiler_id}` that has to be the current `${LANG}` compiler.
    Raise an error if there is no such `${compiler_id}`.

      # E.g. `${lang}` is `cxx`
      get_cxx_compiler_version(<compiler_id> [MAJOR] [MINOR] [PATCH])

    Set a variable called by `${compiler_id}_(major|minor|patch)_version` in
    a parent scope.

    See supported compilers: https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER_ID.html
    See supported languages: https://cmake.org/cmake/help/latest/command/project.html
  #]===========================================================================]
  function(get_${lang}_compiler_version compiler_id)
    __compact_parse_arguments(__start_with 1
      __options MAJOR MINOR PATCH
    )

    if (NOT CMAKE_${LANG}_COMPILER_ID STREQUAL "${compiler_id}")
      message(FATAL_ERROR
        "${compiler_id} is either a wrong name or not the current ${LANG} compiler. "
        "Hint: the current ${LANG} compiler is \"${CMAKE_${LANG}_COMPILER_ID}\"."
      )
    endif()

    string(REPLACE "." ";" compiler_version_list "${CMAKE_${LANG}_COMPILER_VERSION}")
    list(LENGTH compiler_version_list size)

    if (ARGS_MAJOR AND (size GREATER_EQUAL "1"))
      list(GET compiler_version_list 0 compiler_major_version)
      set(${compiler_id}_major_version "${compiler_major_version}" PARENT_SCOPE)
    endif()

    if (ARGS_MINOR AND (size GREATER_EQUAL "2"))
      list(GET compiler_version_list 1 compiler_minor_version)
      set(${compiler_id}_minor_version "${compiler_minor_version}" PARENT_SCOPE)
    endif()

    if (ARGS_PATCH AND (size GREATER_EQUAL "3"))
      list(GET compiler_version_list 2 compiler_patch_version)
      set(${compiler_id}_patch_version "${compiler_patch_version}" PARENT_SCOPE)
    endif()
  endfunction()

  ############################ Only C/C++ support ##############################

  if ("${LANG}" MATCHES "^C(XX)?$")
    ############################# C/C++ standard ###############################

    #[=========================================================================[
      Check if `CMAKE_${LANG}_STANDARD` is set to at least `${standard}` and
      in the very first call define the `${namespace}_${lang}_standard` target
      as an interface library with the standard set to the maximum of
      `${CMAKE_${LANG}_STANDARD}` and `${standard}`, which other targets can
      link against. `${namespace}_${lang}_standard` should be treated as
      a target with the least supported standard of this library.

      If `CMAKE_${LANG}_STANDARD` is not defined, the first call of the function
      set its compile feature to `${lang}_std_${standard}`.

      The first time this function should be called in the current project's
      root listfile to define `${namespace}_${lang}_standard`.
      If there's no such call, but `CMAKE_${LANG}_STANDARD` is defined,
      the `${namespace}_${lang}_standard` target will have the standard that is
      set in `CMAKE_${LANG}_STANDARD`.
      If there's no such call and `CMAKE_${LANG}_STANDARD` is not defined,
      then this function is no-op.

      Use next calls of this function to check if some dependency's requirement
      is not greater than the standard in `${namespace}_${lang}_standard`.
    #]=========================================================================]
    function(use_${lang}_standard_at_least standard)
      if (NOT DEFINED CMAKE_${LANG}_STANDARD)
        if (CMAKE_CURRENT_SOURCE_DIR STREQUAL PROJECT_SOURCE_DIR)
          set(CMAKE_${LANG}_STANDARD ${standard})
          set(CMAKE_${LANG}_STANDARD ${standard} PARENT_SCOPE)
        else()
          return()
        endif()
      endif()

      __compact_parse_arguments(__start_with 1
        __values NAME
      )

      __check_standard_consistency(${LANG} ${standard} NAME "${ARGS_NAME}")

      set(target_suffix ${lang}_standard)
      set(target ${namespace}_${target_suffix})
      if (NOT TARGET ${target})
        add_project_library(${target_suffix} INTERFACE)
        project_target_compile_features(${target_suffix}
          INTERFACE
            ${lang}_std_${CMAKE_${LANG}_STANDARD}
        )
        set(CMAKE_${LANG}_STANDARD_REQUIRED ON PARENT_SCOPE)
      endif()
    endfunction()


    ######################### C/C++ extensions toggle ##########################

    function(enable_${lang}_extensions)
      if (TARGET ${namespace}_${lang}_standard)
        set_target_properties(${namespace}_${lang}_standard
          PROPERTIES
            ${LANG}_EXTENSIONS ON
        )
      endif()
      set(CMAKE_${LANG}_EXTENSIONS ON PARENT_SCOPE)
    endfunction()

    function(disable_${lang}_extensions)
      if (TARGET ${namespace}_${lang}_standard)
        set_target_properties(${namespace}_${lang}_standard
          PROPERTIES
            ${LANG}_EXTENSIONS OFF
        )
      endif()
      set(CMAKE_${LANG}_EXTENSIONS OFF PARENT_SCOPE)
    endfunction()

  endif("${LANG}" MATCHES "^C(XX)?$")

endmacro()

# For internal use. Helper comparison of C/C++ standards.
function(__compare_standards lhs rhs)
  if (NOT lhs MATCHES "^9[0-9]$")
    set(lhs ${lhs}00)
  endif()
  if (NOT rhs MATCHES "^9[0-9]$")
    set(rhs ${rhs}00)
  endif()

  if (lhs LESS rhs)
    set(result "LESS")
  elseif (lhs GREATER rhs)
    set(result "GREATER")
  else() # lhs EQUAL rhs
    set(result "EQUAL")
  endif()

  set(__compare_standards_result ${result} PARENT_SCOPE)
endfunction()

# For internal use. Helper processor of `${LANG}` standards consistency.
function(__check_standard_consistency LANG required_standard)
  __compact_parse_arguments(__start_with 1
    __values NAME
  )

  __compare_standards(${required_standard} ${CMAKE_${LANG}_STANDARD})
  if (NOT __compare_standards_result STREQUAL "GREATER")
    return()
  endif()

  if (CMAKE_CURRENT_LIST_DIR STREQUAL PROJECT_SOURCE_DIR)
    message(FATAL_ERROR
      "The project \"${PROJECT_NAME}\" requires at least "
      "the ${LANG} standard ${required_standard}, "
      "but CMAKE_${LANG}_STANDARD is set to ${CMAKE_${LANG}_STANDARD}."
    )
  else()
    if (ARGS_NAME)
      set(depended_part_name "\"${ARGS_NAME}\"")
    else()
      file(RELATIVE_PATH relative_file_path "${PROJECT_SOURCE_DIR}"
        "${CMAKE_CURRENT_LIST_FILE}"
      )
      set(depended_part_name "defined in \"${relative_file_path}\"")
    endif()

    message(FATAL_ERROR
      "The project \"${PROJECT_NAME}\" is built against "
      "the ${LANG} standard ${CMAKE_${LANG}_STANDARD}, "
      "but its dependent part ${depended_part_name} "
      "requires at least ${required_standard}."
    )
  endif()
endfunction()

macro(__include_compiler_options lang LANG)
  if (ENABLE_EXPORT_HEADER)
    # See: https://cmake.org/cmake/help/latest/prop_tgt/VISIBILITY_INLINES_HIDDEN.html
    set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)
    if ("${LANG}" MATCHES "^C(XX)?$")
      # See: https://cmake.org/cmake/help/latest/prop_tgt/LANG_VISIBILITY_PRESET.html
      set(CMAKE_${LANG}_VISIBILITY_PRESET "hidden")
    endif()
  endif()

  # So far, support only C++ options
  if ("${LANG}" STREQUAL "CXX")
    include_project_module(compiler/CxxOptions)
  endif()

  # TODO: add C options support
endmacro()


########################### The end of the listfile ############################

__init_compiler_common()
