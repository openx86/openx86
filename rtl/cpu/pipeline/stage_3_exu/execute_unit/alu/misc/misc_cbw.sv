/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements misc_cbw.
*/

    input  logic [31: 0]  a,  // 操作数 / 源 1
    output logic [31: 0] y // 结果输出
);
    // 组合逻辑：推导输出
    always_comb begin
        y = { { 16{ a[15] } }, a[15: 0] };
    end

endmodule
