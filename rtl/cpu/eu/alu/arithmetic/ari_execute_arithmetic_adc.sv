/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements ari_execute_arithmetic_adc.
*/
// ============================================================================
// execute_arithmetic_adc
// ----------------------------------------------------------------------------
// 执行单元算术子模块：ADC（Add with Carry）。
//
// 语义：
// - `result = operand_1 + operand_2 + carry_flag`
// - 该文件当前仅输出加法结果；标志位（CF/OF/...）若需要应由上层统一计算。
// ============================================================================

module ari_execute_arithmetic_adc #(    BIT_WIDTH = 32
) (
    input  logic [BIT_WIDTH-1: 0] operand_1,  // 第一操作数
    input  logic [BIT_WIDTH-1: 0] operand_2,  // 第二操作数
    input  logic                  carry_flag,  // 进位输入
    output logic [BIT_WIDTH-1: 0] result      // 带进位和
);

// 组合逻辑：连续赋值
assign result = operand_1 + operand_2 + BIT_WIDTH'(carry_flag);

endmodule
