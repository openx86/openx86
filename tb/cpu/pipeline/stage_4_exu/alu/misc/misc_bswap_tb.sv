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
//  File        : eu_misc_bswap_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_misc_bswap_tb module
// ============================================================================

`timescale 1ns/1ns

module misc_bswap_tb;
    logic [31: 0] a;
    logic [31: 0] y;

    misc_bswap u_dut (
        .a ( a ),
        .y ( y )
    );

    initial begin
        a = 32'h1234_5678;
        #1;
        if (y !== 32'h7856_3412) begin
            $display("FAIL misc_bswap");
            $finish(1);
        end

        $display("eu_misc_bswap_tb PASS");
        $finish;
    end
endmodule
