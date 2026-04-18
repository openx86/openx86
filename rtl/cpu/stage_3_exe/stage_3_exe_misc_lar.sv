/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_lar.
*/
module stage_3_exe_misc_lar (
    input  logic [31: 0]  src,  // 源操作数
    output logic [31: 0] y,  // 结果输出
    output logic         zf  // 零标志
);
    // 组合逻辑：推导输出
    always_comb begin
        y  = src & 32'h00FF_FF00;
        zf = 1'b1;
    end
endmodule
