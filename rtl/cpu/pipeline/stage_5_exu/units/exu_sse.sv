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
//  File        : exu_sse.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : SSE execution unit wrapper
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_sse (
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    output logic [31: 0] o_xmm_result,
    output exu_result_t   o_result
);

    logic [31: 0] alu_result;

    sse_alu u_sse_alu (
        .i_op_addss (1'b1),
        .i_op_mulss (1'b0),
        .i_src1     (i_src1_data),
        .i_src2     (i_src2_data),
        .o_result   (alu_result)
    );

    assign o_xmm_result              = alu_result;
    assign o_result.result           = alu_result;
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
