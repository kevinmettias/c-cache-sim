# Cache Simulator Lab

## Lab Overview

Modern processors are much faster than main memory. Caches reduce that gap by keeping recently used memory blocks close to the CPU. This lab asks you to build a cache simulator in C so you can observe cache behavior directly before translating the same ideas into hardware later.

The simulator will read memory traces, apply a configurable cache model, collect statistics, and compare cache designs across workloads. The early goal is not to create a perfect model of a commercial CPU cache. The early goal is to understand the core mechanisms well enough that each reported hit, miss, eviction, and dirty write-back is explainable.

The long-term goal is more ambitious: by the end of the advanced lab, this project should be a useful and insightful cache analysis tool. It should help you reason about caches from an algorithmic and data-structure point of view before introducing the spatial, temporal, timing, and signal-level constraints of Verilog. The tool should make cache behavior inspectable across workloads, policies, and architecture families, so later hardware work starts from a strong behavioral model instead of guesswork.

You will start with a direct-mapped cache and gradually add parsing, workload generation, tests, benchmark reports, and eventually set associativity and replacement-policy comparisons.

## Learning Objectives

By the end of this lab, you should be able to:

- Explain how cache size, line size, associativity, write policy, and allocation policy affect cache behavior.
- Derive tag, index, and offset fields from a memory address.
- Simulate read and write accesses from a trace file.
- Distinguish read hits, read misses, write hits, write misses, evictions, and dirty evictions.
- Design small traces that expose specific cache behaviors.
- Compare cache configurations using measured statistics rather than intuition alone.
- Separate simulator correctness from benchmark interpretation.

## Motivation

Cache behavior is often unintuitive. A program may run quickly when its working set fits in cache, then slow down sharply when it barely exceeds capacity. A larger line size may help sequential access but waste space for sparse access. A direct-mapped cache may perform poorly on two addresses that repeatedly map to the same set, even if the cache has enough total capacity.

A simulator makes those effects visible. Instead of treating cache performance as a black box, you will build a tool that answers questions such as:

- How many memory references hit in the cache?
- Which accesses cause misses?
- When does an access evict an existing line?
- When does a write-back cache need to write dirty data back to memory?
- Which workloads benefit from larger caches, larger lines, or higher associativity?

These are the same questions you will need to reason about when you eventually move toward a Verilog implementation.

## End-State Vision

The completed advanced simulator should support research-style exploration, not only classroom examples. It should let you ask disciplined questions about how cache designs behave before committing to a hardware architecture.

Useful end-state capabilities include:

- Configurable cache geometry: capacity, line size, associativity, number of sets, and hierarchy depth.
- Configurable behavior: write policy, allocation policy, replacement policy, inclusion policy, and prefetch policy.
- Workload diversity: synthetic locality patterns, adversarial traces, streaming traces, mixed read/write traces, and imported real traces.
- Algorithmic visibility: clear accounting for lookup behavior, replacement decisions, metadata overhead, miss classification, and policy-specific state.
- Benchmark reproducibility: named configurations, deterministic workloads, recorded seeds, versioned result files, and machine-readable reports.
- Comparative analysis: reports that explain tradeoffs across cache designs, workload regimes, and hardware architecture assumptions.

This simulator should not claim to be cycle-accurate unless a later phase explicitly adds and validates timing behavior. Its first responsibility is to make cache algorithms, data structures, and policy tradeoffs understandable.

## Background Theory

### Cache Lines

A cache stores memory in fixed-size blocks called cache lines. If the line size is 64 bytes, then an access to address `0x1004` brings the entire aligned block containing `0x1004` into the cache, not only that single byte.

The line size determines the offset field of an address: the byte position within a cache line.

### Sets, Ways, and Associativity

A cache is divided into sets. Each set contains one or more ways.

- A direct-mapped cache has one way per set.
- A 2-way set-associative cache has two possible lines per set.
- A fully associative cache is the limiting case where any line can go anywhere.

Associativity controls how many cache lines can compete for the same index before eviction becomes necessary.

