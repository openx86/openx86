/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements misc_bswap.
*/
module misc_bswap (    input  logic [31: 0]  a,  // 操作数 / 源 1
    output logic [31: 0] y  // 结果输出
);
    // 组合逻辑：推导输出
    always_comb begin
        y = { a[ 7: 0], a[15:  8], a[23: 16], a[31: 24] };
    end
endmodule
