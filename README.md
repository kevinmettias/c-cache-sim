# c-cache-sim

A small C cache simulator project for learning cache behavior from memory traces before moving the ideas into Verilog.

## Scope

The project starts with:

- direct-mapped cache simulation
- LRU statistics and later replacement-policy comparison
- trace parsing
- hot, warm, and cold workload generation
- benchmark reports across cache designs

The starter scaffold intentionally leaves cache behavior unimplemented so the simulator logic can be built milestone by milestone.

## Style

This repo uses the C style documented in [docs/c-style-guide.md](docs/c-style-guide.md). The short version:

- types: `CacheSim`, `CacheConfig`
- functions: `CacheSim_Create()`, `CacheSim_Read()`
- variables: `cache_sim`, `line_size_bytes`
- files: `cache_sim.c`, `cache_config.h`

## Build

```sh
make
```

For CLion or CMake-based builds:

```sh
cmake -S . -B build
cmake --build build
```

## Test

Tests use CMocka.

```sh
make test
```

With CMake:

```sh
ctest --test-dir build
```

On Windows, use the MSYS2 helper scripts documented in [docs/local-dev.md](docs/local-dev.md):

```powershell
powershell -ExecutionPolicy Bypass -File scripts\local-ci.ps1
```

Additional local tooling:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\format.ps1
powershell -ExecutionPolicy Bypass -File scripts\analyze.ps1
powershell -ExecutionPolicy Bypass -File scripts\coverage.ps1
```

## Intended Trace Format

Each non-comment line is one memory operation:

```text
R 0x1000
W 0x1040
```

Addresses may be decimal or hex. Lines beginning with `#` are ignored.

## Milestones

1. M1: config + stats structs
2. M2: direct-mapped cache read/write simulation
3. M3: trace file parser
4. M4: synthetic workload generator
5. M5: tests for hit/miss/eviction/dirty behavior
6. M6: benchmark hot/warm/cold regimes
7. M7: add 2-way set associative cache
8. M8: compare LRU vs random replacement
