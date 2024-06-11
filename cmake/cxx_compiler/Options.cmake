include_guard(GLOBAL)


if (MSVC)
  include_project_module(cxx_compiler/Msvc.Options)
else()
  include_project_module(cxx_compiler/Gnu.Options)
endif()
