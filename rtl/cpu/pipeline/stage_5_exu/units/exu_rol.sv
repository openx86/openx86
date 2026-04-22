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
//  File        : exu_rol.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ROL execution unit - rotate left
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_rol (
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic [31: 0] i_immediate,
    input  logic         i_has_imm,
    output exu_result_t   o_result
);

    logic [31: 0] operand;
    logic [ 4: 0] shift_count;
    logic [31: 0] result;
    logic [ 5: 0] effective_shift;

    assign operand = i_src1_data;
    assign shift_count = i_has_imm ? i_immediate[4: 0] : i_src2_data[4: 0];
    assign effective_shift = shift_count[4: 0] == 5'd0 ? 6'd0 : (shift_count[4: 0] % 6'd32);
    assign result = (operand << effective_shift) | (operand >> (6'd32 - effective_shift));

    assign o_result.result           = result;
    assign o_result.cf               = (effective_shift != 6'd0) ? result[0] : 1'b0;
    assign o_result.pf               = 1'b0;
    assign o_result.af               = 1'b0;
    assign o_result.zf               = 1'b0;
    assign o_result.sf               = 1'b0;
    assign o_result.of               = (effective_shift == 6'd1) ? (result[31] ^ operand[31]) : 1'b0;
    assign o_result.mem_valid        = 1'b0;
    assign o_result.mem_write_enable = 1'b0;
    assign o_result.mem_address      = 32'd0;
    assign o_result.mem_write_data   = 32'd0;

endmodule
