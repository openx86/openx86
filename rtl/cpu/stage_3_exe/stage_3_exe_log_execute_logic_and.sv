/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_log_execute_logic_and.
*/
// ============================================================================
// execute_logic_and
// ----------------------------------------------------------------------------
// 执行单元逻辑子模块：AND（按位与）。
//
// 语义：
// - `result = operand_1 & operand_2`
// - 标志位更新（例如 ZF/SF/PF，CF/OF 清零等）通常由上层统一实现。
// ============================================================================

module stage_3_exe_log_execute_logic_and #(
    BIT_WIDTH = 32
) (
    // ports
    input logic [BIT_WIDTH-1:0]  operand_1,    input logic [BIT_WIDTH-1:0]  operand_2,    output logic [BIT_WIDTH-1:0] result);

assign result = operand_1 & operand_2;

endmodule
