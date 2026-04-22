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
//  File        : bit_bsr.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : bit_bsr module
// ============================================================================

module bit_bsr (    input  logic [31: 0]  a,  // 操作数 / 源 1
    output logic [31: 0] y, // 结果输出
    output logic         zf // 零标志
);
    // 组合逻辑：推导输出
    always_comb begin
        y = 32'd0;
        zf = 1'b1;
        for (int i = 0; i < 32; i++) begin
            if (a[31-i] && zf) begin
                y = 31 - i;
                zf = 1'b0;
            end
        end
    end
endmodule
