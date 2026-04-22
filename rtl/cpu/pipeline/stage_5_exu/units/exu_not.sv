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
//  File        : exu_not.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : NOT execution unit - bitwise NOT (one's complement)
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_not (
    input  logic [31: 0] i_src1_data,
    output exu_result_t   o_result
);

    logic [31: 0] operand;
    logic [31: 0] result;

    assign operand = i_src1_data;
    assign result = ~operand;

    assign o_result.result           = result;
    assign o_result.cf               = 1'b0;
    assign o_result.pf               = compute_pf(result);
    assign o_result.af               = 1'b0;
    assign o_result.zf               = compute_zf(result);
    assign o_result.sf               = compute_sf(result);
    assign o_result.of               = 1'b0;
    assign o_result.mem_valid        = 1'b0;
    assign o_result.mem_write_enable = 1'b0;
    assign o_result.mem_address      = 32'd0;
    assign o_result.mem_write_data   = 32'd0;

endmodule
