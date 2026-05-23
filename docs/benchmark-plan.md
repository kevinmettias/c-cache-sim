# Benchmark Plan

The first benchmark goal is not speed. It is behavioral comparison across workloads.

## Workload Regimes

- Hot: a tiny working set repeatedly accessed
- Warm: a working set near the cache capacity
- Cold: streaming accesses with little or no reuse

## First Report Columns

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

## Initial Questions To Answer

- Does increasing cache size help hot, warm, and cold workloads equally?
- How much does line size matter for sequential traces?
- When do dirty evictions appear under write-back?
- When does write-allocate help or hurt?
