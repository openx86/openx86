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
//  File        : misc_cdq.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : misc_cdq module
// ============================================================================

module misc_cdq (
    // =========================
    // Port Group: Operand
    // =========================
    input  logic [31: 0]  a,

    // =========================
    // Port Group: Output
    // =========================
    output logic [31: 0] y
);
    // ============================================================
    // Combinational Logic: Derive Outputs
    // ============================================================
    always_comb begin : comb_cdq
        y = a[31] ? 32'hFFFF_FFFF : 32'h0000_0000;
    end

endmodule
