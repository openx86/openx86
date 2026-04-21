/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: uop_to_exu pipeline boundary module for stage_3 to stage_4 handshake.
*/
// ============================================================================
// uop_to_exu
// ----------------------------------------------------------------------------
// Pipeline boundary between micro-op (stage_3) and execute (stage_4):
// - handles ready/valid handshake between stages
// - manages micro-op fire and flush signals
// ============================================================================

module uop_to_exu (
    input  logic i_uop_valid,
    input  logic i_exu_ready,
    input  logic i_flush,
    output logic o_stage3_valid,
    output logic o_uop_fire
);

    assign o_stage3_valid = i_uop_valid & ~i_flush;
    assign o_uop_fire     = i_uop_valid & i_exu_ready & ~i_flush;

endmodule
