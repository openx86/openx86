/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_alu_arithmetic_ari_inc.
*/
module eu_alu_arithmetic_ari_inc (
    input  logic [31: 0]  a,  // 操作数 / 源 1
    output logic [31: 0] y  // 结果输出
);
    // 组合逻辑：连续赋值
    assign y = a + 32'd1;
endmodule
