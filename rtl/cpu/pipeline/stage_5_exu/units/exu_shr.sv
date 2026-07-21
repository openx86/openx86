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
// File : exu_shr.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : SHR execution unit - shift right logical
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_shr (
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic [31: 0] i_immediate,
    input  logic         i_has_imm,
    input  logic [ 1: 0] i_mem_size,
    output exu_result_t   o_result
);

    logic [31: 0] operand;
    logic [ 4: 0] shift_count;
    logic [31: 0] result;

    // Width mask: sibling bytes in parent GPR must not participate (SHR CL / SHR AX).
    always_comb begin
        unique case (i_mem_size)
            2'b00:   operand = {24'h0, i_src1_data[7: 0]};
            2'b01:   operand = {16'h0, i_src1_data[15: 0]};
            default: operand = i_src1_data;
        endcase
    end
    assign shift_count = i_has_imm ? i_immediate[4: 0] : i_src2_data[4: 0];
    assign result = operand >> shift_count;

    assign o_result.result           = result;
    assign o_result.cf               = (shift_count != 5'd0) ? operand[shift_count - 1'b1] : 1'b0;
    assign o_result.pf               = (shift_count != 5'd0) ? compute_pf(result) : 1'b0;
    assign o_result.af               = 1'b0;
    assign o_result.zf               = (shift_count != 5'd0) ? compute_zf(result) : 1'b0;
    assign o_result.sf               = (shift_count != 5'd0) ? compute_sf(result) : 1'b0;
    assign o_result.of               = (shift_count == 5'd1) ?
                                       ((i_mem_size == 2'b00) ? operand[7] :
                                        (i_mem_size == 2'b01) ? operand[15] : operand[31]) : 1'b0;
    assign o_result.mem_valid        = 1'b0;
    assign o_result.mem_write_enable = 1'b0;
    assign o_result.mem_address      = 32'd0;
    assign o_result.mem_write_data   = 32'd0;

endmodule
