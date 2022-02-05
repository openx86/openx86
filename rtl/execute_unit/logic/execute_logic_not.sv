module execute_logic_not #(
    // parameter
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] operand_1,
    output logic [BIT_WIDTH-1:0] result
);

assign result = ~operand_1;

endmodule
