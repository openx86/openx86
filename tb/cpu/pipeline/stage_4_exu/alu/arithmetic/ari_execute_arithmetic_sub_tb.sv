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
//  File        : eu_ari_execute_arithmetic_sub_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_ari_execute_arithmetic_sub_tb module
// ============================================================================

`timescale 1ns/1ns

module ari_execute_arithmetic_sub_tb;
    logic [31: 0] a, b, y;

    ari_execute_arithmetic_sub u_dut (
        .operand_1(a),
        .operand_2(b),
        .result(y)
    );

    initial begin
        a = 32'd9; b = 32'd4; #1;
        if (y !== 32'd5) begin
            $display("FAIL sub");
            $finish(1);
        end
        $display("eu_ari_execute_arithmetic_sub_tb PASS");
        $finish;
    end
endmodule
