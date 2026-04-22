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
//  File        : eu_misc_setcc_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : eu_misc_setcc_tb module
// ============================================================================

`timescale 1ns/1ns

module misc_setcc_tb;
    logic [31: 0] flags;
    logic [ 3: 0] tttn;
    logic [31: 0] y;

    alu_misc_misc_setcc u_dut (
        .flags ( flags ),
        .tttn ( tttn ),
        .y ( y )
    );

    task automatic check_bit(input logic expected, input [127: 0] name);
        begin
            #1;
            if (y[0] !== expected) begin
                $display("FAIL misc_setcc %s", name);
                $finish(1);
            end
        end
    endtask

    initial begin
        // CF=1, PF=0, ZF=1, SF=0, OF=1
        flags = 32'h0000_0841;

        tttn = 4'h0; check_bit(1'b1, "O");
        tttn = 4'h1; check_bit(1'b0, "NO");
        tttn = 4'h2; check_bit(1'b1, "B");
        tttn = 4'h3; check_bit(1'b0, "NB");
        tttn = 4'h6; check_bit(1'b1, "BE");
        tttn = 4'h7; check_bit(1'b0, "NBE");
        tttn = 4'hC; check_bit(1'b1, "L");
        tttn = 4'hD; check_bit(1'b0, "NL");
        tttn = 4'hE; check_bit(1'b1, "LE");
        tttn = 4'hF; check_bit(1'b0, "NLE");

        // CF=0, PF=1, ZF=0, SF=1, OF=0
        flags = 32'h0000_0084;

        tttn = 4'h8; check_bit(1'b1, "S");
        tttn = 4'h9; check_bit(1'b0, "NS");
        tttn = 4'hA; check_bit(1'b1, "P");
        tttn = 4'hB; check_bit(1'b0, "NP");

        $display("eu_misc_setcc_tb PASS");
        $finish;
    end
endmodule
