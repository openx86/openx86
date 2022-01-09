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
