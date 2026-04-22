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
//  File        : ari_execute_arithmetic_sub.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ari_execute_arithmetic_sub module
// ============================================================================

module alu_arithmetic_ari_sub #(
    parameter BIT_WIDTH = 32
) (
    // =========================
    // operands
    // =========================
    input  logic [BIT_WIDTH-1: 0] a,
    input  logic [BIT_WIDTH-1: 0] b,

    // =========================
    // output
    // =========================
    output logic [BIT_WIDTH-1: 0] y
);

    // ============================================================
    // combinational logic: continuous assignment
    // ============================================================
    assign y = a - b;

endmodule
