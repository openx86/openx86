/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_ari_inc.
*/
module stage_3_exe_ari_inc (
    input  logic [31:0] a,
    output logic [31:0] y
);
    assign y = a + 32'd1;
endmodule
