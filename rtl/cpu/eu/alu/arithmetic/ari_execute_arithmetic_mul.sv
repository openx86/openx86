/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_alu_arithmetic_ari_execute_arithmetic_mul.
*/
// ============================================================================
// execute_arithmetic_mul
// ----------------------------------------------------------------------------
// 执行单元算术子模块：MUL（无符号乘法）结果计算。
//
// 说明：
// - 本文件通常只给出“乘法结果”的组合逻辑。
// - x86 的 MUL/IMUL 可能产生双倍宽度结果（例如 32x32 -> 64），以及影响 CF/OF。
//   具体截断/高低位选择由上层或其他单元决定。
// ============================================================================

module eu_alu_arithmetic_ari_execute_arithmetic_mul #(
    BIT_WIDTH = 32
) (
    input  logic [BIT_WIDTH-1: 0] operand_1,  // 第一操作数
    input  logic [BIT_WIDTH-1: 0] operand_2,  // 第二操作数
    output logic [BIT_WIDTH-1: 0] result      // 乘积低位（高位见乘除单元）
);

// 组合逻辑：连续赋值
assign result = operand_1 * operand_2;

endmodule
