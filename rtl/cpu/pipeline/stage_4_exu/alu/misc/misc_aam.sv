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
//  File        : misc_aam.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : misc_aam module
// ============================================================================

module misc_aam (    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic [31: 0]  b, // 操作数 / 源 2
    output logic [31: 0] y // 结果输出
);
    logic [ 7: 0] imm8;
    logic [ 7: 0] al;
    logic [ 7: 0] ah;

    // 组合逻辑：推导输出
    always_comb begin
        imm8 = (b[ 7: 0] == 8'd0) ? 8'd10 : b[ 7: 0];
        ah = a[ 7: 0] / imm8;
        al = a[ 7: 0] % imm8;
        y = { a[31: 16], ah, al };
    end

endmodule
