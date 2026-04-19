/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_log_execute_logic_or.
*/
// ============================================================================
// execute_logic_or
// ----------------------------------------------------------------------------
// 执行单元逻辑子模块：OR（按位或）。
// ============================================================================

module stage_3_exe_log_execute_logic_or #(
    BIT_WIDTH = 32
) (
    input  logic [BIT_WIDTH-1: 0] operand_1,  // 第一操作数
    input  logic [BIT_WIDTH-1: 0] operand_2,  // 第二操作数
    output logic [BIT_WIDTH-1: 0] result      // 按位或结果
);

// 组合逻辑：连续赋值
assign result = operand_1 | operand_2;

endmodule
