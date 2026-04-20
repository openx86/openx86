/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements eu_alu_misc_loop_ctrl.
*/
module eu_alu_misc_loop_ctrl (
    input  logic [31: 0]  ecx,  // ECX 当前值
    input  logic          zf,  // 零标志
    input  logic [ 1: 0]   mode,  // LOOP 族模式
    output logic [31: 0] ecx_next,  // LOOP 后 ECX
    output logic         taken  // 条件成立 / 跳转
);
    // 组合逻辑：推导输出
    always_comb begin
        // LOOP / LOOPE / LOOPNE：ECX 递减后与 ZF 组合
        unique case (mode)
            2'b00: begin
                ecx_next = ecx - 32'd1;
                taken = (ecx_next != 32'd0);
            end
            2'b01: begin
                ecx_next = ecx - 32'd1;
                taken = (ecx_next != 32'd0) && zf;
            end
            2'b10: begin
                ecx_next = ecx - 32'd1;
                taken = (ecx_next != 32'd0) && !zf;
            end
            default: begin
                ecx_next = ecx;
                taken = (ecx == 32'd0);
            end
        endcase
    end
endmodule
