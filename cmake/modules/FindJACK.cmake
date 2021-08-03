#[=======================================================================[.rst:
FindJACK
--------

Finds the JACK Audio Connection Kit library.

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following imported targets, if found:

``JACK::jack``
  The JACK library

Result Variables
^^^^^^^^^^^^^^^^

This will define the following variables:

``JACK_FOUND``
  True if the system has the JACK library.
``JACK_INCLUDE_DIRS``
  Include directories needed to use JACK.
``JACK_LINK_LIBRARIES``
  Libraries needed to link to JACK.

Cache Variables
^^^^^^^^^^^^^^^

The following cache variables may also be set:

``JACK_INCLUDE_DIRS``
  The directory containing ``jack.h``.
``JACK_LINK_LIBRARIES``
  The path to the JACK library.

#]=======================================================================]

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(JACK jack)
else()
  find_path(JACK_INCLUDE_DIRS
    NAMES jack/jack.h
    DOC "JACK include directory"
  )
  find_library(JACK_LINK_LIBRARIES
    NAMES jack
    DOC "JACK library"
  )

  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(
    JACK
    DEFAULT_MSG
    JACK_LINK_LIBRARIES
    JACK_INCLUDE_DIRS
  )
endif()

mark_as_advanced(JACK_LINK_LIBRARIES)
mark_as_advanced(JACK_INCLUDE_DIRS)

if(JACK_FOUND AND NOT TARGET JACK::jack)
  add_library(JACK::jack INTERFACE IMPORTED)
  target_link_libraries(JACK::jack INTERFACE "${JACK_LINK_LIBRARIES}")
  target_include_directories(JACK::jack INTERFACE "${JACK_INCLUDE_DIRS}")
endif()
