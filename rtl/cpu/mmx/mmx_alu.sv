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
//  File        : mmx_alu.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : MMX packed integer ALU
// ============================================================================

module mmx_alu (
    input  logic         i_op_paddb,
    input  logic         i_op_pand,
    input  logic         i_op_por,
    input  logic         i_op_pxor,
    input  logic [63: 0] i_src1,
    input  logic [63: 0] i_src2,
    output logic [63: 0] o_result
);

    logic [63: 0] paddb_result;
    logic [ 7: 0] byte0;
    logic [ 7: 0] byte1;
    logic [ 7: 0] byte2;
    logic [ 7: 0] byte3;
    logic [ 7: 0] byte4;
    logic [ 7: 0] byte5;
    logic [ 7: 0] byte6;
    logic [ 7: 0] byte7;

    assign byte0 = i_src1[ 7: 0] + i_src2[ 7: 0];
    assign byte1 = i_src1[15: 8] + i_src2[15: 8];
    assign byte2 = i_src1[23:16] + i_src2[23:16];
    assign byte3 = i_src1[31:24] + i_src2[31:24];
    assign byte4 = i_src1[39:32] + i_src2[39:32];
    assign byte5 = i_src1[47:40] + i_src2[47:40];
    assign byte6 = i_src1[55:48] + i_src2[55:48];
    assign byte7 = i_src1[63:56] + i_src2[63:56];
    assign paddb_result = {byte7, byte6, byte5, byte4, byte3, byte2, byte1, byte0};

    always_comb begin
        o_result = i_src1;
        if (i_op_paddb) begin
            o_result = paddb_result;
        end else if (i_op_pand) begin
            o_result = i_src1 & i_src2;
        end else if (i_op_por) begin
            o_result = i_src1 | i_src2;
        end else if (i_op_pxor) begin
            o_result = i_src1 ^ i_src2;
        end
    end

endmodule
