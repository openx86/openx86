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
//  File        : eu_misc_stridx_step_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_misc_stridx_step_tb module
// ============================================================================

`timescale 1ns/1ns

module eu_misc_stridx_step_tb;
    logic [31: 0] idx;
    logic        df;
    logic [31: 0] y;

    misc_stridx_step u_dut (
        .idx ( idx ),
        .df ( df ),
        .y ( y )
    );

    task automatic check(input logic cond, input [127: 0] name);
        begin
            if (!cond) begin
                $display("FAIL misc_stridx_step %s", name);
                $finish(1);
            end
        end
    endtask

    initial begin
        idx = 32'h0000_1000;
        df = 1'b0;
        #1;
        check(y == 32'h0000_1001, "increment");

        idx = 32'h0000_1000;
        df = 1'b1;
        #1;
        check(y == 32'h0000_0FFF, "decrement");

        idx = 32'h0000_0000;
        df = 1'b1;
        #1;
        check(y == 32'hFFFF_FFFF, "underflow wrap");

        $display("eu_misc_stridx_step_tb PASS");
        $finish;
    end
endmodule
