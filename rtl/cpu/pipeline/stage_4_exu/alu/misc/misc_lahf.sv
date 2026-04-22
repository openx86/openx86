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
//  File        : misc_lahf.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : misc_lahf module
// ============================================================================

module misc_lahf (    input  logic [31: 0]  eax_in,  // 输入 EAX
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
