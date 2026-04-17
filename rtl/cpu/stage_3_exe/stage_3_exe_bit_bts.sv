/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_bit_bts.
*/
module stage_3_exe_bit_bts (
    input  logic [31: 0]  a,
    input  logic [31: 0]  bit_index,
    output logic [31: 0] y,
    output logic         cf
);
    logic [31: 0] mask;

    always_comb begin
        mask = 32'h1 << bit_index[ 4: 0];
        cf = a[bit_index[ 4: 0]];
        y = a | mask;
    end
endmodule
