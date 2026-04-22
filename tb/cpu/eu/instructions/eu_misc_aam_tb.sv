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
//  File        : eu_misc_aam_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_misc_aam_tb module
// ============================================================================

`timescale 1ns/1ns

module eu_misc_aam_tb;
    logic [31: 0] a;
    logic [31: 0] b;
    logic [31: 0] y;

    misc_aam u_dut (
        .a ( a ),
        .b ( b ),
        .y ( y )
    );

    initial begin
        a = 32'h0000_0017;
        b = 32'h0000_0000; // defaults to base 10
        #1;
        if (y !== 32'h0000_0203) begin
            $display("FAIL misc_aam base10");
            $finish(1);
        end

        a = 32'h0000_000E;
        b = 32'h0000_0004;
        #1;
        if (y !== 32'h0000_0302) begin
            $display("FAIL misc_aam base4");
            $finish(1);
        end

        $display("eu_misc_aam_tb PASS");
        $finish;
    end
endmodule