### Tag, Index, and Offset

For each memory address, the simulator must identify:

- `offset`: where the byte falls within the cache line
- `index`: which cache set the address maps to
- `tag`: which memory block is currently represented by a line

Two addresses with the same index but different tags compete for the same set. In a direct-mapped cache, this means one must evict the other.

### Hits and Misses

A hit occurs when the requested memory block is already present in the cache. A miss occurs when it is not present and the cache must bring the block in or otherwise handle the access according to policy.

Track reads and writes separately. A good simulator should report not only a total hit rate, but also read hit rate and write hit rate.

### Evictions

An eviction occurs when the cache needs to place a new line into a set that has no available invalid line. In a direct-mapped cache, this can happen whenever a valid line with a different tag already occupies the target set.

Evictions are important because they reveal conflict and capacity pressure.

### Dirty Lines and Write Policy

A dirty line is a cache line that has been modified in the cache but not yet written back to lower memory.

For this project, the initial configuration model includes:

```c
typedef struct CacheConfig {
    uint64_t cache_size_bytes;
    uint64_t line_size_bytes;
    uint32_t associativity;
    bool write_back;
    bool write_allocate;
} CacheConfig;
```

The first statistics model is:

```c
typedef struct CacheStats {
    uint64_t reads;
    uint64_t writes;
    uint64_t read_hits;
    uint64_t read_misses;
    uint64_t write_hits;
    uint64_t write_misses;
    uint64_t evictions;
    uint64_t dirty_evictions;
} CacheStats;
```

You should understand what each field means before writing code that updates it.

### Replacement Policy

When a set has multiple ways and all are occupied, the simulator needs a rule for choosing a victim line. Later milestones compare policies such as:

- LRU: evict the least recently used line
- Random: evict a randomly selected line

Do not begin with this complexity. First make the direct-mapped case correct.

## Project Scope

This lab uses C, not Verilog. The C simulator is the learning vehicle. Hardware design comes later, after the behavior is clear.

The intended project layout is:

```text
c-cache-sim/
  include/
    cache_sim.h
    cache_config.h
    cache_stats.h
    trace.h
  src/
    cache_sim.c
    trace.c
    workloads.c
    main.c
  tests/
    test_cache_sim.c
    test_trace.c
  benchmarks/
    traces/
    results/
  docs/
    architecture.md
    benchmark-plan.md
    lab.md
  Makefile
  README.md
```

The implementation should remain small, testable, and milestone-driven.

## Trace Format

The initial trace format is intentionally simple:

```text
R 0x1000
W 0x1040
```

Each non-comment line represents one memory operation:

- `R`: read from an address
- `W`: write to an address

Addresses may be hexadecimal or decimal. Lines beginning with `#` are comments.

The trace parser should reject malformed input clearly enough that incorrect benchmark data does not silently produce misleading results.

## Ordered Phases

### Phase 1: Configuration and Statistics

Define the data models that describe a cache configuration and the statistics collected during simulation.

Deliverables:

- A cache configuration type.
- A cache statistics type.
- Basic validation rules for configurations.
- A way to initialize and reset statistics.

Guiding questions:

- Which configuration values are invalid?
- Must cache size be divisible by line size?
- What does associativity mean when it is `1`?
- Which fields should start at zero?

Completion check:

- You can create a valid direct-mapped configuration.
- Invalid configurations are rejected before simulation begins.
- Statistics have predictable initial values.

### Phase 2: Direct-Mapped Cache Simulation

Build the first working cache model with associativity equal to `1`.

Deliverables:

- Read simulation.
- Write simulation.
- Hit and miss accounting.
- Eviction accounting.
- Dirty-line accounting for write-back behavior.

Guiding questions:

- How do you determine whether an access hits?
- What cache state changes on a read miss?
- What cache state changes on a write hit?
- What happens on a write miss with write-allocate enabled?
- What happens on a write miss with write-allocate disabled?
- When should a dirty eviction be counted?

Completion check:

