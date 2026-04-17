/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_shf_shrd.
*/
module stage_3_exe_shf_shrd (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] count,
    output logic [31:0] y
);
    logic [4:0] sh;
    logic [5:0] sh6;

    always_comb begin
        sh = count[4:0];
        sh6 = { 1'b0, sh };
        if (sh == 5'd0)
            y = a;
        else
            y = (a >> sh) | (b << (6'd32 - sh6));
    end
endmodule
