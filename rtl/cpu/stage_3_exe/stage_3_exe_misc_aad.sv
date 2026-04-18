/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_aad.
*/
module stage_3_exe_misc_aad (
    input  logic [31: 0]  a,  // 操作数 / 源 1
    output logic [31: 0] y  // 结果输出
);
    logic [ 7: 0] al;

    // 组合逻辑：推导输出
    always_comb begin
        al = a[ 7: 0] + (a[15:  8] * 8'd10);
        y = { a[31: 16], 8'h00, al };
    end

endmodule
