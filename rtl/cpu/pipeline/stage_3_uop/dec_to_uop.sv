/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: dec_to_uop pipeline boundary module for stage_2 to stage_3 handshake.
*/
// ============================================================================
// dec_to_uop
// ----------------------------------------------------------------------------
// Pipeline boundary between decode (stage_2) and micro-op (stage_3):
// - handles ready/valid handshake between stages
// - manages instruction fire and flush signals
// ============================================================================

module dec_to_uop (
    input  logic i_dec_ready,
    input  logic i_uop_ready,
    input  logic i_flush,
    output logic o_stage2_valid,
    output logic o_insn_fire
);

    assign o_stage2_valid = i_dec_ready;
    assign o_insn_fire   = i_dec_ready & i_uop_ready & ~i_flush;

endmodule
