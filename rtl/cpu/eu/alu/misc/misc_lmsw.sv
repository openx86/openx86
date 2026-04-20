/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_alu_misc_lmsw.
*/
module eu_alu_misc_lmsw (
    input  logic [31: 0]  cr0,  // CR0 相关
    input  logic [31: 0]  src,  // 源操作数
    output logic [31: 0] y  // 结果输出
);
    // 组合逻辑：推导输出
    always_comb begin
        y = { cr0[31:  4], src[ 3: 0] };
    end
endmodule
