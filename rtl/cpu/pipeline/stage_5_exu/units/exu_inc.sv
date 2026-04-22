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
//  File        : exu_inc.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : INC execution unit - increment by 1 (does not affect CF)
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_inc (
    input  logic [31: 0] i_src1_data,
    input  logic         i_cf,
    output exu_result_t   o_result
);

    logic [31: 0] operand;
    logic [31: 0] result;

    assign operand = i_src1_data;
    assign result = operand + 32'd1;

    assign o_result.result           = result;
    assign o_result.cf               = i_cf;
    assign o_result.pf               = compute_pf(result);
    assign o_result.af               = compute_af(operand, 32'd1, 1'b0);
    assign o_result.zf               = compute_zf(result);
    assign o_result.sf               = compute_sf(result);
    assign o_result.of               = compute_of_inc(operand);
    assign o_result.mem_valid        = 1'b0;
    assign o_result.mem_write_enable = 1'b0;
    assign o_result.mem_address      = 32'd0;
    assign o_result.mem_write_data   = 32'd0;

endmodule
