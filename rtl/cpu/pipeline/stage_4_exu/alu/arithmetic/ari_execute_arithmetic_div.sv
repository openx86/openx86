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
//  File        : ari_execute_arithmetic_div.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ari_execute_arithmetic_div module
// ============================================================================

module ari_execute_arithmetic_div #(    BIT_WIDTH = 32
) (
    input  logic [BIT_WIDTH-1: 0] operand_1, // 被除数
    input  logic [BIT_WIDTH-1: 0] operand_2, // 除数
    output logic [BIT_WIDTH-1: 0] result // 商（余数由乘除单元处理）
);

// 组合逻辑：连续赋值
assign result = operand_1 / operand_2;

endmodule
