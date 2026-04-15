// ============================================================================
// execute_rotate_left
// ----------------------------------------------------------------------------
// 循环左移 / ROL。
//
// 语义：
// - `result = (operand << count) | (operand >> (BIT_WIDTH - count))`
// ============================================================================

module execute_rotate_left #(
    // parameter
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] operand,
    input  logic [BIT_WIDTH-1:0] count,
    output logic [BIT_WIDTH-1:0] result
);

    // 可变切片要求索引为常量；用移位实现 ROL；移位量取低位（与 x86 CL 掩码一致）
    localparam int ShW = (BIT_WIDTH <= 1) ? 1 : $clog2(BIT_WIDTH);
    wire [ShW-1:0] sh = count[ShW-1:0];

    assign result = (operand << sh) | (operand >> (BIT_WIDTH - sh));

endmodule

