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
//  File        : bit_btr.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : bit_btr module
// ============================================================================

module bit_btr (    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic [31: 0]  bit_index, // 位测试索引
    output logic [31: 0] y, // 结果输出
    output logic         cf // 进位标志
);
    logic [31: 0] mask;

    // 组合逻辑：推导输出
    always_comb begin
        mask = 32'h1 << bit_index[ 4: 0];
        cf = a[bit_index[ 4: 0]];
        y = a & ~mask;
    end
endmodule
