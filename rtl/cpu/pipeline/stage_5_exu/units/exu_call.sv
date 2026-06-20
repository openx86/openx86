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
//  File        : exu_call.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : CALL execution unit - call subroutine
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_call (
    input  logic [31: 0] i_src1_data,
    input  logic [31: 0] i_src2_data,
    input  logic [31: 0] i_immediate,
    input  logic [31: 0] i_displacement,
    input  logic         i_has_imm,
    input  logic         i_has_disp,
    output exu_result_t  o_result
);

    logic [31: 0] return_addr;
    logic [31: 0] new_esp;

    assign return_addr = i_src1_data;
    assign new_esp     = i_src2_data - 32'd4;

    assign o_result.result           = new_esp;
    assign o_result.cf               = 1'b0;
    assign o_result.pf               = 1'b0;
    assign o_result.af               = 1'b0;
    assign o_result.zf               = 1'b0;
    assign o_result.sf               = 1'b0;
    assign o_result.of               = 1'b0;
    assign o_result.mem_valid        = 1'b1;
    assign o_result.mem_write_enable = 1'b1;
    assign o_result.mem_address      = new_esp;
    assign o_result.mem_write_data   = return_addr;

endmodule
