/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements misc_lahf.
*/

    input  logic [31: 0]  eax_in,  // 输入 EAX
    input  logic [31: 0]  flags_in, // 输入标志
    output logic [31: 0] eax_out // 输出 EAX
);
    // 组合逻辑：推导输出
    always_comb begin
        eax_out = {
            eax_in[31: 16],
            flags_in[7],
            flags_in[6],
            1'b0,
            flags_in[4],
            1'b0,
            flags_in[2],
            1'b1,
            flags_in[0],
            eax_in[ 7: 0]
        };
    end
endmodule
