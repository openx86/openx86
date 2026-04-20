/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements misc_movzx.
*/
module misc_movzx (    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic [ 1: 0]   width,  // 源宽度编码
    output logic [31: 0] y  // 结果输出
);
    // 组合逻辑：推导输出
    always_comb begin
        if (width == 2'b01)
            y = { 24'd0, a[ 7: 0] };
        else if (width == 2'b10)
            y = { 16'd0, a[15: 0] };
        else
            y = a;
    end

endmodule
