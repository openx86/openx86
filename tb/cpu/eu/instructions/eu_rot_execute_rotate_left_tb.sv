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
//  File        : eu_rot_execute_rotate_left_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_rot_execute_rotate_left_tb module
// ============================================================================

`timescale 1ns/1ns

module eu_rot_execute_rotate_left_tb;
    logic [31: 0] op, cnt, y;

    rot_execute_rotate_left u_dut (
        .operand(op),
        .count(cnt),
        .result(y)
    );

    initial begin
        op = 32'h1234_5678; cnt = 32'd8; #1;
        if (y !== 32'h3456_7812) begin
            $display("FAIL rol");
            $finish(1);
        end
        $display("eu_rot_execute_rotate_left_tb PASS");
        $finish;
    end
endmodule
