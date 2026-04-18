/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_shf_execute_shift_right.
*/
// ============================================================================
// execute_shift_right
// ----------------------------------------------------------------------------
// 执行单元移位子模块：右移（SHR/SAR）。
// - `is_signed` 用于选择逻辑右移(0)或算术右移(1)的行为（高位填充 0 或符号位）。
// ============================================================================

module stage_3_exe_shf_execute_shift_right #(
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1: 0] operand,
    input  logic [BIT_WIDTH-1: 0]  count,
    input  logic [BIT_WIDTH-1: 0] is_signed,
    output logic [BIT_WIDTH-1: 0] result
);

localparam int SHIFT_W = (BIT_WIDTH <= 1) ? 1 : $clog2(BIT_WIDTH);
logic [SHIFT_W-1: 0] shift_amt;

assign shift_amt = count[SHIFT_W-1:0];

assign result = is_signed[0]
    ? ($signed(operand) >>> shift_amt)
    : (operand >> shift_amt);

endmodule
