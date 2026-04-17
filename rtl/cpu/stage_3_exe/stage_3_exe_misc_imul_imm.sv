/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_imul_imm.
*/
module stage_3_exe_misc_imul_imm (
    input  logic [31: 0]  a,
    input  logic [31: 0]  b,
    output logic [31: 0] y,
    output logic         overflow
);
    logic signed [63: 0] wide;

    always_comb begin
        wide = $signed(a) * $signed(b);
        y = wide[31: 0];
        overflow = (wide[63: 31] != { 33{ wide[31] } });
    end
endmodule
