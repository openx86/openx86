module execute_shift_right #(
    // parameter
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] operand,
    input  logic [BIT_WIDTH-1:0] count,
    input  logic [BIT_WIDTH-1:0] is_signed,
    output logic [BIT_WIDTH-1:0] result
);

assign result = is_signed ?
    $signed(operand) >>> count
:
    operand >> count
;

endmodule
