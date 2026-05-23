#ifndef CACHE_SIM_H
#define CACHE_SIM_H

#include <stdbool.h>
#include <stdint.h>

#include "cache_config.h"
#include "cache_stats.h"

typedef struct CacheSim CacheSim;

CacheSim *CacheSim_Create(CacheConfig config);
void CacheSim_Destroy(CacheSim *cache_sim);

bool CacheSim_Read(CacheSim *cache_sim, uint64_t address);
bool CacheSim_Write(CacheSim *cache_sim, uint64_t address);

const CacheStats *CacheSim_Stats(const CacheSim *cache_sim);
void CacheSim_Reset(CacheSim *cache_sim);

#endif
