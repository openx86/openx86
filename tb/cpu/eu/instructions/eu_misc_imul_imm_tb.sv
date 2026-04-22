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
//  File        : eu_misc_imul_imm_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_misc_imul_imm_tb module
// ============================================================================

`timescale 1ns/1ns

module eu_misc_imul_imm_tb;
    logic [31: 0] a;
    logic [31: 0] b;
    logic [31: 0] y;
    logic        overflow;

    misc_imul_imm u_dut (
        .a ( a ),
        .b ( b ),
        .y ( y ),
        .overflow ( overflow )
    );

    task automatic check(input logic cond, input [127: 0] name);
        begin
            if (!cond) begin
                $display("FAIL misc_imul_imm %s", name);
                $finish(1);
            end
        end
    endtask

    initial begin
        a = 32'd7;
        b = -32'sd3;
        #1;
        check(y == -32'sd21, "7 * -3 result");
        check(overflow == 1'b0, "7 * -3 overflow");

        a = 32'h7FFF_FFFF;
        b = 32'd2;
        #1;
        check(y == 32'hFFFF_FFFE, "max_pos * 2 low32");
        check(overflow == 1'b1, "max_pos * 2 overflow");

        a = 32'hFFFF_FFFF;
        b = 32'd1;
        #1;
        check(y == 32'hFFFF_FFFF, "-1 * 1 result");
        check(overflow == 1'b0, "-1 * 1 overflow");

        $display("eu_misc_imul_imm_tb PASS");
        $finish;
    end
endmodule
