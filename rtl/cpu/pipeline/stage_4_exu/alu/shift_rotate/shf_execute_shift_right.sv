/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements shf_execute_shift_right.
*/
// ============================================================================
// execute_shift_right
// ----------------------------------------------------------------------------
// 执行单元移位子模块：右移（SHR/SAR）。
// - `is_signed` 用于选择逻辑右移(0)或算术右移(1)的行为（高位填充 0 或符号位）。
// ============================================================================

module shf_execute_shift_right #(    BIT_WIDTH = 32
) (
    input  logic [BIT_WIDTH-1: 0] operand, // 待移位/旋转的操作数
    input  logic [BIT_WIDTH-1: 0]  count, // 移位或旋转计数值（低位有效）
    input  logic [BIT_WIDTH-1: 0] is_signed, // 低位=1 为算术右移，否则逻辑右移
    output logic [BIT_WIDTH-1: 0] result // 运算结果
);

localparam int SHIFT_W = (BIT_WIDTH <= 1) ? 1 : $clog2(BIT_WIDTH);
// 饱和后的移位位数
logic [SHIFT_W-1: 0] shift_amt;

// 组合逻辑：连续赋值
assign shift_amt = count[SHIFT_W-1:0];

assign result = is_signed[0]
    ? ($signed(operand) >>> shift_amt)
    : (operand >> shift_amt);

endmodule
