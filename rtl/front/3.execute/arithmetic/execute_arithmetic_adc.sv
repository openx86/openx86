module execute_arithmetic_adc #(
    // parameter
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] operand_1,
    input  logic [BIT_WIDTH-1:0] operand_2,
    input  logic                 carry_flag,
    output logic [BIT_WIDTH-1:0] result
);

assign result = operand_1 + operand_2 + carry_flag;

endmodule
