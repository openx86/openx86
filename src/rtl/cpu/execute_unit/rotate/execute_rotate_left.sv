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

assign result = (count != 0) ? {operand[BIT_WIDTH-count-1:0], operand[BIT_WIDTH-1:BIT_WIDTH-count]} : operand;

endmodule

