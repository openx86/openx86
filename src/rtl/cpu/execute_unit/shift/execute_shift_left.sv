// ============================================================================
// execute_shift_left
// ----------------------------------------------------------------------------
// 执行单元移位子模块：逻辑左移（SHL/SAL）。
// - `result = operand << count`
// ============================================================================

module execute_shift_left #(
    // parameter
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] operand,
    input  logic [BIT_WIDTH-1:0] count,
    output logic [BIT_WIDTH-1:0] result
);

assign result = {operand[BIT_WIDTH-count-1:count], count'b0};

endmodule
