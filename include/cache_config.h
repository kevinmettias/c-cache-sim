#ifndef CACHE_CONFIG_H
#define CACHE_CONFIG_H

#include <stdbool.h>
#include <stdint.h>

typedef struct CacheConfig {
    uint64_t cache_size_bytes;
    uint64_t line_size_bytes;
    uint32_t associativity;
    bool write_back;
    bool write_allocate;
} CacheConfig;

#endif
