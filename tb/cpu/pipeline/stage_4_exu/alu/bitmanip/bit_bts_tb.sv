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
//  File        : eu_bit_bts_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_bit_bts_tb module
// ============================================================================

`timescale 1ns/1ns

module bit_bts_tb;
    logic [31: 0] a;
    logic [31: 0] b;
    logic [31: 0] y;
    logic        cf;

    bit_bts u_dut (
        .a ( a ),
        .bit_index ( b ),
        .y ( y ),
        .cf ( cf )
    );

    initial begin
        a = 32'h0000_0000;
        b = 32'd3;
        #1;
        if (cf !== 1'b0 || y !== 32'h0000_0008) begin
            $display("FAIL bit_bts set");
            $finish(1);
        end

        a = y;
        #1;
        if (cf !== 1'b1 || y !== 32'h0000_0008) begin
            $display("FAIL bit_bts keep");
            $finish(1);
        end

        $display("eu_bit_bts_tb PASS");
        $finish;
    end
endmodule
