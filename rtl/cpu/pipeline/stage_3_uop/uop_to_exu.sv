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
//  File        : uop_to_exu.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Pipeline register from stage_3_uop to stage_4_exu
// ============================================================================

`include "openx86_defs.h.sv"

module uop_to_exu (
    // =========================
    // Stage 3 inputs (from FIFO output)
    // =========================
    input  logic                i_uop_valid,
    input  micro_op_t           i_uop,

    // =========================
    // Stage 4 handshake (to EXU)
    // =========================
    input  logic                i_exu_ready,
    output logic                o_stage3_ready,
    output logic                o_uop_valid,
    output micro_op_t           o_uop,

    // =========================
    // Pipeline control
    // =========================
    input  logic                i_flush,

    // =========================
    // Clock and reset
    // =========================
    input  logic                clk,
    input  logic                rst_n
);

    // ============================================================
    // Pipeline register: latch when downstream is ready
    // ============================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_uop_valid <= 1'b0;
            o_uop       <= '0;
        end else if (i_flush) begin
            o_uop_valid <= 1'b0;
        end else if (i_exu_ready) begin
            o_uop_valid <= i_uop_valid;
            o_uop       <= i_uop;
        end
    end

    // ============================================================
    // Back-pressure: stage 3 can push when EXU is ready
    // ============================================================
    assign o_stage3_ready = i_exu_ready;

endmodule
