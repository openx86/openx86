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
//  File        : eu_shf_execute_shift_right_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_shf_execute_shift_right_tb module
// ============================================================================

`timescale 1ns/1ns

module shf_execute_shift_right_tb;
    logic [31: 0] op, cnt, is_signed, y;

    shf_execute_shift_right u_dut (
        .operand   (op),
        .count     (cnt),
        .is_signed (is_signed),
        .result    (y)
    );

    initial begin
        op = 32'h8000_0000; cnt = 32'd1; is_signed = 32'd0; #1;
        if (y !== 32'h4000_0000) begin
            $display("FAIL shr");
            $finish(1);
        end
        op = 32'h8000_0000; cnt = 32'd1; is_signed = 32'd1; #1;
        if (y !== 32'hC000_0000) begin
            $display("FAIL sar");
            $finish(1);
        end
        $display("eu_shf_execute_shift_right_tb PASS");
        $finish;
    end
endmodule
