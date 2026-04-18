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
    input  logic i_instruction_ready, // 取指缓冲就绪（上游 stage1）
    output logic o_stage_valid,       // 本译码级数据有效跟随就绪
    output logic o_insn_fire,         // 就绪上升沿脉冲：启动一拍译码
    input  logic clk,
    input  logic rst_n
);
    logic instruction_ready_d1; // 就绪打一拍，用于边沿检测

    // 打拍：检测 i_instruction_ready 上升沿
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            instruction_ready_d1 <= 1'b0;
        else
            instruction_ready_d1 <= i_instruction_ready;
    end

    assign o_insn_fire  = i_instruction_ready & ~instruction_ready_d1;
    assign o_stage_valid = i_instruction_ready;

endmodule
