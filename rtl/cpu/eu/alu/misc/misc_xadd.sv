/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_alu_misc_xadd.
*/
module eu_alu_misc_xadd (
    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic [31: 0]  b,  // 操作数 / 源 2
    output logic [31: 0] y  // 结果输出
);
    // 组合逻辑：推导输出
    always_comb begin
        y = a + b;
    end
endmodule
