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
    input  logic [ 5: 0] i_x87_subop,
    input  logic [ 2: 0] i_sti_index,
    input  logic [31: 0] i_mem_data,
    input  logic [79: 0] i_st0,
    input  logic [79: 0] i_st1,
    input  logic [79: 0] i_st2,
    input  logic [79: 0] i_st3,
    input  logic [79: 0] i_st4,
    input  logic [79: 0] i_st5,
    input  logic [79: 0] i_st6,
    input  logic [79: 0] i_st7,
    input  logic [15: 0] i_fcw,
    input  logic [15: 0] i_fsw,
    output logic [79: 0] o_st0,
    output logic [79: 0] o_st1,
    output logic [79: 0] o_st2,
    output logic [79: 0] o_st3,
    output logic [79: 0] o_st4,
    output logic [79: 0] o_st5,
    output logic [79: 0] o_st6,
    output logic [79: 0] o_st7,
    output logic         o_st0_we,
    output logic         o_st1_we,
    output logic         o_st2_we,
    output logic         o_st3_we,
    output logic         o_st4_we,
    output logic         o_st5_we,
    output logic         o_st6_we,
    output logic         o_st7_we,
    output logic [15: 0] o_fsw,
    output logic         o_fsw_we,
    output logic         o_fpu_exception,
    output exu_result_t  o_result,
    input  logic         clk,
    input  logic         rst_n
);

    logic         mem_valid;
    logic         mem_we;
    logic [31: 0] mem_wdata;

    x87_fpu_core u_fpu (
        .i_valid             (i_valid),
        .i_x87_subop         (i_x87_subop),
        .i_sti_index         (i_sti_index),
        .i_mem_data          (i_mem_data),
        .i_st0               (i_st0),
        .i_st1               (i_st1),
        .i_st2               (i_st2),
        .i_st3               (i_st3),
        .i_st4               (i_st4),
        .i_st5               (i_st5),
        .i_st6               (i_st6),
        .i_st7               (i_st7),
        .i_fcw               (i_fcw),
        .i_fsw               (i_fsw),
        .o_st0               (o_st0),
        .o_st1               (o_st1),
        .o_st2               (o_st2),
        .o_st3               (o_st3),
        .o_st4               (o_st4),
        .o_st5               (o_st5),
        .o_st6               (o_st6),
        .o_st7               (o_st7),
        .o_st0_we            (o_st0_we),
        .o_st1_we            (o_st1_we),
        .o_st2_we            (o_st2_we),
        .o_st3_we            (o_st3_we),
        .o_st4_we            (o_st4_we),
        .o_st5_we            (o_st5_we),
        .o_st6_we            (o_st6_we),
        .o_st7_we            (o_st7_we),
        .o_fsw               (o_fsw),
        .o_fsw_we            (o_fsw_we),
        .o_fcw               (),
        .o_fcw_we            (),
        .o_stack_push        (),
        .o_stack_pop         (),
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
