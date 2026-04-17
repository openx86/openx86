/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_2_dec.
*/
// ============================================================================
// stage_2_dec
// ----------------------------------------------------------------------------
// Stage 2 (DEC / decode front): generates a one-cycle fire pulse when a new
// fetched instruction block becomes ready.
// ============================================================================

module stage_2_dec (
    input logic  i_instruction_ready,    output logic o_stage_valid,    output logic o_insn_fire,    input logic  reset_n,    input logic  clock);
    logic instruction_ready_d1;

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n)
            instruction_ready_d1 <= 1'b0;
        else
            instruction_ready_d1 <= i_instruction_ready;
    end

    assign o_insn_fire  = i_instruction_ready & ~instruction_ready_d1;
    assign o_stage_valid = i_instruction_ready;

endmodule
