/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements misc_aam.
*/

    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic [31: 0]  b, // 操作数 / 源 2
    output logic [31: 0] y // 结果输出
);
    logic [ 7: 0] imm8;
    logic [ 7: 0] al;
    logic [ 7: 0] ah;

    // 组合逻辑：推导输出
    always_comb begin
        imm8 = (b[ 7: 0] == 8'd0) ? 8'd10 : b[ 7: 0];
        ah = a[ 7: 0] / imm8;
        al = a[ 7: 0] % imm8;
        y = { a[31: 16], ah, al };
    end

endmodule
