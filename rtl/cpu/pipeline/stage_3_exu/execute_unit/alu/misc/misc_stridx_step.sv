/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements misc_stridx_step.
*/

    input  logic [31: 0] idx,  // 索引寄存器值
    input  logic          df, // 方向标志
    output logic [31: 0] y // 结果输出
);
    // 组合逻辑：推导输出
    always_comb begin
        y = df ? (idx - 32'd1) : (idx + 32'd1);
    end
endmodule
