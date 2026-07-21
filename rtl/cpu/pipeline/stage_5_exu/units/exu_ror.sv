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
// File : exu_ror.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : ROR execution unit - width-correct rotate right
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_ror (
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic [31: 0] i_immediate,
    input  logic         i_has_imm,
    input  logic [ 1: 0] i_mem_size,
    output exu_result_t   o_result
);

    logic [ 4: 0] shift_count;
    logic [31: 0] result;
    logic [ 5: 0] width;
    logic [ 5: 0] eff;
    logic [31: 0] op8;
    logic [31: 0] op16;
    logic [31: 0] op32;

    assign shift_count = i_has_imm ? i_immediate[4: 0] : i_src2_data[4: 0];
    assign op8  = {24'h0, i_src1_data[7: 0]};
    assign op16 = {16'h0, i_src1_data[15: 0]};
    assign op32 = i_src1_data;

    always_comb begin
        unique case (i_mem_size)
            2'b00: begin
                width = 6'd8;
                eff = (shift_count == 5'd0) ? 6'd0 : {1'b0, shift_count} % 6'd8;
                result = (eff == 6'd0) ? op8 :
                         ((op8 >> eff) | (op8 << (6'd8 - eff)));
            end
            2'b01: begin
                width = 6'd16;
                eff = (shift_count == 5'd0) ? 6'd0 : {1'b0, shift_count} % 6'd16;
                result = (eff == 6'd0) ? op16 :
                         ((op16 >> eff) | (op16 << (6'd16 - eff)));
            end
            default: begin
                width = 6'd32;
                eff = (shift_count == 5'd0) ? 6'd0 : {1'b0, shift_count};
                result = (eff == 6'd0) ? op32 :
                         ((op32 >> eff) | (op32 << (6'd32 - eff)));
            end
        endcase
    end

    assign o_result.result           = result;
    assign o_result.cf               = (eff != 6'd0) ?
                                       ((i_mem_size == 2'b00) ? result[7] :
                                        (i_mem_size == 2'b01) ? result[15] : result[31]) : 1'b0;
    assign o_result.pf               = 1'b0;
    assign o_result.af               = 1'b0;
    assign o_result.zf               = 1'b0;
    assign o_result.sf               = 1'b0;
    assign o_result.of               = (eff == 6'd1) ?
                                       ((i_mem_size == 2'b00) ? (result[7] ^ result[6]) :
                                        (i_mem_size == 2'b01) ? (result[15] ^ result[14]) :
                                        (result[31] ^ result[30])) : 1'b0;
    assign o_result.mem_valid        = 1'b0;
    assign o_result.mem_write_enable = 1'b0;
    assign o_result.mem_address      = 32'd0;
    assign o_result.mem_write_data   = 32'd0;

endmodule
