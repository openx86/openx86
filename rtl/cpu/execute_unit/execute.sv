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
    input  logic [BIT_WIDTH-1:0] register_data_result
);

logic [BIT_WIDTH-1:0] adc_result;

execute_arithmetic_adc u_execute_arithmetic_adc (
    .operand_1 ( register_data_operand_1 ),
    .operand_2 ( register_data_operand_2 ),
    .result    ( adc_result )
);

endmodule
