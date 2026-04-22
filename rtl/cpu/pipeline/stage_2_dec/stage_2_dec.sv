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
//  File        : stage_2_dec.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_2_dec module
// ============================================================================

module stage_2_dec (
    // =========================
    // instruction input
    // =========================
    input  logic [15: 0][ 7: 0] i_instruction,
    input  logic                i_instruction_valid,

    // =========================
    // decode outputs
    // =========================
    output logic [ 3: 0]        o_consume_bytes,
    output logic                o_decode_error,

    // TODO: decode results: opcode, operand types, etc.

    input  logic                clk,                      // 时钟信号
    input  logic                rst_n                     // 复位信号
);

endmodule
