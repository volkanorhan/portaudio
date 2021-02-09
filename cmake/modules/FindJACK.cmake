#[=======================================================================[.rst:
FindJACK
--------

Finds the JACK Audio Connection Kit library.

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following imported targets, if found:

``JACK::jack``
  The JACK library

#]=======================================================================]

# Prefer finding the libraries from pkgconfig rather than find_library. This is
# required to build with PipeWire's reimplementation of the JACK library.
#
# This also enables using PortAudio with the jack2 port in vcpkg. That only
# builds JackWeakAPI (not the JACK server) which dynamically loads the real
# JACK library and forwards API calls to it. JackWeakAPI requires linking `dl`
# in addition to jack, as specified in the pkgconfig file in vcpkg.
find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(JACK jack)
else()
  find_library(JACK_LINK_LIBRARIES
    NAMES jack
    DOC "JACK library"
  )
  find_path(JACK_INCLUDEDIR
    NAMES jack/jack.h
    DOC "JACK header"
  )
endif()

# Check for the POSIX headers #include'd by pa_jack.c. This prevents a build
# failure when cross compiling from Linux to Windows with MinGW if the Linux
# host has JACK installed but MinGW does not provide all the required POSIX
# headers. Check for REGEX_H here to avoid printing "Looking for POSIX headers"
# when reconfiguring CMake.
if(NOT REGEX_H AND JACK_LINK_LIBRARIES AND JACK_INCLUDEDIR)
  message(STATUS "Looking for POSIX headers")
  include(CheckIncludeFile)
  check_include_file(string.h STRING_H)
  check_include_file(regex.h REGEX_H)
  check_include_file(stdlib.h STDLIB_H)
  check_include_file(stdio.h STDIO_H)
  check_include_file(assert.h ASSERT_H)
  check_include_file(sys/types.h TYPES_H)
  check_include_file(unistd.h UNISTD_H)
  check_include_file(errno.h ERRNO_H)
  check_include_file(signal.h SIGNAL_H)
  check_include_file(math.h MATH_H)
  check_include_file(semaphore.h SEMAPHOR_H)
  if(
    NOT STRING_H OR
    NOT REGEX_H OR
    NOT STDLIB_H OR
    NOT STDIO_H OR
    NOT ASSERT_H OR
    NOT TYPES_H OR
    NOT UNISTD_H OR
    NOT ERRNO_H OR
    NOT SIGNAL_H OR
    NOT MATH_H OR
    NOT SEMAPHOR_H)
    message(STATUS "POSIX headers not found. Unable to build JACK host API.")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  JACK
  DEFAULT_MSG
  JACK_LINK_LIBRARIES
  JACK_INCLUDEDIR
  STRING_H
  REGEX_H
  STDLIB_H
  STDIO_H
  ASSERT_H
  TYPES_H
  UNISTD_H
  ERRNO_H
  SIGNAL_H
  MATH_H
  SEMAPHOR_H
)

if(JACK_FOUND AND NOT TARGET JACK::jack)
  add_library(JACK::jack INTERFACE IMPORTED)
  target_link_libraries(JACK::jack INTERFACE "${JACK_LINK_LIBRARIES}")
  target_include_directories(JACK::jack INTERFACE "${JACK_INCLUDEDIR}")
endif()
