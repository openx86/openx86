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
//  File        : shf_shrd.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : shf_shrd module
// ============================================================================

module alu_shift_rotate_shf_shrd (    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic [31: 0]  b, // 操作数 / 源 2
    input  logic [31: 0]  count, // 移位或旋转计数值（低位有效）
    output logic [31: 0] y // 结果输出
);
    logic [ 4: 0] sh;
    logic [ 5: 0] sh6;

    // 组合逻辑：推导输出
    always_comb begin
        sh = count[ 4: 0];
        sh6 = { 1'b0, sh };
        if (sh == 5'd0)
            y = a;
        else
            y = (a >> sh) | (b << (6'd32 - sh6));
    end
endmodule
