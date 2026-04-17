/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_log_execute_logic_not.
*/
// ============================================================================
// execute_logic_not
// ----------------------------------------------------------------------------
// 执行单元逻辑子模块：NOT（按位取反）。
// ============================================================================

module stage_3_exe_log_execute_logic_not #(
    // parameter
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] operand_1,
    output logic [BIT_WIDTH-1:0] result
);

assign result = ~operand_1;

endmodule
