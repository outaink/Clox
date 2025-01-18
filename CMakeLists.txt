cmake_minimum_required(VERSION 3.10)
project(Clox C)

set(CMAKE_STANDARD 99)
set(CMAKE_STANDARD_REQUIRED ON)

include_directories(${PROJECT_SOURCE_DIR}/include)

add_executable(Clox
    src/main.c
    src/debug.c
    src/chunk.c
    src/memory.c
    src/value.c
    src/vm.c
)