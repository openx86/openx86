/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_shf_execute_shift_left.
*/
// ============================================================================
// execute_shift_left
// ----------------------------------------------------------------------------
// 执行单元移位子模块：逻辑左移（SHL/SAL）。
// - `result = operand << count`
// ============================================================================

module stage_3_exe_shf_execute_shift_left #(
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1: 0] operand,
    input  logic [BIT_WIDTH-1: 0]  count,
    output logic [BIT_WIDTH-1: 0] result
);

localparam int SHIFT_W = (BIT_WIDTH <= 1) ? 1 : $clog2(BIT_WIDTH);
logic [SHIFT_W-1: 0] shift_amt = count[SHIFT_W-1:0];

assign result = operand << shift_amt;

endmodule
