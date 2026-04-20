/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements misc_sahf.
*/
module misc_sahf (    input  logic [31: 0]  flags_in,  // 输入标志
    input  logic [31: 0]  eax_in,  // 输入 EAX
    output logic [31: 0] flags_out  // 输出标志
);
    // 组合逻辑：推导输出
    always_comb begin
        flags_out = {
            flags_in[31:  8],
            eax_in[15],
            eax_in[14],
            flags_in[5],
            eax_in[12],
            flags_in[3],
            eax_in[10],
            flags_in[1],
            eax_in[8]
        };
    end
endmodule
