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
//  File        : exu_div.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : DIV execution unit - unsigned division
//                Dividend in EDX:EAX, divisor in operand
//                Quotient in EAX, remainder in EDX
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_div (
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic [63: 0] i_dividend,
    output exu_result_t   o_result,
    output logic [31: 0] o_result_high
);

    logic [31: 0] divisor;
    logic [31: 0] quotient;
    logic [31: 0] remainder;

    assign divisor = i_src1_data;
    assign quotient  = (divisor != 32'd0) ? (i_dividend / divisor) : 32'd0;
    assign remainder = (divisor != 32'd0) ? (i_dividend % divisor) : 32'd0;

    assign o_result.result           = quotient;
    assign o_result_high              = remainder;
    assign o_result.cf               = 1'b0;
    assign o_result.pf               = 1'b0;
    assign o_result.af               = 1'b0;
    assign o_result.zf               = 1'b0;
    assign o_result.sf               = 1'b0;
    assign o_result.of               = 1'b0;
    assign o_result.mem_valid        = 1'b0;
    assign o_result.mem_write_enable = 1'b0;
    assign o_result.mem_address      = 32'd0;
    assign o_result.mem_write_data   = 32'd0;

endmodule
