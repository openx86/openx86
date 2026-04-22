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
//  File        : log_and.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : log_and module
// ============================================================================

module log_and (
    // =========================
    // operands
    // =========================
    input  logic [31: 0]  a,
    input  logic [31: 0]  b,

    // =========================
    // output
    // =========================
    output logic [31: 0] y
);
    // ============================================================
    // AND implementation
    // ============================================================
    log_execute_logic_and u_impl (
        .operand_1 ( a ),
        .operand_2 ( b ),
        .result    ( y )
    );
endmodule
