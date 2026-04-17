/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_xadd.
*/
module stage_3_exe_misc_xadd (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    always_comb begin
        y = a + b;
    end
endmodule
