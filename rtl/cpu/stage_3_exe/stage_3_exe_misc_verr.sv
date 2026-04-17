/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_verr.
*/
module stage_3_exe_misc_verr (
    input logic [31: 0] selector,    output logic        zf);
    always_comb begin
        zf = (selector[15: 0] != 16'd0);
    end
endmodule
