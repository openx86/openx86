/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_misc_lahf.
*/
module stage_3_exe_misc_lahf (
    input  logic [31:0] eax_in,
    input  logic [31:0] flags_in,
    output logic [31:0] eax_out
);
    always_comb begin
        eax_out = {
            eax_in[31:16],
            flags_in[7],
            flags_in[6],
            1'b0,
            flags_in[4],
            1'b0,
            flags_in[2],
            1'b1,
            flags_in[0],
            eax_in[7:0]
        };
    end
endmodule
