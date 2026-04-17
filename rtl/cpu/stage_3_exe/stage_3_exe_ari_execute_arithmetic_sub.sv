/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_ari_execute_arithmetic_sub.
*/
// ============================================================================
// stage_3_exe_ari_execute_arithmetic_sub — 普通减法（SUB）
// ----------------------------------------------------------------------------
// `result = operand_1 - operand_2`
// 仅输出结果；标志位更新由上层统一实现。
// ============================================================================

module stage_3_exe_ari_execute_arithmetic_sub #(
    BIT_WIDTH = 32
) (
    input  logic [BIT_WIDTH-1: 0] operand_1,    input  logic [BIT_WIDTH-1: 0] operand_2,    output logic [BIT_WIDTH-1: 0] result);

    assign result = operand_1 - operand_2;

endmodule
