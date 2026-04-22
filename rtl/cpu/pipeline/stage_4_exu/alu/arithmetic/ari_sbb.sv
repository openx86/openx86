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
//  File        : ari_sbb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ari_sbb module
// ============================================================================

module ari_sbb (
    // =========================
    // operands
    // =========================
    input  logic [31: 0]  a,
    input  logic [31: 0]  b,
    input  logic          cf,

    // =========================
    // output
    // =========================
    output logic [31: 0] y
);
    // ============================================================
    // SBB implementation
    // ============================================================
    ari_execute_arithmetic_sbb u_impl (
        .operand_1  ( a  ),
        .operand_2  ( b  ),
        .carry_flag ( cf ),
        .result     ( y  )
    );
endmodule
