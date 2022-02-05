module execute #(
    // parameter
    BIT_WIDTH = 32
) (
    // ports
    input  logic [BIT_WIDTH-1:0] register_index_operand_1,
    input  logic [BIT_WIDTH-1:0] register_data_operand_1,
    input  logic [BIT_WIDTH-1:0] register_index_operand_2,
    input  logic [BIT_WIDTH-1:0] register_data_operand_2,
    input  logic [BIT_WIDTH-1:0] register_index_result,
    input  logic [BIT_WIDTH-1:0] register_data_result,
);

assign result = (count != 0) ? {operand[BIT_WIDTH-count-1:0], operand[BIT_WIDTH-1:BIT_WIDTH-count]} : operand;

execute_arithmetic_adc u_execute_arithmetic_adc (
    .operand_1 ( register_data_operand_1 ),
    .operand_2 ( register_data_operand_2 ),
    .result ( register_data_result ),
);

endmodule
