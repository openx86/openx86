/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_das.
*/
module stage_3_exe_misc_das (
    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic          af_in,  // 输入 AF
    input  logic          cf_in,  // 输入进位
    output logic [31: 0] y,  // 结果输出
    output logic         af_out,  // 输出 AF
    output logic         cf_out  // 输出进位
);
    logic [ 7: 0] al;  // 调整中的 AL
    logic [ 7: 0] orig_al;  // 原始 AL（用于高位越界判定）

    // 组合逻辑：推导输出
    always_comb begin
        orig_al = a[ 7: 0];
        al = orig_al;
        af_out = af_in;
        cf_out = cf_in;

        // 低半字节借位校正
        if (((al & 8'h0F) > 8'h09) || af_in) begin
            al = al - 8'h06;
            af_out = 1'b1;
        end

        // 原始 AL>0x99 或 CF：再减 0x60
        if ((orig_al > 8'h99) || cf_in) begin
            al = al - 8'h60;
            cf_out = 1'b1;
        end

        y = { a[31:  8], al };
    end

endmodule
