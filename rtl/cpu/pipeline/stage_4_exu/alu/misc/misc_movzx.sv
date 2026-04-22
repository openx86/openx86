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
//  File        : misc_movzx.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : misc_movzx module
// ============================================================================

module misc_movzx (    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic [ 1: 0]   width, // 源宽度编码
    output logic [31: 0] y // 结果输出
);
    // 组合逻辑：推导输出
    always_comb begin
        if (width == 2'b01)
            y = { 24'd0, a[ 7: 0] };
        else if (width == 2'b10)
            y = { 16'd0, a[15: 0] };
        else
            y = a;
    end

endmodule
