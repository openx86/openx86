/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_alu_arithmetic_ari_execute_arithmetic_sub.
*/
// ============================================================================
// eu_alu_arithmetic_ari_execute_arithmetic_sub — 普通减法（SUB）
// ----------------------------------------------------------------------------
// `result = operand_1 - operand_2`
// 仅输出结果；标志位更新由上层统一实现。
// ============================================================================

module eu_alu_arithmetic_ari_execute_arithmetic_sub #(
    BIT_WIDTH = 32
) (
    input  logic [BIT_WIDTH-1: 0] operand_1,  // 第一操作数
    input  logic [BIT_WIDTH-1: 0] operand_2,  // 第二操作数
    output logic [BIT_WIDTH-1: 0] result      // 无借位差
);

    // 组合逻辑：连续赋值
    assign result = operand_1 - operand_2;

endmodule
