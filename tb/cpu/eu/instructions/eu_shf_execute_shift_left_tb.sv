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
//  File        : eu_shf_execute_shift_left_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_shf_execute_shift_left_tb module
// ============================================================================

`timescale 1ns/1ns

module eu_shf_execute_shift_left_tb;
    logic [31: 0] op, cnt, y;

    shf_execute_shift_left u_dut (
        .operand(op),
        .count(cnt),
        .result(y)
    );

    initial begin
        op = 32'h0000_0001; cnt = 32'd4; #1;
        if (y !== 32'h0000_0010) begin
            $display("FAIL shl");
            $finish(1);
        end
        $display("eu_shf_execute_shift_left_tb PASS");
        $finish;
    end
endmodule
