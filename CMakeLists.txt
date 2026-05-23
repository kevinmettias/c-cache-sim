cmake_minimum_required(VERSION 3.20)

project(c_cache_sim C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(ENABLE_COVERAGE "Build with gcov/lcov coverage instrumentation" OFF)

find_package(cmocka CONFIG QUIET)
if(cmocka_FOUND)
    if(TARGET cmocka::cmocka)
        set(CMOCKA_TARGET cmocka::cmocka)
    else()
        set(CMOCKA_TARGET cmocka)
    endif()
else()
    find_library(CMOCKA_TARGET cmocka REQUIRED)
endif()

add_library(cache_sim_core
    src/cache_sim.c
    src/trace.c
    src/workloads.c
)

target_include_directories(cache_sim_core PUBLIC include)

if(MSVC)
    target_compile_options(cache_sim_core PRIVATE /W4 /WX)
else()
    target_compile_options(cache_sim_core PRIVATE -Wall -Wextra -Wpedantic -Werror)
endif()

if(ENABLE_COVERAGE)
    if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
        target_compile_options(cache_sim_core PRIVATE --coverage -O0 -g)
        target_link_options(cache_sim_core PUBLIC --coverage)
    else()
        message(FATAL_ERROR "ENABLE_COVERAGE requires GCC or Clang")
    endif()
endif()

add_executable(cache-sim src/main.c)
target_link_libraries(cache-sim PRIVATE cache_sim_core)

enable_testing()

add_executable(test_cache_sim tests/test_cache_sim.c)
target_link_libraries(test_cache_sim PRIVATE cache_sim_core ${CMOCKA_TARGET})
add_test(NAME test_cache_sim COMMAND test_cache_sim)

add_executable(test_trace tests/test_trace.c)
target_link_libraries(test_trace PRIVATE cache_sim_core ${CMOCKA_TARGET})
add_test(NAME test_trace COMMAND test_trace)
