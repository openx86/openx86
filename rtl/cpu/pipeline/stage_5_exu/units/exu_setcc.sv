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
//  File        : exu_setcc.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : SETCC execution unit - set byte on condition
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_setcc (
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic [31: 0] i_immediate,
    input  logic         i_has_imm,
    input  logic [ 3: 0] i_tttn,
    input  logic         i_cf,
    input  logic         i_pf,
    input  logic         i_zf,
    input  logic         i_sf,
    input  logic         i_of,
    output exu_result_t  o_result
);

    logic         condition_met;
    logic [31: 0] result_full;

    assign condition_met = compute_condition(i_tttn, i_of, i_cf, i_zf, i_sf, i_pf);
    assign result_full   = condition_met ? 32'd1 : 32'd0;

    assign o_result.result           = result_full;
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
