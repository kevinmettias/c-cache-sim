# Architecture Notes

This project is a C cache simulator intended to teach cache mechanics before a later Verilog implementation.

## Current Boundary

The starter code includes:

- cache configuration and statistics models
- trace event types
- source/test directories
- build and test plumbing

The cache behavior, parser behavior, workload generation, and benchmark behavior are intentionally not implemented yet.

## Suggested Milestone Shape

1. M1: config validation and stats helpers
2. M2: direct-mapped read/write simulation
3. M3: trace file parser wired into the simulator
4. M4: synthetic hot, warm, and cold workload generation
5. M5: tests for hit, miss, eviction, and dirty behavior
6. M6: benchmark reports for hot, warm, and cold regimes
7. M7: 2-way set associative cache
8. M8: LRU versus random replacement comparison

## Mental Model

For each memory address, derive:

- offset: which byte inside a cache line
- index: which cache set
- tag: identity of the memory block stored in the set

For a direct-mapped cache, each set has exactly one line. For set-associative caches, each set has multiple ways and needs a replacement policy.
