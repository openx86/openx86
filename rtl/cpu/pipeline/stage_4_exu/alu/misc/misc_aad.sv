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
//  File        : misc_aad.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : misc_aad module
// ============================================================================

module misc_aad (    input  logic [31: 0]  a,  // 操作数 / 源 1
    output logic [31: 0] y // 结果输出
);
    logic [ 7: 0] al;

    // 组合逻辑：推导输出
    always_comb begin
        al = a[ 7: 0] + (a[15:  8] * 8'd10);
        y = { a[31: 16], 8'h00, al };
    end

endmodule
