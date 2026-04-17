/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_aas.
*/
module stage_3_exe_misc_aas (
    input logic [31: 0]  a,    input logic          af_in,    output logic [31: 0] y,    output logic         af_out,    output logic         cf_out);
    logic [ 7: 0] al;
    logic [ 7: 0] ah;

    always_comb begin
        al = a[ 7: 0];
        ah = a[15:  8];

        if (((al & 8'h0F) > 8'h09) || af_in) begin
            al = (al - 8'h06) & 8'h0F;
            ah = ah - 8'h01;
            af_out = 1'b1;
            cf_out = 1'b1;
        end else begin
            al = al & 8'h0F;
            af_out = 1'b0;
            cf_out = 1'b0;
        end

        y = { a[31: 16], ah, al };
    end

endmodule
