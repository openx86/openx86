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
//  File        : exu_misc.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : MISC execution unit — CPUID, BSWAP, CBW/CWDE/CDQ, BCD
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_misc (
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic [31: 0] i_immediate,
    input  logic         i_has_imm,
    input  logic [31: 0] i_cpuid_eax,
    output exu_result_t  o_result
);

    logic [ 7: 0] subcode;
    logic [ 7: 0] al_in;
    logic [ 7: 0] ah_in;
    logic [ 7: 0] al_adj;
    logic [15: 0] ax_in;
    logic         af_in;
    logic         cf_in;

    // Unused until BCD uses src2 / has_imm fully
    // verilator lint_off UNUSEDSIGNAL
    logic unused_misc;
    assign unused_misc = |i_src2_data | i_has_imm;
    // verilator lint_on UNUSEDSIGNAL

    assign subcode = i_immediate[7: 0];
    assign al_in   = i_src1_data[ 7: 0];
    assign ah_in   = i_src1_data[15: 8];
    assign ax_in   = i_src1_data[15: 0];
    assign af_in   = 1'b0;
    assign cf_in   = 1'b0;

    always_comb begin
        o_result.result           = 32'd0;
        o_result.cf               = 1'b0;
        o_result.pf               = 1'b0;
        o_result.af               = 1'b0;
        o_result.zf               = 1'b0;
        o_result.sf               = 1'b0;
        o_result.of               = 1'b0;
        o_result.mem_valid        = 1'b0;
        o_result.mem_write_enable = 1'b0;
        o_result.mem_address      = 32'd0;
        o_result.mem_write_data   = 32'd0;
        al_adj                    = al_in;

        unique case (subcode)
            `MISC_SUB_BSWAP: begin
                o_result.result = {i_src1_data[ 7: 0], i_src1_data[15: 8],
                                   i_src1_data[23:16], i_src1_data[31:24]};
            end
            `MISC_SUB_CPUID: begin
                o_result.result = i_cpuid_eax;
            end
            `MISC_SUB_CBW: begin
                // AX := sign-extend AL
                o_result.result = {16'h0, {8{al_in[7]}}, al_in};
            end
            `MISC_SUB_CWDE: begin
                // EAX := sign-extend AX
                o_result.result = {{16{ax_in[15]}}, ax_in};
            end
            `MISC_SUB_CDQ: begin
                // EDX:EAX sign-extend — result is high half for EDX write path
                o_result.result = {32{i_src1_data[31]}};
            end
            `MISC_SUB_AAA: begin
                if ((al_in[3: 0] > 4'h9) | af_in) begin
                    al_adj = al_in + 8'h06;
                    o_result.result = {16'h0, ah_in + 8'h01, {4'h0, al_adj[3: 0]}};
                    o_result.af = 1'b1;
                    o_result.cf = 1'b1;
                end else begin
                    o_result.result = {16'h0, ah_in, {4'h0, al_in[3: 0]}};
                end
            end
            `MISC_SUB_AAS: begin
                if ((al_in[3: 0] > 4'h9) | af_in) begin
                    al_adj = al_in - 8'h06;
                    o_result.result = {16'h0, ah_in - 8'h01, {4'h0, al_adj[3: 0]}};
                    o_result.af = 1'b1;
                    o_result.cf = 1'b1;
                end else begin
                    o_result.result = {16'h0, ah_in, {4'h0, al_in[3: 0]}};
                end
            end
            `MISC_SUB_DAA: begin
                if ((al_in[3: 0] > 4'h9) | af_in) begin
                    al_adj      = al_in + 8'h06;
                    o_result.af = 1'b1;
                end
                if ((al_in > 8'h99) | cf_in) begin
                    al_adj      = al_adj + 8'h60;
                    o_result.cf = 1'b1;
                end
                o_result.result = {24'h0, al_adj};
                o_result.zf     = (al_adj == 8'h00);
                o_result.sf     = al_adj[7];
            end
            `MISC_SUB_DAS: begin
                if ((al_in[3: 0] > 4'h9) | af_in) begin
                    al_adj      = al_in - 8'h06;
                    o_result.af = 1'b1;
                end
                if ((al_in > 8'h99) | cf_in) begin
                    al_adj      = al_adj - 8'h60;
                    o_result.cf = 1'b1;
                end
                o_result.result = {24'h0, al_adj};
                o_result.zf     = (al_adj == 8'h00);
                o_result.sf     = al_adj[7];
            end
            `MISC_SUB_AAM: begin
                // AH := AL / 10; AL := AL % 10 (imm default 0x0A)
                o_result.result = {16'h0, al_in / 8'd10, al_in % 8'd10};
                o_result.zf     = ((al_in % 8'd10) == 8'h00);
                o_result.sf     = (al_in % 8'd10) >> 7;
            end
            `MISC_SUB_AAD: begin
                // AL := AH*10 + AL; AH := 0
                al_adj = (ah_in * 8'd10) + al_in;
                o_result.result = {24'h0, al_adj};
                o_result.zf     = (al_adj == 8'h00);
                o_result.sf     = al_adj[7];
            end
            default: ;
        endcase
    end

endmodule
