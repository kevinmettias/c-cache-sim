# C Style Guide

This project uses a small house style intended to be reusable across future C repositories.

## Naming

Types use PascalCase with no underscores:

```c
typedef struct CacheSim CacheSim;
typedef struct CacheConfig CacheConfig;
typedef struct TraceEvent TraceEvent;
```

Functions start with a capital letter. When a type name appears in the function name, keep it exactly as the type name with no added spacing or underscores. Use underscores only for the remaining word separation:

```c
CacheSim *CacheSim_Create(CacheConfig config);
void CacheSim_Destroy(CacheSim *cache_sim);
bool CacheSim_Read(CacheSim *cache_sim, uint64_t address);
```

Each word segment in a function name starts with a capital letter:

```c
static void CacheSim_Placeholder_Test(void **state);
```

Variables use lower snake case:

```c
uint64_t line_size_bytes;
CacheSim *cache_sim;
TraceEvent trace_event;
```

Enum types use PascalCase. Enum values use the enum type as a prefix, followed by an underscore and a PascalCase value:

```c
typedef enum TraceOp {
    TraceOp_Read = 0,
    TraceOp_Write = 1
} TraceOp;
```

Preprocessor constants and include guards use upper snake case:

```c
#ifndef CACHE_SIM_H
#define CACHE_SIM_H
```

## Files

File names use lower snake case:

```text
cache_sim.c
cache_sim.h
cache_config.h
```

Public headers live in `include/`. Implementations live in `src/`. Tests live in `tests/`.

## API Shape

Prefer opaque public structs for stateful modules:

```c
typedef struct CacheSim CacheSim;
```

Keep simple value structs public when callers need to construct or inspect them directly:

```c
typedef struct CacheConfig {
    uint64_t cache_size_bytes;
    uint64_t line_size_bytes;
    uint32_t associativity;
    bool write_back;
    bool write_allocate;
} CacheConfig;
```

## Formatting Defaults

- Use C11.
- Use 4 spaces for indentation.
- Do not use tabs.
- Keep braces on the same line for functions and control flow.
- Prefer one declaration per line.
- Include standard headers before project headers only when the standard types are needed by that header.
- Keep comments sparse and useful.

## Build Expectations

All normal builds should compile with warnings enabled and warnings treated as errors:

```text
-Wall -Wextra -Wpedantic -Werror
```

For MSVC, use the equivalent project setting:

```text
/W4 /WX
```

## Tests

Use CMocka for unit tests in C projects unless there is a project-specific reason not to. Test file names should mirror the module under test:

```text
tests/test_cache_sim.c
tests/test_trace.c
```
