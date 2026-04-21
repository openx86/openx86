/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements log_execute_logic_and.
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

module log_execute_logic_and #(    BIT_WIDTH = 32
) (
    input  logic [BIT_WIDTH-1: 0] operand_1, // 第一操作数
    input  logic [BIT_WIDTH-1: 0] operand_2, // 第二操作数
    output logic [BIT_WIDTH-1: 0] result // 按位与结果
);

// 组合逻辑：连续赋值
assign result = operand_1 & operand_2;

endmodule
