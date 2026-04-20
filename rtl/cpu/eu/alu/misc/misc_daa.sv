/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_alu_misc_daa.
*/
module eu_alu_misc_daa (
    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic          af_in,
    input  logic          cf_in,  // 输入进位
    output logic [31: 0] y,  // 结果输出
    output logic         af_out,
    output logic         cf_out  // 输出进位
);
    logic [ 7: 0] al;  // 调整中的 AL

    // 组合逻辑：推导输出
    always_comb begin
        al = a[ 7: 0];
        af_out = af_in;
        cf_out = cf_in;

        // 低半字节非 BCD 或 AF：加 6 并置 AF
        if (((al & 8'h0F) > 8'h09) || af_in) begin
            al = al + 8'h06;
            af_out = 1'b1;
        end

        // 高半字节越界或 CF：加 0x60 并置 CF
        if ((al > 8'h9F) || cf_in) begin
            al = al + 8'h60;
            cf_out = 1'b1;
        end

        y = { a[31:  8], al };
    end

endmodule
