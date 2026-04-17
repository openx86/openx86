/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_aam.
*/
module stage_3_exe_misc_aam (
    input logic [31: 0]  a,    input logic [31: 0]  b,    output logic [31: 0] y);
    logic [ 7: 0] imm8;
    logic [ 7: 0] al;
    logic [ 7: 0] ah;

    always_comb begin
        imm8 = (b[ 7: 0] == 8'd0) ? 8'd10 : b[ 7: 0];
        ah = a[ 7: 0] / imm8;
        al = a[ 7: 0] % imm8;
        y = { a[31: 16], ah, al };
    end

endmodule
