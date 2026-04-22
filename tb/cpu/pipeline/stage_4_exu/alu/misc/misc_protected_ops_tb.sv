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
//  File        : eu_misc_protected_ops_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_misc_protected_ops_tb module
// ============================================================================

`timescale 1ns/1ns

module misc_protected_ops_tb;
    logic [31: 0] arpl_dst;
    logic [31: 0] arpl_src;
    logic [31: 0] arpl_y;
    logic        arpl_zf;

    logic [31: 0] lar_src;
    logic [31: 0] lar_y;
    logic        lar_zf;

    logic [31: 0] lsl_src;
    logic [31: 0] lsl_y;
    logic        lsl_zf;

    logic [31: 0] verr_selector;
    logic        verr_zf;

    misc_arpl u_arpl (
        .dst ( arpl_dst ),
        .src ( arpl_src ),
        .y ( arpl_y ),
        .zf ( arpl_zf )
    );

    misc_lar u_lar (
        .src ( lar_src ),
        .y ( lar_y ),
        .zf ( lar_zf )
    );

    misc_lsl u_lsl (
        .src ( lsl_src ),
        .y ( lsl_y ),
        .zf ( lsl_zf )
    );

    misc_verr u_verr (
        .selector ( verr_selector ),
        .zf ( verr_zf )
    );

    task automatic check(input logic cond, input [127: 0] name);
        begin
            if (!cond) begin
                $display("FAIL eu_misc_protected_ops %s", name);
                $finish(1);
            end
        end
    endtask

    initial begin
        arpl_dst = 32'h1234_5601;
        arpl_src = 32'h0000_0003;
        #1;
        check(arpl_y == 32'h1234_5603, "ARPL update");
        check(arpl_zf == 1'b1, "ARPL zf set");

        arpl_dst = 32'h89AB_CDEF;
        arpl_src = 32'h0000_0001;
        #1;
        check(arpl_y == 32'h89AB_CDEF, "ARPL keep");
        check(arpl_zf == 1'b0, "ARPL zf clear");

        lar_src = 32'hDEAD_BEEF;
        #1;
        check(lar_y == 32'h00AD_BE00, "LAR mask");
        check(lar_zf == 1'b1, "LAR zf");

        lsl_src = 32'h0000_0000;
        #1;
        check(lsl_y == 32'h000F_FFFF, "LSL limit");
        check(lsl_zf == 1'b1, "LSL zf");

        verr_selector = 32'h0000_0000;
        #1;
        check(verr_zf == 1'b0, "VERR zero selector");

        verr_selector = 32'h0000_00A8;
        #1;
        check(verr_zf == 1'b1, "VERR non-zero selector");

        $display("eu_misc_protected_ops_tb PASS");
        $finish;
    end
endmodule
