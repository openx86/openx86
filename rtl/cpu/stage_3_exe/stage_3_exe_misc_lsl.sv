/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_lsl.
*/
module stage_3_exe_misc_lsl (
    input logic [31: 0]  src,    output logic [31: 0] y,    output logic         zf);
    always_comb begin
        y  = 32'h000F_FFFF;
        zf = 1'b1;
    end
endmodule
