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

module mem_to_wrb (
    input  logic          i_stage4_valid,
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
    input  logic          i_flush,
    input  logic          clk,
    input  logic          rst_n
);

`include "rtl/cpu/pipe/pipeline_types.svh"

    mem_to_wrb_t payload_in;
    mem_to_wrb_t payload_out;
    logic        vld_out;
    logic        rdy_in;

    always_comb begin
        payload_in.mem_valid        = i_mem_valid;
        payload_in.mem_write_enable = i_mem_write_enable;
        payload_in.mem_address      = i_mem_address;
        payload_in.mem_write_data   = i_mem_write_data;
    end

    pipeline_reg #(
        .T ( mem_to_wrb_t )
    ) u_mem_to_wrb_reg (
        .i_flush   ( i_flush ),
        .i_valid   ( i_stage4_valid ),
        .o_ready   ( rdy_in ),
        .i_payload ( payload_in ),
        .o_valid   ( vld_out ),
        .i_ready   ( i_wrb_ready ),
        .o_payload ( payload_out ),
        .clk       ( clk ),
        .rst_n     ( rst_n )
    );

    assign o_mem_ready    = rdy_in;
    assign o_stage4_valid = vld_out;

    assign o_mem_valid        = payload_out.mem_valid;
    assign o_mem_write_enable = payload_out.mem_write_enable;
    assign o_mem_address      = payload_out.mem_address;
    assign o_mem_write_data   = payload_out.mem_write_data;

endmodule
