/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements misc_smsw.
*/
module misc_smsw (    input  logic [31: 0]  cr0,  // CR0 相关
    output logic [31: 0] y  // 结果输出
);
    // 组合逻辑：推导输出
    always_comb begin
        y = { 16'd0, cr0[15: 0] };
    end
endmodule