- A repeated read of the same address produces a miss followed by a hit.
- Two addresses mapping to the same set but with different tags can cause eviction.
- Write behavior changes when write-back and write-allocate settings change.

### Phase 3: Trace Parser

Implement parsing for memory traces so the simulator can process files rather than only hand-written calls.

Deliverables:

- A trace event type.
- A parser for read and write operations.
- Comment and blank-line handling.
- Error handling for malformed trace lines.

Guiding questions:

- What should the parser return for a valid line?
- How should it report an invalid operation?
- How should it report an invalid address?
- Should parsing continue after an error, or stop immediately?

Completion check:

- A small valid trace file can be parsed and replayed.
- Invalid trace lines are detected.
- Parser tests do not require the cache simulator to be correct.

### Phase 4: Synthetic Workload Generator

Create repeatable workloads that expose different cache behaviors.

Deliverables:

- Hot workload generation.
- Warm workload generation.
- Cold workload generation.
- Generated traces saved under `benchmarks/traces/`.

Workload regimes:

- Hot: a small working set repeatedly accessed.
- Warm: a working set near the cache capacity.
- Cold: streaming or sparse accesses with little reuse.

Guiding questions:

- What makes a workload have strong temporal locality?
- What makes a workload have strong spatial locality?
- How can a workload intentionally create conflict misses?
- What parameters make a generated workload reproducible?

Completion check:

- The same generator settings produce the same trace.
- Hot, warm, and cold workloads produce visibly different hit-rate patterns.

### Phase 5: Correctness Tests

Write tests that prove individual behaviors before relying on benchmark output.

Deliverables:

- Hit and miss tests.
- Eviction tests.
- Dirty eviction tests.
- Trace parser tests.
- Tests for important configuration validation rules.

Guiding questions:

- What is the smallest trace that proves a hit?
- What is the smallest trace that proves an eviction?
- What is the smallest trace that proves a dirty eviction?
- Which tests would fail if index or tag extraction were wrong?

Completion check:

- Tests cover both reads and writes.
- Tests include at least one conflict pattern.
- Tests are deterministic.

### Phase 6: Benchmark Report

Run controlled experiments across cache configurations and workload regimes.

Deliverables:

- Benchmark inputs.
- Benchmark results under `benchmarks/results/`.
- A report comparing configurations.

Initial report columns:

- workload name
- cache size
- line size
- associativity
- reads
- writes
- read hit rate
- write hit rate
- total hit rate
- evictions
- dirty evictions

Guiding questions:

- Does increasing cache size help all workloads equally?
- Does increasing line size help sequential access?
- When do dirty evictions appear?
- When does write-allocate help?
- When does write-allocate hurt?

Completion check:

- Results are generated from trace files, not manually entered.
- Each result row identifies the workload and cache configuration.
- The report explains observed behavior using cache concepts.

### Phase 7: 2-Way Set-Associative Cache

Extend the simulator beyond direct mapping by allowing two ways per set.

Deliverables:

- Support for associativity equal to `2`.
- Correct hit detection across both ways.
- Correct victim selection when both ways are occupied.
- Statistics compatible with earlier direct-mapped results.

Guiding questions:

- What changes when a set contains two candidate lines?
- How do you search for a hit?
- How do you choose an empty way?
- How do you choose a victim when no way is empty?
- Which direct-mapped tests should still pass unchanged?

Completion check:

- Direct-mapped behavior still works.
- A conflict pattern that performs poorly in a direct-mapped cache improves in a 2-way cache.
- Replacement behavior is observable in tests.

### Phase 8: Replacement-Policy Comparison

Compare LRU and random replacement on the same traces.

Deliverables:

- LRU replacement statistics or policy support.
- Random replacement policy support.
- Benchmark comparison across workloads.

Guiding questions:

- Which metadata is needed to make LRU decisions?
- How should random replacement be made reproducible for tests?
- Which workloads favor LRU?
- Which workloads make random replacement competitive?

Completion check:

