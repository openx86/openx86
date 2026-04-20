/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: pipeline_boundary — combinational bridge from IF (stage_1) to decode inputs.
*/
// ============================================================================
// pipeline_boundary
// ----------------------------------------------------------------------------
// Passes instruction window, ready, and segment fault from IFU to DEC.
// ============================================================================

module if_to_dec (
    input  logic [15: 0][ 7: 0] i_instruction,
    input  logic          i_instruction_ready,
    input  logic          i_segment_fault,
    output logic [15: 0][ 7: 0] o_instruction,
    output logic         o_instruction_ready,
    output logic         o_segment_fault,
    input  logic          i_dec_ready,
    output logic         o_ifu_ready,
    input  logic          i_flush,
    input  logic          clk,
    input  logic          rst_n
);

`include "rtl/cpu/pipe/pipeline_types.svh"

    ifu_to_dec_t payload_in;
    ifu_to_dec_t payload_out;
    logic        vld_out;
    logic        rdy_in;

    always_comb begin
        payload_in.instruction   = i_instruction;
        payload_in.segment_fault = i_segment_fault;
    end

    pipeline_reg #(
        .T ( ifu_to_dec_t )
    ) u_if_to_dec_reg (
        .i_flush   ( i_flush ),
        .i_valid   ( i_instruction_ready ),
        .o_ready   ( rdy_in ),
        .i_payload ( payload_in ),
        .o_valid   ( vld_out ),
        .i_ready   ( i_dec_ready ),
        .o_payload ( payload_out ),
        .clk       ( clk ),
        .rst_n     ( rst_n )
    );

    assign o_ifu_ready         = rdy_in;
    assign o_instruction_ready = vld_out;
    assign o_instruction       = payload_out.instruction;
    assign o_segment_fault     = payload_out.segment_fault;

endmodule
