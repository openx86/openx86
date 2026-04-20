/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements ari_execute_arithmetic_sbb.
*/
// ============================================================================
// ari_execute_arithmetic_sbb — 带借位减法（SBB）
// ----------------------------------------------------------------------------
// `result = operand_1 - operand_2 - carry_flag`
// 仅输出结果；标志位更新由上层统一实现。
// ============================================================================

module ari_execute_arithmetic_sbb #(    BIT_WIDTH = 32
) (
    input  logic [BIT_WIDTH-1: 0] operand_1,  // 第一操作数
    input  logic [BIT_WIDTH-1: 0] operand_2,  // 第二操作数
    input  logic                  carry_flag,  // 借位输入
    output logic [BIT_WIDTH-1: 0] result      // 带借位差
);

    // 组合逻辑：连续赋值
    assign result = operand_1 - operand_2 - BIT_WIDTH'(carry_flag);

endmodule
