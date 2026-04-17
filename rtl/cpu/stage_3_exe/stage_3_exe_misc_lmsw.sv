/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_lmsw.
*/
module stage_3_exe_misc_lmsw (
    input  logic [31: 0]  cr0,
    input  logic [31: 0]  src,
    output logic [31: 0] y
);
    always_comb begin
        y = { cr0[31:  4], src[ 3: 0] };
    end
endmodule
