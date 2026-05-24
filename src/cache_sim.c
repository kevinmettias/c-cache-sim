#include "cache_sim.h"

#include <stdint.h>
#include <stdlib.h>

struct CacheSim
{
    CacheConfig config;
    CacheStats stats;
};

static CacheSim* CacheSim_Create(void)
{
    return malloc(sizeof(CacheSim));
}

CacheSim* CacheSim_Create_And_Initialize(CacheConfig config)
{
    CacheSim* sim = CacheSim_Create();
    if (sim == NULL)
    {
        return NULL;
    }
    sim->config = config;
    sim->stats = (CacheStats){0};
    return sim;
}

CacheSim* CacheSim_Create_And_Initialize_With_Stats(CacheConfig config, CacheStats stats)
{
    CacheSim* sim = CacheSim_Create_And_Initialize(config);
    if (sim == NULL)
    {
        return NULL;
    }

    sim->stats = stats;

    return sim;
}

void CacheSim_Destroy(CacheSim* cache_sim)
{
    if (cache_sim == NULL)
    {
        return;
    }

    free(cache_sim);
}

bool CacheSim_Read(CacheSim* cache_sim, uint64_t address)
{
    (void)address;

    cache_sim->stats.reads++;
    return true;
}

bool CacheSim_Write(CacheSim* cache_sim, uint64_t address)
{
    (void)address;

    cache_sim->stats.writes++;
    return true;
}

const CacheStats* CacheSim_Stats(const CacheSim* cache_sim)
{
    return &cache_sim->stats;
}

void CacheSim_Reset(CacheSim* cache_sim)
{
    if (cache_sim == NULL)
    {
        return;
    }

    cache_sim->stats = (CacheStats){0};
}
