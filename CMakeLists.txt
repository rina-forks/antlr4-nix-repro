cmake_minimum_required(VERSION 3.20)
project(Project)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(ANTLR4_JAR_LOCATION /usr/share/java/antlr-complete.jar CACHE STRING "antlr4 jar location")
find_package(antlr4-generator REQUIRED)
find_package(antlr4-runtime REQUIRED antlr4_shared)

message(STATUS "Found antlr4cpp libs: ${ANTLR4_LIB_DIR} and includes: ${ANTLR4_INCLUDE_DIR} ")

antlr4_generate(Grammar ${CMAKE_CURRENT_SOURCE_DIR}/Semantics.g4 BOTH TRUE TRUE aslt
  "${ANTLR4_TOKEN_FILES_Grammar}"
  "${ANTLR4_TOKEN_DIRECTORY_Grammar}")
message(STATUS "antlr generated include: ${ANTLR4_INCLUDE_DIR_Grammar}")

add_library(grammar STATIC "${ANTLR4_SRC_FILES_Grammar}")
target_compile_options(grammar PUBLIC -Wno-error=overloaded-virtual -Wno-overloaded-virtual) # warnings in antlr-generated code
target_include_directories(grammar PUBLIC ${PROJECT_BINARY_DIR} ${ANTLR4_INCLUDE_DIR} ${ANTLR4_INCLUDE_DIR_Grammar})

add_executable(bridge "bridge.cpp")
add_dependencies(bridge antlr4_shared)
target_link_libraries(bridge PUBLIC antlr4_shared grammar)
