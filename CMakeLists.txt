cmake_minimum_required(VERSION 3.10)
project(Clox C)

set(CMAKE_STANDARD 99)
set(CMAKE_STANDARD_REQUIRED ON)

include_directories(${PROJECT_SOURCE_DIR}/include)

enable_testing()

add_executable(Clox
    src/main.c
    src/debug.c
    src/chunk.c
    src/memory.c
    src/value.c
    src/vm.c
    src/scanner.c
    src/compiler.c
    src/object.c
)

add_test(NAME testExp
        COMMAND Clox ${CMAKE_SOURCE_DIR}/tests/clox/exp.txt)