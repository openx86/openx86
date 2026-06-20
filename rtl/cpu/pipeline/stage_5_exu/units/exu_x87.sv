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
//  File        : exu_x87.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : X87 execution unit — delegates to x87_fpu_core
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module exu_x87 (
    input  logic         i_valid,
    input  logic [ 4: 0] i_x87_subop,
    input  logic [ 2: 0] i_sti_index,
    input  logic [31: 0] i_mem_data,
    input  logic [79: 0] i_st0,
    input  logic [79: 0] i_st1,
    output logic [79: 0] o_st0,
    output logic [79: 0] o_st1,
    output logic         o_fpu_exception,
    output exu_result_t  o_result,
    input  logic         clk,
    input  logic         rst_n
);

    logic mem_valid;
    logic mem_we;
    logic [31: 0] mem_wdata;

    x87_fpu_core u_fpu (
        .i_valid             (i_valid),
        .i_x87_subop         (i_x87_subop),
        .i_sti_index         (i_sti_index),
        .i_mem_data          (i_mem_data),
        .i_st0               (i_st0),
        .i_st1               (i_st1),
        .o_st0               (o_st0),
        .o_st1               (o_st1),
        .o_stack_push        (),
        .o_stack_pop           (),
        .o_mem_valid         (mem_valid),
        .o_mem_write_enable  (mem_we),
        .o_mem_wdata         (mem_wdata),
        .o_fpu_exception     (o_fpu_exception),
        .clk                 (clk),
        .rst_n               (rst_n)
    );

    assign o_result.result           = 32'd0;
    assign o_result.cf               = 1'b0;
    assign o_result.pf               = 1'b0;
    assign o_result.af               = 1'b0;
    assign o_result.zf               = 1'b0;
    assign o_result.sf               = 1'b0;
    assign o_result.of               = 1'b0;
    assign o_result.mem_valid        = mem_valid;
    assign o_result.mem_write_enable = mem_we;
    assign o_result.mem_address      = 32'd0;
    assign o_result.mem_write_data   = mem_wdata;

endmodule
