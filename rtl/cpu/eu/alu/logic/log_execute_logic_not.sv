/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_alu_logic_log_execute_logic_not.
*/
// ============================================================================
// execute_logic_not
// ----------------------------------------------------------------------------
// 执行单元逻辑子模块：NOT（按位取反）。
// ============================================================================

module eu_alu_logic_log_execute_logic_not #(
    BIT_WIDTH = 32
) (
    input  logic [BIT_WIDTH-1: 0] operand_1,  // 第一操作数
    output logic [BIT_WIDTH-1: 0] result      // 按位取反结果
);

// 组合逻辑：连续赋值
assign result = ~operand_1;

endmodule
