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
//  File        : misc_arpl.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : misc_arpl module
// ============================================================================

module misc_arpl (    input  logic [31: 0]  dst,  // 目的操作数
    input  logic [31: 0]  src, // 源操作数
    output logic [31: 0] y, // 结果输出
    output logic         zf // 零标志
);
    // 组合逻辑：推导输出
    always_comb begin
        if (dst[ 1: 0] < src[ 1: 0]) begin
            y  = { dst[31:  2], src[ 1: 0] };
            zf = 1'b1;
        end else begin
            y  = dst;
            zf = 1'b0;
        end
    end
endmodule
