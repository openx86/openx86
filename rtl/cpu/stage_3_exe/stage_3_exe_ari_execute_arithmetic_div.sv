/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_ari_execute_arithmetic_div.
*/
// ============================================================================
// execute_arithmetic_div
// ----------------------------------------------------------------------------
// 执行单元算术子模块：DIV（无符号除法）结果计算。
//
// 风险提示：
// - 除以 0、溢出等在 x86 中应触发异常；本文件可能只提供数学结果，不含异常机制。
// - 综合时除法器资源开销大；真实实现通常使用多周期除法或共享乘除单元。
// ============================================================================

module stage_3_exe_ari_execute_arithmetic_div #(
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1: 0] operand_1,    input  logic [BIT_WIDTH-1: 0] operand_2,    output logic [BIT_WIDTH-1: 0] result);

assign result = operand_1 / operand_2;

endmodule
