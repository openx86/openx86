// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: decode_general_general_register_tb
// create at: 2021-10-22 02:29:28
// description: test decode_general_general_register module

`timescale 1ns/1ns
module decode_general_register_tb #(
    // parameters
) (
    // ports
);

initial begin: check_register_sequence_code
    logic [2:0] register_sequence_code;
    logic       w_in_instruction;
    logic       w;

    for (w_in_instruction = 0; w_in_instruction <= 1; w_in_instruction = w_in_instruction + 1) begin
        for (w = 0; w <= 1; w = w + 1) begin
            for (register_sequence_code = 0; register_sequence_code <= 7; register_sequence_code = register_sequence_code + 1) begin
                #1 $display ("w_in_instruction = %b, w = %b, register_sequence_code = %b", w_in_instruction, w, register_sequence_code);
            end
        end
    end
end

endmodule
