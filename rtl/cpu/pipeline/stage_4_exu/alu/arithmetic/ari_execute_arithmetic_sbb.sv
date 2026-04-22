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
//  File        : ari_execute_arithmetic_sbb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ari_execute_arithmetic_sbb module
// ============================================================================

module ari_execute_arithmetic_sbb #(    BIT_WIDTH = 32
) (
    input  logic [BIT_WIDTH-1: 0] operand_1, // 第一操作数
    input  logic [BIT_WIDTH-1: 0] operand_2, // 第二操作数
    input  logic                  carry_flag, // 借位输入
    output logic [BIT_WIDTH-1: 0] result // 带借位差
);

    // 组合逻辑：连续赋值
    assign result = operand_1 - operand_2 - BIT_WIDTH'(carry_flag);

endmodule
