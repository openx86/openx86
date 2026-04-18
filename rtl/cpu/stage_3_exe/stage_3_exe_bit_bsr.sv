/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_bit_bsr.
*/
module stage_3_exe_bit_bsr (
    input  logic [31: 0]  a,  // 操作数 / 源 1
    output logic [31: 0] y,  // 结果输出
    output logic         zf  // 零标志
);
    // 组合逻辑：推导输出
    always_comb begin
        y = 32'd0;
        zf = 1'b1;
        for (int i = 0; i < 32; i++) begin
            if (a[31-i] && zf) begin
                y = 31 - i;
                zf = 1'b0;
            end
        end
    end
endmodule