- LRU and random can be selected without changing trace files.
- Random replacement is deterministic when seeded.
- The report explains where policy choice matters and where it does not.

## Advanced Phases

Phases 1 through 8 build the core learning simulator. Phase 9 and later turn the project into a more comprehensive cache simulation lab. These phases are intentionally broader and should be attempted only after the direct-mapped, trace-driven, benchmarked simulator is correct and well tested.

### Phase 9: Comprehensive Cache Configuration Matrix

Expand the simulator and benchmark harness so it can sweep many cache designs in one run.

Deliverables:

- A structured way to describe multiple cache configurations.
- Batch benchmark execution across cache size, line size, associativity, write policy, allocation policy, and replacement policy.
- Results that can be compared across all selected configurations.

Guiding questions:

- Which parameters are independent, and which combinations are invalid?
- How will you prevent benchmark results from becoming hard to interpret?
- What minimum set of configurations gives useful coverage without producing noise?
- Which fields must appear in every result row to make comparisons fair?

Completion check:

- A single benchmark command can run multiple configurations.
- Invalid configuration combinations are rejected before execution.
- Result files are organized so runs can be reproduced and compared.

### Phase 10: Additional Replacement Policies

Add more replacement policies and compare their behavior against LRU and random.

Possible policies:

- FIFO
- MRU
- Clock or second-chance
- Pseudo-LRU

Deliverables:

- A policy selection mechanism.
- Tests that expose policy-specific victim choices.
- Benchmark results comparing at least three replacement policies.

Guiding questions:

- What metadata does each policy require?
- Which policies are realistic for hardware?
- Which policies are easier to simulate than to implement in hardware?
- Which workloads make the policy choice visible?

Completion check:

- Policy behavior is testable with small traces.
- Policy metadata does not leak into unrelated simulator code.
- The report distinguishes correctness from performance.

### Phase 11: Multi-Level Cache Simulation

Extend the simulator from one cache to a simple hierarchy such as L1 plus L2.

Deliverables:

- A model for multiple cache levels.
- Per-level hit, miss, and eviction statistics.
- A clear rule for how misses flow from one level to the next.
- Benchmark reports that separate L1 behavior from overall memory behavior.

Guiding questions:

- What event happens in L2 after an L1 miss?
- How should write policy interact across levels?
- What does an L1 eviction mean for L2?
- Which statistics belong to each level?

Completion check:

- A trace can be replayed through more than one cache level.
- Per-level statistics are reported separately.
- Simple traces can prove that an L1 miss may still be an L2 hit.

### Phase 12: Miss Classification

Classify misses to explain why they occurred, not only how many occurred.

Miss categories:

- Compulsory misses
- Capacity misses
- Conflict misses

Deliverables:

- A method for classifying misses.
- Tests for simple compulsory, capacity, and conflict cases.
- Benchmark output that includes miss-classification counts or rates.

Guiding questions:

- What extra reference information is needed to classify a miss?
- Which classifications are exact, and which are approximations?
- How does associativity change conflict misses?
- How does total cache size change capacity misses?

Completion check:

- Small hand-written traces produce expected classifications.
- Benchmark reports explain hit rate changes using miss categories.
- Classification logic is documented separately from normal hit/miss accounting.

### Phase 13: Performance Cost Model

Estimate performance impact using a simple cycle or latency model.

Deliverables:

- Configurable hit latency and miss penalty values.
- Total estimated access cost.
- Average memory access time calculations.
- Benchmark reports including both hit rates and estimated cost.

Guiding questions:

- Why can two configurations with similar hit rates have different costs?
- How should dirty evictions affect estimated cost?
- What assumptions does the cost model make about memory latency?
- Which numbers are measured by the simulator, and which are model parameters?

Completion check:

- The simulator can report average memory access time.
- Cost model assumptions are visible in the report.
- Results do not imply cycle accuracy beyond the model's assumptions.

### Phase 14: Real Trace Integration

Support traces produced by external tools or real programs.

Deliverables:

