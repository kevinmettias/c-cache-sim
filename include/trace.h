#ifndef TRACE_H
#define TRACE_H

#include <stdint.h>

typedef enum TraceOp
{
    TraceOp_Read = 0,
    TraceOp_Write = 1
} TraceOp;

typedef struct TraceEvent
{
    TraceOp op;
    uint64_t address;
} TraceEvent;

#endif
