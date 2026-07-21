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
//  File        : exu_lea.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : LEA execution unit - load effective address
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_lea (
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic [31: 0] i_displacement,
    input  logic         i_agu_base,
    input  logic         i_agu_index,
    input  logic [ 1: 0] i_sib_scale,
    output exu_result_t   o_result
);

    logic [31: 0] effective_addr;
    logic [31: 0] index_term;

    assign index_term     = i_agu_index ? (i_src2_data << i_sib_scale) : 32'h0;
    assign effective_addr = (i_agu_base ? i_src1_data : 32'h0) +
                            index_term + i_displacement;

    assign o_result.result           = effective_addr;
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
