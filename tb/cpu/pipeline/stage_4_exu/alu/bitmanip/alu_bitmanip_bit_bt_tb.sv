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
//  File        : eu_bit_bt_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_bit_bt_tb module
// ============================================================================

`timescale 1ns/1ns

module bit_bt_tb;
    logic [31: 0] a;
    logic [31: 0] b;
    logic [31: 0] y;
    logic        cf;

    alu_bitmanip_bit_bt u_dut (
        .a ( a ),
        .bit_index ( b ),
        .y ( y ),
        .cf ( cf )
    );

    initial begin
        a = 32'h0000_0020;
        b = 32'd5;
        #1;
        if (cf !== 1'b1 || y !== a) begin
            $display("FAIL bit_bt bit1");
            $finish(1);
        end

        b = 32'd4;
        #1;
        if (cf !== 1'b0 || y !== a) begin
            $display("FAIL bit_bt bit0");
            $finish(1);
        end

        $display("eu_bit_bt_tb PASS");
        $finish;
    end
endmodule
