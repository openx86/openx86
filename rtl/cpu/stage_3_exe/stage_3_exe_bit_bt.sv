/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_bit_bt.
*/
module stage_3_exe_bit_bt (
    input  logic [31:  0] a,
    input  logic [31:  0] bit_index,
    output logic [31:  0] y,
    output logic        cf);
    always_comb begin
        y = a;
        cf = a[bit_index[ 4:  0]];
    end
endmodule
