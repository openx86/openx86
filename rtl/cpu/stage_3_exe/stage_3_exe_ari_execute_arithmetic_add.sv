/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_ari_execute_arithmetic_add.
*/
// ============================================================================
// execute_arithmetic_add
// ----------------------------------------------------------------------------
// 执行单元算术子模块：ADD（无进位加法）。
//
// 语义：
// - `result = operand_1 + operand_2`
// - 本文件仅输出加法结果；标志位更新通常由上层统一实现。
// ============================================================================

module stage_3_exe_ari_execute_arithmetic_add #(
    // parameter
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] operand_1,
    input  logic [BIT_WIDTH-1:0] operand_2,
    output logic [BIT_WIDTH-1:0] result
);

assign result = operand_1 + operand_2;

endmodule
