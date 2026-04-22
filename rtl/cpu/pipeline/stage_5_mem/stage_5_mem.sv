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
//  File        : stage_5_mem.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_5_mem module
// ============================================================================

module stage_5_mem (
    input  logic          i_stage3_valid,
    output logic          o_stage3_ready,

    input  logic          i_start,
    input  logic          i_is_store,
    input  logic [31: 0]  i_addr,
    input  logic [31: 0]  i_wdata,

    input  logic [31: 0]  i_mem_rdata,
    input  logic          i_mem_ready,

    output logic [31: 0]  o_lsu_rdata,
    output logic          o_lsu_done,
    output logic          o_lsu_busy,

    output logic          o_stage4_valid,
    input  logic          i_wrb_ready,
    output logic          o_mem_valid,
    output logic          o_mem_write_enable,
    output logic [31: 0]  o_mem_address,
    output logic [31: 0]  o_mem_write_data,

    input  logic          i_flush,
    input  logic          clk, // 时钟信号
    input  logic          rst_n // 复位信号
);

    logic        s34_stage3_valid;
    logic        s34_start;
    logic        s34_is_store;
    logic [31: 0] s34_addr;
    logic [31: 0] s34_wdata;
    logic [31: 0] s34_mem_rdata;
    logic        s34_mem_ready;
    logic        s34_stage_ready;

    logic        stage4_valid_from_mem;
    logic        mem_valid_from_mem;
    logic        mem_write_enable_from_mem;
    logic [31: 0] mem_address_from_mem;
    logic [31: 0] mem_write_data_from_mem;

    /* verilator lint_off PINCONNECTEMPTY */
    exe_to_mem u_stage_4_mem_exe_to_mem (
        .i_stage3_valid    ( i_stage3_valid ),
        .o_stage3_valid    ( s34_stage3_valid ),
        .i_mem_stage_ready ( s34_stage_ready ),
        .o_exe_ready       ( ),
        .i_start           ( i_start ),
        .o_start           ( s34_start ),
        .i_is_store        ( i_is_store ),
        .o_is_store        ( s34_is_store ),
        .i_addr            ( i_addr ),
        .o_addr            ( s34_addr ),
        .i_wdata           ( i_wdata ),
        .o_wdata           ( s34_wdata ),
        .i_mem_rdata       ( i_mem_rdata ),
        .o_mem_rdata       ( s34_mem_rdata ),
        .i_mem_ready       ( i_mem_ready ),
        .o_mem_ready       ( s34_mem_ready ),
        .i_flush           ( i_flush ),
        .clk               ( clk ),
        .rst_n             ( rst_n )
    );

    memory_stage u_stage_4_mem_main (
        .i_stage3_valid ( s34_stage3_valid ),
        .o_stage_valid  ( stage4_valid_from_mem ),
        .o_stage_ready  ( s34_stage_ready ),
        .i_start        ( s34_start ),
        .i_is_store     ( s34_is_store ),
        .i_addr         ( s34_addr ),
        .i_wdata        ( s34_wdata ),
        .o_rdata        ( o_lsu_rdata ),
        .o_done         ( o_lsu_done ),
        .o_busy         ( o_lsu_busy ),
        .o_mem_valid    ( mem_valid_from_mem ),
        .o_mem_we       ( mem_write_enable_from_mem ),
        .o_mem_addr     ( mem_address_from_mem ),
        .o_mem_wdata    ( mem_write_data_from_mem ),
        .i_mem_rdata    ( s34_mem_rdata ),
        .i_mem_ready    ( s34_mem_ready ),
        .clk            ( clk ),
        .rst_n          ( rst_n )
    );

    mem_to_wrb u_stage_4_mem_to_wrb (
        .i_stage4_valid      ( stage4_valid_from_mem ),
        .o_stage4_valid      ( o_stage4_valid ),
        .i_wrb_ready         ( i_wrb_ready ),
        .o_mem_ready         ( ),
        .i_mem_valid         ( mem_valid_from_mem ),
        .o_mem_valid         ( o_mem_valid ),
        .i_mem_write_enable  ( mem_write_enable_from_mem ),
        .o_mem_write_enable  ( o_mem_write_enable ),
        .i_mem_address       ( mem_address_from_mem ),
        .o_mem_address       ( o_mem_address ),
        .i_mem_write_data    ( mem_write_data_from_mem ),
        .o_mem_write_data    ( o_mem_write_data ),
        .i_flush             ( i_flush ),
        .clk                 ( clk ),
        .rst_n               ( rst_n )
    );
    /* verilator lint_on PINCONNECTEMPTY */

    assign o_stage3_ready = s34_stage_ready;

endmodule
