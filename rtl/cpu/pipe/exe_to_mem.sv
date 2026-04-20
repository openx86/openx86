/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: pipeline_boundary — combinational bridge from EXE stage to MEM (LSU) inputs.
*/
// ============================================================================
// pipeline_boundary
// ----------------------------------------------------------------------------
// Passes EXE valid and LSU request / memory return paths into memory_stage.
// ============================================================================

module exe_to_mem (
    input  logic          i_stage3_valid,
    output logic         o_stage3_valid,
    input  logic          i_mem_stage_ready,
    output logic         o_exe_ready,
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
    input  logic          i_flush,
    input  logic          clk,
    input  logic          rst_n
);

`include "rtl/cpu/pipe/pipeline_types.svh"

    exe_to_mem_t payload_in;
    exe_to_mem_t payload_out;
    logic        vld_out;
    logic        rdy_in;

    always_comb begin
        payload_in.start     = i_start;
        payload_in.is_store  = i_is_store;
        payload_in.addr      = i_addr;
        payload_in.wdata     = i_wdata;
        payload_in.mem_rdata = i_mem_rdata;
        payload_in.mem_ready = i_mem_ready;
    end

    pipeline_reg #(
        .T ( exe_to_mem_t )
    ) u_exe_to_mem_reg (
        .i_flush   ( i_flush ),
        .i_valid   ( i_stage3_valid ),
        .o_ready   ( rdy_in ),
        .i_payload ( payload_in ),
        .o_valid   ( vld_out ),
        .i_ready   ( i_mem_stage_ready ),
        .o_payload ( payload_out ),
        .clk       ( clk ),
        .rst_n     ( rst_n )
    );

    assign o_exe_ready    = rdy_in;
    assign o_stage3_valid = vld_out;

    assign o_start     = payload_out.start;
    assign o_is_store  = payload_out.is_store;
    assign o_addr      = payload_out.addr;
    assign o_wdata     = payload_out.wdata;
    assign o_mem_rdata = payload_out.mem_rdata;
    assign o_mem_ready = payload_out.mem_ready;

endmodule
