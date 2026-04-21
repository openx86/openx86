/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements misc_cdq.
*/
module misc_cdq (    input  logic [31: 0]  a,  // 操作数 / 源 1
    output logic [31: 0] y // 结果输出
);
    // 组合逻辑：推导输出
    always_comb begin
        y = a[31] ? 32'hFFFF_FFFF : 32'h0000_0000;
    end

endmodule
