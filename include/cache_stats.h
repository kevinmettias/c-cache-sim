#ifndef CACHE_STATS_H
#define CACHE_STATS_H

#include <stdint.h>

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

#endif
