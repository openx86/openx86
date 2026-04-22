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
//  File        : eu_misc_daa_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_misc_daa_tb module
// ============================================================================

`timescale 1ns/1ns

module misc_daa_tb;
    logic [31: 0] a;
    logic        af_in;
    logic        cf_in;
    logic [31: 0] y;
    logic        af_out;
    logic        cf_out;

    misc_daa u_dut (
        .a ( a ),
        .af_in ( af_in ),
        .cf_in ( cf_in ),
        .y ( y ),
        .af_out ( af_out ),
        .cf_out ( cf_out )
    );

    initial begin
        a = 32'h0000_009A;
        af_in = 1'b0;
        cf_in = 1'b0;
        #1;
        if ((y !== 32'h0000_0000) || (af_out !== 1'b1) || (cf_out !== 1'b1)) begin
            $display("FAIL misc_daa double-adjust");
            $finish(1);
        end

        a = 32'h0000_0015;
        af_in = 1'b0;
        cf_in = 1'b0;
        #1;
        if ((y !== 32'h0000_0015) || (af_out !== 1'b0) || (cf_out !== 1'b0)) begin
            $display("FAIL misc_daa no-adjust");
            $finish(1);
        end

        $display("eu_misc_daa_tb PASS");
        $finish;
    end
endmodule
