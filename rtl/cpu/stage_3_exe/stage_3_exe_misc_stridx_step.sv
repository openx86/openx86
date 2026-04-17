/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_stridx_step.
*/
module stage_3_exe_misc_stridx_step (
    input logic [31: 0]  idx,    input logic          df,    output logic [31: 0] y);
    always_comb begin
        y = df ? (idx - 32'd1) : (idx + 32'd1);
    end
endmodule
