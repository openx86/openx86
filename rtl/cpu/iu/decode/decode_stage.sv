/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements decode_stage.
*/
// ============================================================================
// decode_stage
// ----------------------------------------------------------------------------
// Stage 2 (DEC / decode front): generates a one-cycle fire pulse when a new
// fetched instruction block becomes ready.
// ============================================================================

module decode_stage (    input  logic i_instruction_ready, // 取指缓冲就绪（上游 stage1）
    input  logic i_stage3_ready,      // 下游 EXE 可接收
    output logic o_stage_ready,       // 对上游 IFU/DEC 的反压
    output logic o_stage_valid,       // 本译码级数据有效跟随就绪
    output logic o_insn_fire,         // 就绪上升沿脉冲：启动一拍译码
    input  logic clk,
    input  logic rst_n
);
    assign o_stage_ready = i_stage3_ready;
    assign o_insn_fire   = i_instruction_ready & i_stage3_ready;
    assign o_stage_valid = i_instruction_ready;

endmodule
