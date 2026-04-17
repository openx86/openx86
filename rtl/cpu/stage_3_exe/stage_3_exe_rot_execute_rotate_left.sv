/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_rot_execute_rotate_left.
*/
// ============================================================================
// execute_rotate_left
// ----------------------------------------------------------------------------
// 循环左移 / ROL。
//
// 语义：
// - `result = (operand << count) | (operand >> (BIT_WIDTH - count))`
// ============================================================================

module stage_3_exe_rot_execute_rotate_left #(
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1: 0] operand,
    input  logic [BIT_WIDTH-1: 0]  count,
    output logic [BIT_WIDTH-1: 0] result
);

    // 可变切片要求索引为常量；用移位实现 ROL；移位量取低位（与 x86 CL 掩码一致）
    localparam int ShW = (BIT_WIDTH <= 1) ? 1 : $clog2(BIT_WIDTH);
    logic [ShW-1: 0] sh = count[ShW-1:0];

    assign result = (operand << sh) | (operand >> (BIT_WIDTH - sh));

endmodule

