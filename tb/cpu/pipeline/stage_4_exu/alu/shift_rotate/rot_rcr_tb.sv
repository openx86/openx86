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
//  File        : eu_rot_rcr_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_rot_rcr_tb module
// ============================================================================

`timescale 1ns/1ns

module rot_rcr_tb;
    logic [31: 0] a;
    logic [31: 0] c;
    logic        cf_in;
    logic [31: 0] y;
    logic        cf_out;

    alu_shift_rotate_rot_rcr u_dut (
        .a ( a ),
        .count ( c ),
        .cf_in ( cf_in ),
        .y ( y ),
        .cf_out ( cf_out )
    );

    initial begin
        a = 32'h0000_0001;
        c = 32'd1;
        cf_in = 1'b1;
        #1;
        if (y !== 32'h8000_0000 || cf_out !== 1'b1) begin
            $display("FAIL rot_rcr step1");
            $finish(1);
        end

        a = 32'h8000_0000;
        c = 32'd1;
        cf_in = 1'b0;
        #1;
        if (y !== 32'h4000_0000 || cf_out !== 1'b0) begin
            $display("FAIL rot_rcr step2");
            $finish(1);
        end

        $display("eu_rot_rcr_tb PASS");
        $finish;
    end
endmodule
