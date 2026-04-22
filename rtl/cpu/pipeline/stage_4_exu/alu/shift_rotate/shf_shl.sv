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
//  File        : shf_shl.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : shf_shl module
// ============================================================================

module shf_shl (    input  logic [31: 0]  a,  // 操作数 / 源 1
    input  logic [31: 0]  count, // 移位或旋转计数值（低位有效）
    output logic [31: 0] y // 结果输出
);
    shf_execute_shift_left u_impl (
        .operand ( a     ),
        .count   ( count ),
        .result  ( y     )
    );
endmodule
