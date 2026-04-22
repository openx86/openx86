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
//  File        : misc_daa.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : misc_daa module
// ============================================================================

module misc_daa (
    // =========================
    // operands
    // =========================
    input  logic [31: 0]  a,
    input  logic          af_in,
    input  logic          cf_in,

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

    // ============================================================
    // combinational logic: derive outputs
    // ============================================================
    always_comb begin : comb_daa
        al = a[ 7: 0];
        af_out = af_in;
        cf_out = cf_in;

        // 低半字节非 BCD 或 AF：加 6 并置 AF
        if (((al & 8'h0F) > 8'h09) || af_in) begin
            al = al + 8'h06;
            af_out = 1'b1;
        end

        // 高半字节越界或 CF：加 0x60 并置 CF
        if ((al > 8'h9F) || cf_in) begin
            al = al + 8'h60;
            cf_out = 1'b1;
        end

        y = { a[31:  8], al };
    end

endmodule
