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
//  File        : eu_bit_bsr_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_bit_bsr_tb module
// ============================================================================

`timescale 1ns/1ns

module bit_bsr_tb;
    logic [31: 0] a;
    logic [31: 0] y;
    logic        zf;

    bit_bsr u_dut (
        .a ( a ),
        .y ( y ),
        .zf ( zf )
    );

    initial begin
        a = 32'h0000_0000; #1;
        if (zf !== 1'b1 || y !== 32'd0) begin
            $display("FAIL bit_bsr zero");
            $finish(1);
        end

        a = 32'h8010_0800; #1;
        if (zf !== 1'b0 || y !== 32'd31) begin
            $display("FAIL bit_bsr nonzero");
            $finish(1);
        end

        $display("eu_bit_bsr_tb PASS");
        $finish;
    end
endmodule
