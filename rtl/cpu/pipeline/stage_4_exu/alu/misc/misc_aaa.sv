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
//  File        : misc_aaa.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : misc_aaa module
// ============================================================================

module misc_aaa (
    // =========================
    // operands
    // =========================
    input  logic [31: 0]  a,
    input  logic          af_in,

    // =========================
    // outputs
    // =========================
    output logic [31: 0] y,
    output logic         af_out,
    output logic         cf_out
);
    // ============================================================
    // intermediate signals
    // ============================================================
    logic [ 7: 0] al;
    logic [ 7: 0] ah;

    // ============================================================
    // combinational logic: derive outputs
    // ============================================================
    always_comb begin : comb_aaa
        al = a[ 7: 0];
        ah = a[15:  8];

        if (((al & 8'h0F) > 8'h09) || af_in) begin
            al = (al + 8'h06) & 8'h0F;
            ah = ah + 8'h01;
            af_out = 1'b1;
            cf_out = 1'b1;
        end else begin
            al = al & 8'h0F;
            af_out = 1'b0;
            cf_out = 1'b0;
        end

        y = { a[31: 16], ah, al };
    end

endmodule
