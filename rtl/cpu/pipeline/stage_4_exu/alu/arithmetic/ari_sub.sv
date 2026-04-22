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
//  File        : ari_sub.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ari_sub module
// ============================================================================

module ari_sub (    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic [31: 0]  b, // 操作数 / 源 2
    output logic [31: 0] y // 结果输出
);
    ari_execute_arithmetic_sub u_impl (
        .operand_1 ( a ),
        .operand_2 ( b ),
        .result    ( y )
    );
endmodule
