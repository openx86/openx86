/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: pipeline_boundary — combinational bridge from MEM LSU outputs to WRB inputs.
*/
// ============================================================================
// pipeline_boundary
// ----------------------------------------------------------------------------
// Passes MEM stage valid and data-bus request bundle into write_back_stage.
// ============================================================================

module mem_to_wrb (    input  logic          i_stage4_valid,
    output logic         o_stage4_valid,
    input  logic          i_wrb_ready,
    output logic         o_mem_ready,
    input  logic          i_mem_valid,
    output logic         o_mem_valid,
    input  logic          i_mem_write_enable,
    output logic         o_mem_write_enable,
    input  logic [31: 0] i_mem_address,
    output logic [31: 0] o_mem_address,
    input  logic [31: 0] i_mem_write_data,
    output logic [31: 0] o_mem_write_data,
    input  logic          clk,
    input  logic          rst_n
);

    assign o_stage4_valid     = i_stage4_valid & i_wrb_ready;
    assign o_mem_valid        = i_mem_valid & i_wrb_ready;
    assign o_mem_write_enable = i_mem_write_enable;
    assign o_mem_address      = i_mem_address;
    assign o_mem_write_data   = i_mem_write_data;
    assign o_mem_ready        = i_wrb_ready;

endmodule
