/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_bswap.
*/
module stage_3_exe_misc_bswap (
    input  logic [31: 0]  a,
    output logic [31: 0] y
);
    always_comb begin
        y = { a[ 7: 0], a[15:  8], a[23: 16], a[31: 24] };
    end
endmodule
