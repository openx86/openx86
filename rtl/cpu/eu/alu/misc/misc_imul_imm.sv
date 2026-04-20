/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements misc_imul_imm.
*/
module misc_imul_imm (    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic [31: 0]  b,  // 操作数 / 源 2
    output logic [31: 0] y,  // 结果输出
    output logic         overflow  // 乘法溢出
);
    logic signed [63: 0] wide;

    // 组合逻辑：推导输出
    always_comb begin
        wide = $signed(a) * $signed(b);
        y = wide[31: 0];
        overflow = (wide[63: 31] != { 33{ wide[31] } });
    end
endmodule
