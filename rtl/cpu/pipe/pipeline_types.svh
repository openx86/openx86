/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: common packed types for CPU 5-stage pipeline payloads.
*/

// ============================================================================
// pipeline_types
// ----------------------------------------------------------------------------
// Shared payload typedefs used on stage boundaries.
// NOTE: This file intentionally contains only types (no logic).
// ============================================================================

typedef struct packed {
    logic [15: 0][ 7: 0] instruction;
    logic                segment_fault;
} ifu_to_dec_t;

typedef struct packed {
    logic         start;
    logic         is_store;
    logic [31: 0] addr;
    logic [31: 0] wdata;
    logic [31: 0] mem_rdata;
    logic         mem_ready;
} exe_to_mem_t;

typedef struct packed {
    logic         mem_valid;
    logic         mem_write_enable;
    logic [31: 0] mem_address;
    logic [31: 0] mem_write_data;
} mem_to_wrb_t;

