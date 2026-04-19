/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: stage_1_2_isc_dec — combinational bridge from IF (stage_1) to decode inputs.
*/
// ============================================================================
// stage_1_2_isc_dec
// ----------------------------------------------------------------------------
// Passes instruction window, ready, and segment fault from ISC to DEC.
// ============================================================================

module stage_1_2_isc_dec (
    input  logic [15: 0][ 7: 0] i_instruction,
    input  logic          i_instruction_ready,
    input  logic          i_segment_fault,
    output logic [15: 0][ 7: 0] o_instruction,
    output logic         o_instruction_ready,
    output logic         o_segment_fault,
    input  logic          clk,
    input  logic          rst_n
);

    assign o_instruction       = i_instruction;
    assign o_instruction_ready = i_instruction_ready;
    assign o_segment_fault     = i_segment_fault;

endmodule
