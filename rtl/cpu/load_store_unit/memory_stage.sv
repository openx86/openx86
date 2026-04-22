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
//  File        : memory_stage.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : memory_stage module
// ============================================================================

module memory_stage (
    // =========================
    // pipeline stage interface
    // =========================
    input  logic          i_stage3_valid,
    output logic          o_stage_valid,
    output logic          o_stage_ready,

    // =========================
    // access interface
    // =========================
    input  logic          i_start,
    input  logic          i_is_store,
    input  logic [31: 0] i_addr,
    input  logic [31: 0] i_wdata,
    output logic [31: 0] o_rdata,
    output logic          o_done,
    output logic          o_busy,

    // =========================
    // downstream memory port
    // =========================
    output logic          o_mem_valid,
    output logic          o_mem_we,
    output logic [31: 0] o_mem_addr,
    output logic [31: 0] o_mem_wdata,
    input  logic [31: 0] i_mem_rdata,
    input  logic          i_mem_ready,

    // =========================
    // clock and reset
    // =========================
    input  logic          clk,
    input  logic          rst_n
);

    // ============================================================
    // delegate LSU timing and downstream memory interface details
    // ============================================================
    access_memory u_am_access_memory (
        .clk         (clk),
        .rst_n       (rst_n),
        .i_start     (i_start),
        .i_is_store  (i_is_store),
        .i_addr      (i_addr),
        .i_wdata     (i_wdata),
        .o_rdata     (o_rdata),
        .o_done      (o_done),
        .o_busy      (o_busy),
        .o_mem_valid (o_mem_valid),
        .o_mem_we    (o_mem_we),
        .o_mem_addr  (o_mem_addr),
        .o_mem_wdata (o_mem_wdata),
        .i_mem_rdata (i_mem_rdata),
        .i_mem_ready (i_mem_ready)
    );

    // ============================================================
    // stage control logic
    // ============================================================
    assign o_stage_ready = ~o_busy;

    // MEM stage valid: upstream valid and transaction initiated or completed
    assign o_stage_valid = i_stage3_valid & (o_busy | o_done);

endmodule
