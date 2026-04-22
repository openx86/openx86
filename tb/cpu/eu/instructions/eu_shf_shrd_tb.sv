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
//  File        : eu_shf_shrd_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_shf_shrd_tb module
// ============================================================================

`timescale 1ns/1ns

module eu_shf_shrd_tb;
    logic [31: 0] a;
    logic [31: 0] b;
    logic [31: 0] c;
    logic [31: 0] y;

    shf_shrd u_dut (
        .a ( a ),
        .b ( b ),
        .count ( c ),
        .y ( y )
    );

    initial begin
        a = 32'h1234_5678;
        b = 32'h9ABC_DEF0;
        c = 32'd4;
        #1;
        if (y !== 32'h0123_4567) begin
            $display("FAIL shf_shrd");
            $finish(1);
        end

        c = 32'd0;
        #1;
        if (y !== a) begin
            $display("FAIL shf_shrd count0");
            $finish(1);
        end

        $display("eu_shf_shrd_tb PASS");
        $finish;
    end
endmodule
