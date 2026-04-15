// ============================================================================
// execute_rotate_right
// ----------------------------------------------------------------------------
// 循环右移 / ROR。
//
// 语义：
// - `result = (operand >> count) | (operand << (BIT_WIDTH - count))`
// ============================================================================

module execute_rotate_right #(
    // parameter
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] operand,
    input  logic [BIT_WIDTH-1:0] count,
    output logic [BIT_WIDTH-1:0] result
);

    localparam int ShW = (BIT_WIDTH <= 1) ? 1 : $clog2(BIT_WIDTH);
    wire [ShW-1:0] sh = count[ShW-1:0];

    assign result = (operand >> sh) | (operand << (BIT_WIDTH - sh));

endmodule

