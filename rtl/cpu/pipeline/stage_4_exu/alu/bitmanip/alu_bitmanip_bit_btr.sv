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
//  File        : bit_btr.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : bit_btr module
// ============================================================================

module alu_bitmanip_bit_btr (
    // =========================
    // operands
    // =========================
    input  logic [31: 0]  a,
    input  logic [31: 0]  bit_index,

    // =========================
    // outputs
    // =========================
    output logic [31: 0] y,
    output logic         cf
);
    // ============================================================
    // intermediate signals
    // ============================================================
    logic [31: 0] mask;

    // ============================================================
    // combinational logic: derive outputs
    // ============================================================
    always_comb begin : comb_bit_reset
        mask = 32'h1 << bit_index[ 4: 0];
        cf = a[bit_index[ 4: 0]];
        y = a & ~mask;
    end
endmodule
