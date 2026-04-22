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
//  File        : exu_bsr.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : BSR execution unit - bit scan reverse (find most significant set bit)
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_bsr (
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic [31: 0] i_immediate,
    input  logic         i_has_imm,
    output exu_result_t   o_result
);

    logic [31: 0] operand;
    logic [ 4: 0] bit_index;
    logic [31: 0] result;

    assign operand = i_src1_data;
    assign bit_index = 5'd0;

    always_comb begin
        if (operand != 32'd0) begin
            case (1'b1)
                operand[31]: bit_index = 5'd31;
                operand[30]: bit_index = 5'd30;
                operand[29]: bit_index = 5'd29;
                operand[28]: bit_index = 5'd28;
                operand[27]: bit_index = 5'd27;
                operand[26]: bit_index = 5'd26;
                operand[25]: bit_index = 5'd25;
                operand[24]: bit_index = 5'd24;
                operand[23]: bit_index = 5'd23;
                operand[22]: bit_index = 5'd22;
                operand[21]: bit_index = 5'd21;
                operand[20]: bit_index = 5'd20;
                operand[19]: bit_index = 5'd19;
                operand[18]: bit_index = 5'd18;
                operand[17]: bit_index = 5'd17;
                operand[16]: bit_index = 5'd16;
                operand[15]: bit_index = 5'd15;
                operand[14]: bit_index = 5'd14;
                operand[13]: bit_index = 5'd13;
                operand[12]: bit_index = 5'd12;
                operand[11]: bit_index = 5'd11;
                operand[10]: bit_index = 5'd10;
                operand[9]:  bit_index = 5'd9;
                operand[8]:  bit_index = 5'd8;
                operand[7]:  bit_index = 5'd7;
                operand[6]:  bit_index = 5'd6;
                operand[5]:  bit_index = 5'd5;
                operand[4]:  bit_index = 5'd4;
                operand[3]:  bit_index = 5'd3;
                operand[2]:  bit_index = 5'd2;
                operand[1]:  bit_index = 5'd1;
                operand[0]:  bit_index = 5'd0;
                default:  bit_index = 5'd0;
            endcase
        end
    end

    assign result = {27'd0, bit_index};

    assign o_result.result           = result;
    assign o_result.cf               = 1'b0;
    assign o_result.pf               = 1'b0;
    assign o_result.af               = 1'b0;
    assign o_result.zf               = (operand == 32'd0);
    assign o_result.sf               = 1'b0;
    assign o_result.of               = 1'b0;
    assign o_result.mem_valid        = 1'b0;
    assign o_result.mem_write_enable = 1'b0;
    assign o_result.mem_address      = 32'd0;
    assign o_result.mem_write_data   = 32'd0;

endmodule
