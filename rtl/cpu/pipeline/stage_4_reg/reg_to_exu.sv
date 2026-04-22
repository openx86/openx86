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
//  File        : reg_to_exu.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Pipeline register: stage_4_reg_read → stage_5_exu
//                Passes micro_op_t and operand data to execution stage
// ============================================================================

`include "openx86_defs.h.sv"

module reg_to_exu (
    // =========================
    // Micro-op and operand inputs from stage_4_reg_read
    // =========================
    input  logic                i_uop_valid,
    input  micro_op_t           i_uop,
    input  logic [31: 0]        i_src1_data,
    input  logic [31: 0]        i_src2_data,

    // =========================
    // Flag inputs from stage_4_reg_read
    // =========================
    input  logic                i_flag_cf,
    input  logic                i_flag_pf,
    input  logic                i_flag_af,
    input  logic                i_flag_zf,
    input  logic                i_flag_sf,
    input  logic                i_flag_of,

    // =========================
    // Stage 5 handshake (to EXU)
    // =========================
    input  logic                i_exu_ready,
    output logic                o_stage4_ready,
    output logic                o_uop_valid,
    output micro_op_t           o_uop,
    output logic [31: 0]        o_src1_data,
    output logic [31: 0]        o_src2_data,
    output logic                o_flag_cf,
    output logic                o_flag_pf,
    output logic                o_flag_af,
    output logic                o_flag_zf,
    output logic                o_flag_sf,
    output logic                o_flag_of,

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
            o_uop_valid   <= 1'b0;
            o_uop         <= '0;
            o_src1_data   <= 32'd0;
            o_src2_data   <= 32'd0;
            o_flag_cf     <= 1'b0;
            o_flag_pf     <= 1'b0;
            o_flag_af     <= 1'b0;
            o_flag_zf     <= 1'b0;
            o_flag_sf     <= 1'b0;
            o_flag_of     <= 1'b0;
        end else if (i_flush) begin
            o_uop_valid   <= 1'b0;
        end else if (i_exu_ready) begin
            o_uop_valid   <= i_uop_valid;
            o_uop         <= i_uop;
            o_src1_data   <= i_src1_data;
            o_src2_data   <= i_src2_data;
            o_flag_cf     <= i_flag_cf;
            o_flag_pf     <= i_flag_pf;
            o_flag_af     <= i_flag_af;
            o_flag_zf     <= i_flag_zf;
            o_flag_sf     <= i_flag_sf;
            o_flag_of     <= i_flag_of;
        end
    end

    // ============================================================
    // Back-pressure: stage 4 can push when EXU is ready
    // ============================================================
    assign o_stage4_ready = i_exu_ready;

endmodule
