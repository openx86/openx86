/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_cbw.
*/
module stage_3_exe_misc_cbw (
    input  logic [31: 0] a,
    output logic [31: 0] y
);
    always_comb begin
        y = { { 16{ a[15] } }, a[15: 0] };
    end

endmodule
