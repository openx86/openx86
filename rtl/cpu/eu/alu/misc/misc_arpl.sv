/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_alu_misc_arpl.
*/
module eu_alu_misc_arpl (
    input  logic [31: 0]  dst,  // 目的操作数
    input  logic [31: 0]  src,  // 源操作数
    output logic [31: 0] y,  // 结果输出
    output logic         zf  // 零标志
);
    // 组合逻辑：推导输出
    always_comb begin
        if (dst[ 1: 0] < src[ 1: 0]) begin
            y  = { dst[31:  2], src[ 1: 0] };
            zf = 1'b1;
        end else begin
            y  = dst;
            zf = 1'b0;
        end
    end
endmodule
