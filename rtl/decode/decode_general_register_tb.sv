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
    bit testcase [1:0][1:0][7:0];

    foreach (testcase[w_in_instruction, w, register_sequence_code]) begin
        #1 $display ("w_in_instruction = %1b, w = %1b, register_sequence_code = %3b", w_in_instruction, w, register_sequence_code);
    end

    $finish();
end

endmodule
