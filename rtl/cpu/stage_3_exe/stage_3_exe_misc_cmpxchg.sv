/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_cmpxchg.
*/
module stage_3_exe_misc_cmpxchg (
    input  logic [31:  0] acc,
    input  logic [31:  0] dst,
    input  logic [31:  0] src,
    output logic [31:  0] y,
    output logic        zf);
    always_comb begin
        zf = (acc == dst);
        if (zf)
            y = src;
        else
            y = dst;
    end
endmodule
