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
//  File        : rot_execute_rotate_right.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : rot_execute_rotate_right module
// ============================================================================

module rot_execute_rotate_right #(    BIT_WIDTH = 32
) (
    input  logic [BIT_WIDTH-1: 0] operand, // 待移位/旋转的操作数
    input  logic [BIT_WIDTH-1: 0]  count, // 移位或旋转计数值（低位有效）
    output logic [BIT_WIDTH-1: 0] result // 运算结果
);

    localparam int ShW = (BIT_WIDTH <= 1) ? 1 : $clog2(BIT_WIDTH);
    logic [ShW-1: 0] sh;

    // 组合逻辑：连续赋值
    assign sh = count[ShW-1:0];

    assign result = (operand >> sh) | (operand << (BIT_WIDTH - sh));

endmodule

