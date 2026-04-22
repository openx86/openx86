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
//  File        : eu_misc_loop_ctrl_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_misc_loop_ctrl_tb module
// ============================================================================

`timescale 1ns/1ns

module eu_misc_loop_ctrl_tb;
    logic [31: 0] ecx;
    logic        zf;
    logic [ 1: 0] mode;
    logic [31: 0] ecx_next;
    logic        taken;

    misc_loop_ctrl u_dut (
        .ecx ( ecx ),
        .zf ( zf ),
        .mode ( mode ),
        .ecx_next ( ecx_next ),
        .taken ( taken )
    );

    task automatic check(input logic cond, input [127: 0] name);
        begin
            if (!cond) begin
                $display("FAIL misc_loop_ctrl %s", name);
                $finish(1);
            end
        end
    endtask

    initial begin
        ecx = 32'd2;
        zf = 1'b0;
        mode = 2'b00;
        #1;
        check(ecx_next == 32'd1, "LOOP decrement");
        check(taken == 1'b1, "LOOP taken");

        ecx = 32'd1;
        zf = 1'b0;
        mode = 2'b00;
        #1;
        check(ecx_next == 32'd0, "LOOP reaches zero");
        check(taken == 1'b0, "LOOP not taken at zero");

        ecx = 32'd2;
        zf = 1'b1;
        mode = 2'b01;
        #1;
        check(taken == 1'b1, "LOOPZ taken when ZF=1");

        ecx = 32'd2;
        zf = 1'b0;
        mode = 2'b01;
        #1;
        check(taken == 1'b0, "LOOPZ not taken when ZF=0");

        ecx = 32'd2;
        zf = 1'b0;
        mode = 2'b10;
        #1;
        check(taken == 1'b1, "LOOPNZ taken when ZF=0");

        ecx = 32'd2;
        zf = 1'b1;
        mode = 2'b10;
        #1;
        check(taken == 1'b0, "LOOPNZ not taken when ZF=1");

        ecx = 32'd0;
        zf = 1'b0;
        mode = 2'b11;
        #1;
        check(ecx_next == 32'd0, "JCXZ no decrement");
        check(taken == 1'b1, "JCXZ taken");

        ecx = 32'd5;
        zf = 1'b0;
        mode = 2'b11;
        #1;
        check(ecx_next == 32'd5, "JCXZ preserve ECX");
        check(taken == 1'b0, "JCXZ not taken");

        $display("eu_misc_loop_ctrl_tb PASS");
        $finish;
    end
endmodule