- A documented trace import path.
- Conversion or normalization for at least one external trace format.
- Validation that imported traces preserve operation type and address.
- Benchmark results comparing synthetic and real traces.

Guiding questions:

- What information does the external trace format include?
- What information does your simulator ignore?
- How large can traces become before memory or runtime becomes a problem?
- How will you sample, split, or stream large traces?

Completion check:

- At least one real or externally generated trace can be simulated.
- Import errors are reported clearly.
- The report compares synthetic workload assumptions with real trace behavior.

### Phase 15: Visualization and Reporting

Improve the output so results are easier to analyze and explain.

Deliverables:

- CSV or another machine-readable report format.
- Plots or tables for hit rate, miss rate, evictions, and dirty evictions.
- A written benchmark summary that connects plots to cache theory.

Guiding questions:

- Which graph best shows cache-size sensitivity?
- Which graph best shows line-size sensitivity?
- Which graph best shows replacement-policy differences?
- What should be plotted as counts, rates, or normalized values?

Completion check:

- Reports can be regenerated from benchmark data.
- Plots include enough labels to stand alone.
- The written analysis explains causes, not only trends.

### Phase 16: Hardware-Oriented Preparation

Prepare the simulator concepts for a future Verilog implementation without writing Verilog yet.

Deliverables:

- A document mapping simulator concepts to hardware blocks.
- A list of state elements needed for a direct-mapped hardware cache.
- A list of operations that would occur per clocked access.
- A set of tiny traces suitable for later hardware testbenches.

Guiding questions:

- Which simulator fields become registers or memories?
- Which operations are combinational decisions?
- Which operations require stored state?
- Which simulator conveniences would not exist in hardware?

Completion check:

- The hardware mapping is written in terms of state, inputs, outputs, and transitions.
- The mapping avoids relying on C-specific implementation details.
- The selected traces are small enough to become hardware testbench cases.

### Phase 17: Architecture-Family Case Studies

Use the simulator to study cache choices across different hardware architecture contexts. The goal is not to perfectly model proprietary processors. The goal is to understand why different IC types and hardware systems favor different cache organizations.

Example architecture contexts:

- Microcontroller or embedded SoC
- Desktop or server CPU
- GPU or throughput-oriented accelerator
- DSP or signal-processing pipeline
- Network processor or packet-processing ASIC
- ML accelerator or tiled array architecture
- Coherent multicore system

Deliverables:

- A short architecture profile for each selected context.
- A cache configuration family matched to each profile.
- Workloads that reasonably stress each architecture context.
- A comparison report explaining why each design choice fits or fails its context.

Guiding questions:

- What is the dominant access pattern for this architecture?
- Is latency, bandwidth, area, power, determinism, or throughput most important?
- Does the architecture benefit from large caches, predictable caches, scratchpads, or streaming buffers?
- Which cache behaviors are architectural necessities, and which are implementation choices?
- Which simulator assumptions are too simple for this architecture?

Completion check:

- At least three architecture contexts are compared.
- Each context has a justified workload and cache configuration set.
- The analysis distinguishes measured simulator behavior from hardware-specific assumptions.

### Phase 18: Research-Grade Benchmark Methodology

Make the benchmark process rigorous enough that results are reproducible, reviewable, and useful for deeper investigation.

Deliverables:

- A benchmark manifest describing traces, configurations, seeds, and output files.
- Repeatable benchmark runs with stable identifiers.
- Statistical summaries across repeated runs where randomness is involved.
- Clear separation between raw results, derived metrics, and written interpretation.
- A benchmark methodology document.

Guiding questions:

- What must be recorded so another person can reproduce a result?
- Which results are deterministic?
- Which results require multiple trials?
- What derived metrics are meaningful?
- How will you avoid cherry-picking favorable traces or configurations?

Completion check:

- A benchmark run can be reproduced from its manifest.
- Randomized policies report seeds and trial counts.
- Raw data is preserved separately from summaries and plots.
- The report identifies limitations and threats to validity.

### Phase 19: Advanced Cache Features

