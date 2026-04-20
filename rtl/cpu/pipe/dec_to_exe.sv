/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: pipeline_boundary — bridge DEC front (insn_fire / stage2 valid) toward EXE.
*/
// ============================================================================
// pipeline_boundary
// ----------------------------------------------------------------------------
// Wraps decode_stage between instruction-ready and execute-side handshake nets.
// ============================================================================

module dec_to_exe (
    input  logic i_instruction_ready,
    input  logic i_exe_ready,
    output logic o_dec_ready,
    output logic o_insn_fire,
    output logic o_stage_valid,
    input  logic i_flush,
    input  logic clk,
    input  logic rst_n
);

    logic dummy_in;
    logic dummy_out;
    logic vld_out;

    assign dummy_in = 1'b0;

    pipeline_reg #(
        .T ( logic )
    ) u_dec_to_exe_reg (
        .i_flush   ( i_flush ),
        .i_valid   ( i_instruction_ready ),
        .o_ready   ( o_dec_ready ),
        .i_payload ( dummy_in ),
        .o_valid   ( vld_out ),
        .i_ready   ( i_exe_ready ),
        .o_payload ( dummy_out ),
        .clk       ( clk ),
        .rst_n     ( rst_n )
    );

    assign o_stage_valid = vld_out;
    assign o_insn_fire   = vld_out & i_exe_ready;

endmodule
