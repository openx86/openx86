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

module pipeline_boundary (    input  logic i_instruction_ready,
    output logic o_insn_fire,
    output logic o_stage_valid,
    input  logic clk,
    input  logic rst_n
);

    decode_stage u_stage_2_dec (
        .i_instruction_ready ( i_instruction_ready ),
        .o_insn_fire         ( o_insn_fire ),
        .o_stage_valid       ( o_stage_valid ),
        .clk                 ( clk ),
        .rst_n               ( rst_n )
    );

endmodule
