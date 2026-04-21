/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements misc_verr.
*/
module misc_verr (    input  logic [31: 0] selector,  // 选择子
    output logic        zf // 零标志
);
    // 组合逻辑：推导输出
    always_comb begin
        zf = (selector[15: 0] != 16'd0);
    end
endmodule
