/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_smsw.
*/
module stage_3_exe_misc_smsw (
    input logic [31: 0]  cr0,    output logic [31: 0] y);
    always_comb begin
        y = { 16'd0, cr0[15: 0] };
    end
endmodule
