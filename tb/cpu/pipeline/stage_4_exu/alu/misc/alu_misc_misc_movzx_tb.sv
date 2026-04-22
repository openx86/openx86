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
//  File        : eu_misc_movzx_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_misc_movzx_tb module
// ============================================================================

`timescale 1ns/1ns

module misc_movzx_tb;
    logic [31: 0] a;
    logic [ 1: 0] width;
    logic [31: 0] y;

    alu_misc_misc_movzx u_dut (
        .a ( a ),
        .width ( width ),
        .y ( y )
    );

    initial begin
        a = 32'h0000_00FF;
        width = 2'b01;
        #1;
        if (y !== 32'h0000_00FF) begin
            $display("FAIL misc_movzx byte");
            $finish(1);
        end

        a = 32'h0000_FF01;
        width = 2'b10;
        #1;
        if (y !== 32'h0000_FF01) begin
            $display("FAIL misc_movzx word");
            $finish(1);
        end

        a = 32'h89AB_CDEF;
        width = 2'b11;
        #1;
        if (y !== 32'h89AB_CDEF) begin
            $display("FAIL misc_movzx dword");
            $finish(1);
        end

        $display("eu_misc_movzx_tb PASS");
        $finish;
    end
endmodule
