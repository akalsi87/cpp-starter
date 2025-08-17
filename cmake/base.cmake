# cmake/base.cmake

# --- Basic Project Setup ---
# Prevent in-source builds
if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(FATAL_ERROR "In-source builds are not allowed. Please create a build directory.")
endif()

# Set C & C++ standards
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# --- Project Options ---
option(BUILD_TESTING "Build the testing tree." ON)
option(USE_CCACHE "Use ccache if available" ON)
option(ENABLE_WARNINGS "Enable compiler warnings" ON)
option(ENABLE_WARNINGS_AS_ERRORS "Treat warnings as errors" ON)
option(ENABLE_COVERAGE "Enable code coverage flags for Debug builds" ON)

# --- Configure Build Tools ---
# Set default build type if not specified
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Choose the type of build" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# Find and enable ccache if requested
if(USE_CCACHE)
  find_program(CCACHE_PROGRAM ccache)
  if(CCACHE_PROGRAM)
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    message(STATUS "Using ccache: ${CCACHE_PROGRAM}")
  endif()
endif()

# --- Compiler Flags & Features ---
# Configure compiler warnings
if(ENABLE_WARNINGS)
  if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wsign-conversion)
    if(ENABLE_WARNINGS_AS_ERRORS)
      add_compile_options(-Werror)
    endif()
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    add_compile_options(/W4)
    if(ENABLE_WARNINGS_AS_ERRORS)
      add_compile_options(/WX)
    endif()
  endif()
endif()

# Configure build-type specific features
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  # Add sanitizers for Debug builds
  add_compile_options(-fsanitize=address,undefined -g)
  add_link_options(-fsanitize=address,undefined)

  # Add code coverage flags if enabled
  if(ENABLE_COVERAGE)
    message(STATUS "Code coverage flags enabled for Debug build.")
    add_compile_options(--coverage)
    add_link_options(--coverage)
  endif()
else()
  # Enable Link-Time Optimization (LTO) for Release builds
  include(CheckIPOSupported)
  check_ipo_supported(RESULT LTO_SUPPORTED)
  if(LTO_SUPPORTED)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
    message(STATUS "LTO/IPO enabled for release build.")
  endif()
endif()

# --- Testing Setup ---
if(BUILD_TESTING)
  find_package(GTest CONFIG REQUIRED)
  include(GoogleTest)
  enable_testing()
endif()

# --- Tooling & Installation ---
# Create a symbolic link to compile_commands.json for editor integration
if(CMAKE_EXPORT_COMPILE_COMMANDS)
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E create_symlink
    ${CMAKE_BINARY_DIR}/compile_commands.json
    ${CMAKE_SOURCE_DIR}/compile_commands.json
  )
endif()

# Default install rules for libraries
include(GNUInstallDirs)
install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

# --- Configuration Summary ---
message(STATUS "---------------------")
message(STATUS "Configuration Summary")
message(STATUS "---------------------")
message(STATUS "Build type:         ${CMAKE_BUILD_TYPE}")
message(STATUS "Build testing:      ${BUILD_TESTING}")
message(STATUS "Enable coverage:    ${ENABLE_COVERAGE}")
message(STATUS "Use ccache:         ${USE_CCACHE}")
message(STATUS "Warnings as errors: ${ENABLE_WARNINGS_AS_ERRORS}")
message(STATUS "---------------------")
