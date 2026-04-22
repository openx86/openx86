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
//  File        : eu_misc_movsx_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_misc_movsx_tb module
// ============================================================================

`timescale 1ns/1ns

module misc_movsx_tb;
    logic [31: 0] a;
    logic [ 1: 0] width;
    logic [31: 0] y;

    alu_misc_misc_movsx u_dut (
        .a ( a ),
        .width ( width ),
        .y ( y )
    );

    initial begin
        a = 32'h0000_0080;
        width = 2'b01;
        #1;
        if (y !== 32'hFFFF_FF80) begin
            $display("FAIL misc_movsx byte");
            $finish(1);
        end

        a = 32'h0000_8001;
        width = 2'b10;
        #1;
        if (y !== 32'hFFFF_8001) begin
            $display("FAIL misc_movsx word");
            $finish(1);
        end

        a = 32'h89AB_CDEF;
        width = 2'b11;
        #1;
        if (y !== 32'h89AB_CDEF) begin
            $display("FAIL misc_movsx dword");
            $finish(1);
        end

        $display("eu_misc_movsx_tb PASS");
        $finish;
    end
endmodule
