/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_loop_ctrl.
*/
module stage_3_exe_misc_loop_ctrl (
    input  logic [31: 0]  ecx,
    input  logic          zf,
    input  logic [ 1: 0]   mode,
    output logic [31: 0] ecx_next,
    output logic         taken
);
    always_comb begin
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
