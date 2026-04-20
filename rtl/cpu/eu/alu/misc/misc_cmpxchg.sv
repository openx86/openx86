/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_alu_misc_cmpxchg.
*/
module eu_alu_misc_cmpxchg (
    input  logic [31: 0]  acc,  // 累加器 / 比较目标
    input  logic [31: 0]  dst,  // 目的操作数
    input  logic [31: 0]  src,  // 源操作数
    output logic [31: 0] y,  // 结果输出
    output logic         zf  // 零标志
);
    // 组合逻辑：推导输出
    always_comb begin
        zf = (acc == dst);
        if (zf)
            y = src;
        else
            y = dst;
    end
endmodule
