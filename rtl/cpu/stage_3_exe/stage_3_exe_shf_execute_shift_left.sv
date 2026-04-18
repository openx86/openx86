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
    input  logic [BIT_WIDTH-1: 0] operand,  // 待移位/旋转的操作数
    input  logic [BIT_WIDTH-1: 0]  count,  // 移位或旋转计数值（低位有效）
    output logic [BIT_WIDTH-1: 0] result  // 运算结果
);

localparam int SHIFT_W = (BIT_WIDTH <= 1) ? 1 : $clog2(BIT_WIDTH);
// 饱和到有效位宽的移位量（避免越界切片）
logic [SHIFT_W-1: 0] shift_amt;

// 组合逻辑：连续赋值
assign shift_amt = count[SHIFT_W-1:0];

assign result = operand << shift_amt;

endmodule
