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
//  File        : exu_adc.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ADC execution unit - add with carry
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_adc (
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic [31: 0] i_immediate,
    input  logic         i_cf,
    input  logic         i_has_imm,
    output exu_result_t   o_result
);

    logic [31: 0] operand1;
    logic [31: 0] operand2;
    logic [31: 0] result;
    logic [32: 0] add_result;

    assign operand1 = i_src1_data;
    assign operand2 = i_has_imm ? i_immediate : i_src2_data;
    assign add_result = operand1 + operand2 + i_cf;
    assign result = add_result[31: 0];

    assign o_result.result           = result;
    assign o_result.cf               = add_result[32];
    assign o_result.pf               = compute_pf(result);
    assign o_result.af               = compute_af(operand1, operand2, 1'b0) | i_cf;
    assign o_result.zf               = compute_zf(result);
    assign o_result.sf               = compute_sf(result);
    assign o_result.of               = compute_of_adc(operand1, operand2, i_cf);
    assign o_result.mem_valid        = 1'b0;
    assign o_result.mem_write_enable = 1'b0;
    assign o_result.mem_address      = 32'd0;
    assign o_result.mem_write_data   = 32'd0;

endmodule
