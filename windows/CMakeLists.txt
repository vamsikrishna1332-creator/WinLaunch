cmake_minimum_required(VERSION 3.14)
project(launchdesk LANGUAGES CXX)

set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/run")
set(CMAKE_BUILD_TYPE "Release" CACHE STRING "" FORCE)

set(BINARY_NAME "launchdesk")
set(APPLICATION_ID "com.yourcompany.launchdesk")

cmake_policy(VERSION 3.14...3.25)

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

# Flutter library and tool build rules.
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Application build; see runner/CMakeLists.txt.
add_subdirectory("runner")

# Generated plugin build rules, which manage building the plugins and adding
# them to the application.
include(flutter/generated_plugins.cmake)


# === Installation ===
set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")

# Make the "install" command copy the built binaries into the "run" directory.
install(CODE "
  file(REMOVE_RECURSE \"${CMAKE_INSTALL_PREFIX}/\")
  file(COPY \"${BUILD_BUNDLE_DIR}/\" DESTINATION \"${CMAKE_INSTALL_PREFIX}/\")
" COMPONENT Runtime)
