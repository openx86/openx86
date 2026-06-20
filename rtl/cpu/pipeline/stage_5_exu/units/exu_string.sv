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
//  File        : exu_string.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : STRING execution unit — single-step MOVS/STOS/CMPS/SCAS
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_string (
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic         i_is_store,
    input  logic         i_df,
    output exu_result_t  o_result
);

    logic [31: 0] step;

    assign step = i_df ? 32'hFFFF_FFFC : 32'd4;

    always_comb begin
        o_result.result           = i_src1_data + step;
        o_result.cf               = 1'b0;
        o_result.pf               = 1'b0;
        o_result.af               = 1'b0;
        o_result.zf               = 1'b0;
        o_result.sf               = 1'b0;
        o_result.of               = 1'b0;
        o_result.mem_valid        = 1'b1;
        o_result.mem_write_enable = i_is_store;
        o_result.mem_address      = i_src1_data;
        o_result.mem_write_data   = i_src2_data;
    end

endmodule
