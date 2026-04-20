/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_alu_misc_lsl.
*/
module eu_alu_misc_lsl (
    input  logic [31: 0]  src,  // 源操作数
    output logic [31: 0] y,  // 结果输出
    output logic         zf  // 零标志
);
    // 组合逻辑：推导输出
    always_comb begin
        y  = 32'h000F_FFFF;
        zf = 1'b1;
    end
endmodule