Add selected advanced cache mechanisms that appear in real research or production cache designs.

Possible features:

- Victim cache
- Stream buffer
- Next-line prefetching
- Stride prefetching
- Non-blocking cache model with outstanding misses
- Write buffer model
- Inclusion, exclusion, or non-inclusion policy for multi-level caches
- Way prediction or skewed associativity
- Scratchpad memory comparison

Deliverables:

- One or more advanced features selected for focused study.
- Feature-specific tests and traces.
- Benchmark comparisons showing when the feature helps, hurts, or has no effect.
- Documentation of new assumptions introduced by the feature.

Guiding questions:

- What problem is this feature trying to solve?
- What new metadata or state does it require?
- What workload should benefit from it?
- What workload could make it perform poorly?
- Is this feature mainly an algorithmic idea, a hardware optimization, or both?

Completion check:

- Each feature has a baseline comparison.
- Each feature has at least one workload where its behavior is visible.
- The analysis includes cost or complexity, not only hit-rate improvement.

### Phase 20: Research-Style Capstone Analysis

Use the simulator to conduct a small research-style cache study.

Deliverables:

- A research question.
- A hypothesis.
- A benchmark plan.
- Reproducible results.
- A written analysis with figures or tables.
- A limitations section.
- A conclusion that states what was learned and what remains unresolved.

Example research questions:

- When does higher associativity stop helping for hot, warm, and cold workloads?
- How does replacement policy sensitivity change across architecture families?
- Which workloads benefit more from prefetching than from increased capacity?
- When does write-allocate become harmful?
- How much metadata does an advanced replacement policy require relative to its benefit?

Guiding questions:

- Is the research question narrow enough to answer?
- What baseline are you comparing against?
- What would disprove your hypothesis?
- Are the traces representative of the claim?
- What simulator limitations affect the conclusion?

Completion check:

- The study can be rerun from documented commands or manifests.
- The conclusion follows from the data.
- The report is honest about what the simulator does not model.
- The result improves your understanding of cache design tradeoffs.

## Design Constraints

Follow these constraints throughout the project:

- Keep cache behavior separate from trace parsing.
- Keep benchmark reporting separate from simulator correctness tests.
- Prefer small functions with clear responsibilities.
- Avoid hard-coding one cache size or one line size.
- Make generated workloads reproducible.
- Treat tests as part of the design, not as an afterthought.
- Do not move to Verilog until the C simulator behavior is well understood.
- Keep algorithmic cache behavior separate from later signal-level, layout-level, and timing-level hardware concerns.

## Suggested Lab Notebook Entries

For each phase, record:

- What you implemented.
- What assumptions you made.
- One trace or test case that exposed a bug or misunderstanding.
- One result that matched your expectation.
- One result that surprised you.

This notebook will be useful later when translating the simulator concepts into hardware.

## Final Submission Expectations

At the end of the core lab, the project should include:

- A working C cache simulator.
- Unit tests for core behavior.
- Trace parser tests.
- Synthetic hot, warm, and cold traces.
- Benchmark results comparing cache configurations.
- A short written interpretation of the benchmark results.

At the end of the advanced lab, the project should also include:

- A broader cache configuration sweep.
- Multiple replacement-policy comparisons.
- Optional multi-level cache results.
- Miss classification or cost-model analysis.
- Reproducible reports suitable for explaining cache design tradeoffs.
- Architecture-family case studies across multiple IC or hardware-system contexts.
- Research-grade benchmark manifests, raw results, derived metrics, and written analysis.
- At least one advanced cache feature studied against a baseline.
- Hardware-oriented notes that prepare the direct-mapped design for a later Verilog version.

The strongest submissions will not only produce numbers. They will explain why the numbers changed when cache size, line size, associativity, write policy, workload locality, replacement policy, architecture context, or advanced cache feature changed.

The final advanced project should feel like a small research instrument: limited in scope, honest about assumptions, reproducible, and useful for building deep cache intuition before moving into Verilog or physical hardware constraints.
