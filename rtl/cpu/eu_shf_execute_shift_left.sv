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

localparam int SHIFT_W = (BIT_WIDTH <= 1) ? 1 : $clog2(BIT_WIDTH);
wire [SHIFT_W-1:0] shift_amt = count[SHIFT_W-1:0];

assign result = operand << shift_amt;

endmodule
