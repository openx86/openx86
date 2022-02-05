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
