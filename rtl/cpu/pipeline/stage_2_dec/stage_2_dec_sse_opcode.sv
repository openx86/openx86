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
//  File        : stage_2_dec_sse_opcode.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : SSE opcode decode (SSE1 subset)
// ============================================================================

module stage_2_dec_sse_opcode (
    output logic         o_opcode_sse_any,
    output logic         o_opcode_sse_ADDSS,
    output logic         o_opcode_sse_MULSS,
    output logic         o_opcode_sse_MOVSS,
    output logic         o_opcode_sse_MOVAPS,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

    logic [ 7: 0] map1;
    logic [ 7: 0] map2;
    logic         esc_0f;

    assign esc_0f = (i_instruction[0][7: 0] == 8'h0F);
    assign map1   = i_instruction[1][7: 0];
    assign map2   = i_instruction[2][7: 0];

    assign o_opcode_sse_ADDSS  = esc_0f & (map1 == 8'h58);
    assign o_opcode_sse_MULSS  = esc_0f & (map1 == 8'h59);
    assign o_opcode_sse_MOVSS  = esc_0f & (map1 == 8'h10);
    assign o_opcode_sse_MOVAPS = esc_0f & (map1 == 8'h28);
    assign o_opcode_sse_any    = o_opcode_sse_ADDSS | o_opcode_sse_MULSS |
                                 o_opcode_sse_MOVSS | o_opcode_sse_MOVAPS;

endmodule
