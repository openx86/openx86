/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements misc_aas.
*/
module misc_aas (    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic          af_in,
    output logic [31: 0] y,  // 结果输出
    output logic         af_out,
    output logic         cf_out  // 输出进位
);
    logic [ 7: 0] al;
    logic [ 7: 0] ah;

    // 组合逻辑：推导输出
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
