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
//  File        : exu_imul.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : IMUL execution unit - signed multiplication
//                Result in EDX:EAX, CF/OF set if sign extension needed
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_imul (
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    output exu_result_t   o_result,
    output logic [31: 0] o_result_high
);

    logic signed [31: 0] operand1;
    logic signed [31: 0] operand2;
    logic signed [63: 0] result;
    logic [31: 0] result_low;
    logic [31: 0] result_high;

    assign operand1 = $signed(i_src1_data);
    assign operand2 = $signed(i_src2_data);
    assign result = operand1 * operand2;
    assign result_low  = result[31: 0];
    assign result_high = result[63: 32];

    assign o_result.result           = result_low;
    assign o_result_high              = result_high;
    assign o_result.cf               = (result_high != {32{result_low[31]}});
    assign o_result.pf               = 1'b0;
    assign o_result.af               = 1'b0;
    assign o_result.zf               = 1'b0;
    assign o_result.sf               = 1'b0;
    assign o_result.of               = (result_high != {32{result_low[31]}});
    assign o_result.mem_valid        = 1'b0;
    assign o_result.mem_write_enable = 1'b0;
    assign o_result.mem_address      = 32'd0;
    assign o_result.mem_write_data   = 32'd0;

endmodule
