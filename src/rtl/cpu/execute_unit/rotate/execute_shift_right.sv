// ============================================================================
// execute_shift_right.sv (rotate/)
// ----------------------------------------------------------------------------
// 注意：该文件实现的是 `execute_rotate_right`（循环右移 / ROR），文件名沿用历史命名。
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

assign result = (count != 0) ? {operand[count-1:0], operand[BIT_WIDTH-count:count]} : operand;

endmodule
