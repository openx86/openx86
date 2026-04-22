// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : misc_sahf.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : misc_sahf module
// ============================================================================

module misc_sahf (    input  logic [31: 0]  flags_in,  // 输入标志
    input  logic [31: 0]  eax_in, // 输入 EAX
    output logic [31: 0] flags_out // 输出标志
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
