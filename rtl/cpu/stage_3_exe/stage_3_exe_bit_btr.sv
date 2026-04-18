/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_bit_btr.
*/
module stage_3_exe_bit_btr (
    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic [31: 0]  bit_index,  // 位测试索引
    output logic [31: 0] y,  // 结果输出
    output logic         cf  // 进位标志
);
    logic [31: 0] mask;

    // 组合逻辑：推导输出
    always_comb begin
        mask = 32'h1 << bit_index[ 4: 0];
        cf = a[bit_index[ 4: 0]];
        y = a & ~mask;
    end
endmodule
