/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_das.
*/
module stage_3_exe_misc_das (
    input  logic [31:  0] a,
    input  logic        af_in,
    input  logic        cf_in,
    output logic [31:  0] y,
    output logic        af_out,
    output logic        cf_out);
    logic [ 7:  0] al;
    logic [ 7:  0] orig_al;

    always_comb begin
        orig_al = a[ 7:  0];
        al = orig_al;
        af_out = af_in;
        cf_out = cf_in;

        if (((al & 8'h0F) > 8'h09) || af_in) begin
            al = al - 8'h06;
            af_out = 1'b1;
        end

        if ((orig_al > 8'h99) || cf_in) begin
            al = al - 8'h60;
            cf_out = 1'b1;
        end

        y = { a[31:  8], al };
    end

endmodule
