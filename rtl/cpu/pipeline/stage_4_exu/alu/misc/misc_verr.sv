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
//  File        : misc_verr.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : misc_verr module
// ============================================================================

module misc_verr (    input  logic [31: 0] selector,  // 选择子
    output logic        zf // 零标志
);
    // 组合逻辑：推导输出
    always_comb begin
        zf = (selector[15: 0] != 16'd0);
    end
endmodule
