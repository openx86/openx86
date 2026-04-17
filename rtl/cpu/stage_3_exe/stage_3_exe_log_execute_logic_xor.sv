/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_log_execute_logic_xor.
*/
// ============================================================================
// execute_logic_xor
// ----------------------------------------------------------------------------
// 执行单元逻辑子模块：XOR（按位异或）。
// ============================================================================

module stage_3_exe_log_execute_logic_xor #(
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] operand_1,
    input  logic [BIT_WIDTH-1:0] operand_2,
    output logic [BIT_WIDTH-1:0] result
);

assign result = operand_1 ^ operand_2;

endmodule
