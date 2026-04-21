/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements shf_shrd.
*/
module shf_shrd (    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic [31: 0]  b, // 操作数 / 源 2
    input  logic [31: 0]  count, // 移位或旋转计数值（低位有效）
    output logic [31: 0] y // 结果输出
);
    logic [ 4: 0] sh;
    logic [ 5: 0] sh6;

    // 组合逻辑：推导输出
    always_comb begin
        sh = count[ 4: 0];
        sh6 = { 1'b0, sh };
        if (sh == 5'd0)
            y = a;
        else
            y = (a >> sh) | (b << (6'd32 - sh6));
    end
endmodule
