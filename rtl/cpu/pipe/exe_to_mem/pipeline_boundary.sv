/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: pipe_exe_to_mem_pipeline_boundary — combinational bridge from EXE stage to MEM (LSU) inputs.
*/
// ============================================================================
// pipe_exe_to_mem_pipeline_boundary
// ----------------------------------------------------------------------------
// Passes EXE valid and LSU request / memory return paths into mem_memory_stage.
// ============================================================================

module pipe_exe_to_mem_pipeline_boundary (
    input  logic          i_stage3_valid,
    output logic         o_stage3_valid,
    input  logic          i_start,
    output logic         o_start,
    input  logic          i_is_store,
    output logic         o_is_store,
    input  logic [31: 0] i_addr,
    output logic [31: 0] o_addr,
    input  logic [31: 0] i_wdata,
    output logic [31: 0] o_wdata,
    input  logic [31: 0] i_mem_rdata,
    output logic [31: 0] o_mem_rdata,
    input  logic          i_mem_ready,
    output logic         o_mem_ready,
    input  logic          clk,
    input  logic          rst_n
);

    assign o_stage3_valid = i_stage3_valid;
    assign o_start          = i_start;
    assign o_is_store       = i_is_store;
    assign o_addr           = i_addr;
    assign o_wdata          = i_wdata;
    assign o_mem_rdata      = i_mem_rdata;
    assign o_mem_ready      = i_mem_ready;

endmodule
