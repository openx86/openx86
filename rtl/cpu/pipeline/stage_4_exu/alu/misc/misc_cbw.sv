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
//  File        : misc_cbw.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : misc_cbw module
// ============================================================================

module misc_cbw (
    // =========================
    // operand
    // =========================
    input  logic [31: 0]  a,

    // =========================
    // output
    // =========================
    output logic [31: 0] y
);
    // ============================================================
    // combinational logic: derive outputs
    // ============================================================
    always_comb begin : comb_cbw
        y = { { 16{ a[15] } }, a[15: 0] };
    end

endmodule
