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
//  File        : stage_4_reg.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Register read stage — reads GPR and flag values based on uop
//                register indices, passes uop and operand data to execution
// ============================================================================

`include "openx86_defs.h.sv"

module stage_4_reg (
    // =========================
    // Pipeline handshake from stage_3_uop
    // =========================
    input  logic                i_uop_valid,
    input  micro_op_t           i_uop,
    output logic                o_stage3_ready,

    // =========================
    // Pipeline handshake to stage_5_exu
    // =========================
    output logic                o_stage_ready,
    output logic                o_stage_valid,
    input  logic                i_exu_ready,

    // =========================
    // Pipeline control
    // =========================
    input  logic                i_flush,

    // =========================
    // GPR read data (from register file)
    // =========================
    input  logic [31: 0]        i_gpr_eax,
    input  logic [31: 0]        i_gpr_ebx,
    input  logic [31: 0]        i_gpr_ecx,
    input  logic [31: 0]        i_gpr_edx,
    input  logic [31: 0]        i_gpr_esp,
    input  logic [31: 0]        i_gpr_ebp,
    input  logic [31: 0]        i_gpr_esi,
    input  logic [31: 0]        i_gpr_edi,

    // =========================
    // Flags (from EFLAGS register)
    // =========================
    input  logic                i_flag_cf,
    input  logic                i_flag_pf,
    input  logic                i_flag_af,
    input  logic                i_flag_zf,
    input  logic                i_flag_sf,
    input  logic                i_flag_of,

    // =========================
    // Micro-op and operand outputs to stage_5_exu
    // =========================
    output micro_op_t           o_uop,
    output logic [31: 0]        o_src1_data,
    output logic [31: 0]        o_src2_data,

    // =========================
    // Flags output to stage_5_exu
    // =========================
    output logic                o_flag_cf,
    output logic                o_flag_pf,
    output logic                o_flag_af,
    output logic                o_flag_zf,
    output logic                o_flag_sf,
    output logic                o_flag_of,

    // =========================
    // Clock and reset
    // =========================
    input  logic                clk,
    input  logic                rst_n
);

    // ============================================================
    // GPR index mapping array
    // ============================================================
    logic [31: 0] gpr_by_idx [0: 7];

    assign gpr_by_idx[0] = i_gpr_eax;
    assign gpr_by_idx[1] = i_gpr_ecx;
    assign gpr_by_idx[2] = i_gpr_edx;
    assign gpr_by_idx[3] = i_gpr_ebx;
    assign gpr_by_idx[4] = i_gpr_esp;
    assign gpr_by_idx[5] = i_gpr_ebp;
    assign gpr_by_idx[6] = i_gpr_esi;
    assign gpr_by_idx[7] = i_gpr_edi;

    // ============================================================
    // Operand selection based on uop register indices
    // ============================================================
    logic [31: 0] src1_data;
    logic [31: 0] src2_data;

    assign src1_data = gpr_by_idx[i_uop.uop_src1_reg];
    assign src2_data = gpr_by_idx[i_uop.uop_src2_reg];

    // ============================================================
    // Pipeline register: latch when downstream is ready
    // ============================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_stage_valid <= 1'b0;
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
            o_stage_valid <= 1'b0;
        end else if (i_exu_ready) begin
            o_stage_valid <= i_uop_valid;
            o_uop         <= i_uop;
            o_src1_data   <= src1_data;
            o_src2_data   <= src2_data;
            o_flag_cf     <= i_flag_cf;
            o_flag_pf     <= i_flag_pf;
            o_flag_af     <= i_flag_af;
            o_flag_zf     <= i_flag_zf;
            o_flag_sf     <= i_flag_sf;
            o_flag_of     <= i_flag_of;
        end
    end

    // ============================================================
    // Back-pressure: stage 3 can push when stage 4 is ready
    // ============================================================
    assign o_stage3_ready = i_exu_ready;
    assign o_stage_ready  = i_exu_ready;

endmodule
