// ============================================================================
// Copyright (c) 2026 Chang Wei
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
// File : exu_cmp.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : CMP execution — sized subtract for flags only (no GPR write)
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_cmp (
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic [31: 0] i_immediate,
    input  logic         i_has_imm,
    input  logic [ 1: 0] i_mem_size,
    output exu_result_t  o_result
);

    logic [31: 0] operand1_raw;
    logic [31: 0] operand2_raw;
    logic [31: 0] operand1;
    logic [31: 0] operand2;
    logic [31: 0] result;

    assign operand1_raw = i_src1_data;
    assign operand2_raw = i_has_imm ? i_immediate : i_src2_data;

    always_comb begin
        unique case (i_mem_size)
            2'b00: begin
                operand1 = {24'h0, operand1_raw[7: 0]};
                operand2 = {24'h0, operand2_raw[7: 0]};
            end
            2'b01: begin
                operand1 = {16'h0, operand1_raw[15: 0]};
                operand2 = {16'h0, operand2_raw[15: 0]};
            end
            default: begin
                operand1 = operand1_raw;
                operand2 = operand2_raw;
            end
        endcase
    end

    assign result = operand1 - operand2;

    assign o_result.result           = 32'd0;
    assign o_result.cf               = compute_cf_sub(operand1, operand2);
    assign o_result.pf               = compute_pf(result);
    assign o_result.af               = compute_af(operand1, operand2, 1'b1);
    assign o_result.zf               = compute_zf(result);
    assign o_result.sf               = (i_mem_size == 2'b00) ? result[7] :
                                       (i_mem_size == 2'b01) ? result[15] : result[31];
    assign o_result.of               = compute_of_sub(operand1, operand2);
    assign o_result.mem_valid        = 1'b0;
    assign o_result.mem_write_enable = 1'b0;
    assign o_result.mem_address      = 32'd0;
    assign o_result.mem_write_data   = 32'd0;

endmodule
