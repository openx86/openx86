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
//  File        : i486_cpu_core.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : i486_cpu_core module
// ============================================================================

// ============================================================================
// i486_cpu_core — core-side pipeline (prefetch/decode/execute/memory/writeback)
// ============================================================================
`include "openx86_defs.h.sv"

module i486_cpu_core (
    // =========================
    // MMU channel
    // =========================
    output logic         o_mmu_vaild      = 1'b0,
    input  logic          i_mmu_ready,
    output logic [31: 0] o_mmu_address     = 32'b0,
    input  logic [31: 0] i_mmu_data_read,

    // =========================
    // instruction fetch channel
    // =========================
    output logic         o_code_vaild     = 1'b0,
    input  logic          i_code_ready,
    output logic [31: 0] o_code_address    = 32'b0,
    input  logic [31: 0] i_code_data_read,

    // =========================
    // data access channel
    // =========================
    output logic         o_data_vaild     = 1'b0,
    input  logic          i_data_ready,
    output logic         o_data_write_enable = 1'b0,
    output logic         o_data_io_access   = 1'b0,
    output logic [31: 0] o_data_address    = 32'b0,
    input  logic [31: 0] i_data_data_read,
    output logic [31: 0] o_data_data_write  = 32'b0,

    // =========================
    // clock and reset
    // =========================
    input  logic          clk,
    input  logic          rst_n
);
    // 译码子模块 .* 互连线：必须放在模块内，避免在编译单元顶层声明而与子模块端口同名（VARHIDDEN）
`include "iu_decode_outputs_decl.svh"

    // ============================================================
    // GPR write ports (individual write enables)
    // ============================================================
    logic wrb_gpr_eax_write_enable = 1'b0;
    logic wrb_gpr_ecx_write_enable = 1'b0;
    logic wrb_gpr_edx_write_enable = 1'b0;
    logic wrb_gpr_ebx_write_enable = 1'b0;
    logic wrb_gpr_esp_write_enable = 1'b0;
    logic wrb_gpr_ebp_write_enable = 1'b0;
    logic wrb_gpr_esi_write_enable = 1'b0;
    logic wrb_gpr_edi_write_enable = 1'b0;
    logic [31: 0] wrb_gpr_write_data = 32'b0;

    // ============================================================
    // segment register write ports (individual write enables)
    // ============================================================
    logic wrb_seg_es_write_enable = 1'b0;
    logic wrb_seg_cs_write_enable = 1'b0;
    logic wrb_seg_ss_write_enable = 1'b0;
    logic wrb_seg_ds_write_enable = 1'b0;
    logic wrb_seg_fs_write_enable = 1'b0;
    logic wrb_seg_gs_write_enable = 1'b0;
    logic [15: 0] wrb_seg_write_selector = 16'b0;
    logic [63: 0] wrb_seg_write_descriptor = 64'b0;

    // ============================================================
    // flags register write ports
    // ============================================================
    logic FLAGS_write_enable;
    logic [31: 0] FLAGS_write_data;
    logic wrb_FLAGS_write_enable;
    logic [31: 0] wrb_FLAGS_write_data;

    // ============================================================
    // EIP write ports
    // ============================================================
    logic IP_write_enable;
    logic [31: 0] IP_write_data;
    logic wrb_IP_write_enable;
    logic [31: 0] wrb_IP_write_data;

    // ============================================================
    // control registers write ports (individual write enables)
    // ============================================================
    logic wrb_cr0_write_enable = 1'b0;
    logic wrb_cr1_write_enable = 1'b0;
    logic wrb_cr2_write_enable = 1'b0;
    logic wrb_cr3_write_enable = 1'b0;
    logic wrb_cr4_write_enable = 1'b0;
    logic wrb_cr5_write_enable = 1'b0;
    logic wrb_cr6_write_enable = 1'b0;
    logic wrb_cr7_write_enable = 1'b0;
    logic [31: 0] wrb_cr_write_data = 32'b0;

    // ============================================================
    // debug registers write ports (individual write enables)
    // ============================================================
    logic wrb_dr0_write_enable = 1'b0;
    logic wrb_dr1_write_enable = 1'b0;
    logic wrb_dr2_write_enable = 1'b0;
    logic wrb_dr3_write_enable = 1'b0;
    logic wrb_dr4_write_enable = 1'b0;
    logic wrb_dr5_write_enable = 1'b0;
    logic wrb_dr6_write_enable = 1'b0;
    logic wrb_dr7_write_enable = 1'b0;
    logic [31: 0] wrb_dr_write_data = 32'b0;

    // ============================================================
    // test registers write ports (individual write enables)
    // ============================================================
    logic wrb_tr0_write_enable = 1'b0;
    logic wrb_tr1_write_enable = 1'b0;
    logic wrb_tr2_write_enable = 1'b0;
    logic wrb_tr3_write_enable = 1'b0;
    logic wrb_tr4_write_enable = 1'b0;
    logic wrb_tr5_write_enable = 1'b0;
    logic wrb_tr6_write_enable = 1'b0;
    logic wrb_tr7_write_enable = 1'b0;
    logic [31: 0] wrb_tr_write_data = 32'b0;

    // ============================================================
    // GPR read ports (8/16/32-bit views broadcast to decode and EU)
    // ============================================================
    logic [ 7: 0][31: 0] GPR_read__8;
    logic [ 7: 0][31: 0] GPR_read_16;
    logic [ 7: 0][31: 0] GPR_read_32;
    logic [31: 0] gpr_eax_read_32;
    logic [31: 0] gpr_ecx_read_32;
    logic [31: 0] gpr_edx_read_32;
    logic [31: 0] gpr_ebx_read_32;
    logic [31: 0] gpr_esp_read_32;
    logic [31: 0] gpr_ebp_read_32;
    logic [31: 0] gpr_esi_read_32;
    logic [31: 0] gpr_edi_read_32;

    // ============================================================
    // segment registers (selector + descriptor cache)
    // ============================================================
    logic [ 5: 0][15: 0] segment_selector;
    logic [ 5: 0][63: 0] descriptor_cache;
    logic [15: 0] seg_es_selector;
    logic [15: 0] seg_cs_selector;
    logic [15: 0] seg_ss_selector;
    logic [15: 0] seg_ds_selector;
    logic [15: 0] seg_fs_selector;
    logic [15: 0] seg_gs_selector;
    logic [63: 0] seg_es_descriptor;
    logic [63: 0] seg_cs_descriptor;
    logic [63: 0] seg_ss_descriptor;
    logic [63: 0] seg_ds_descriptor;
    logic [63: 0] seg_fs_descriptor;
    logic [63: 0] seg_gs_descriptor;

    // ============================================================
    // flags register
    // ============================================================
    logic         CF, PF, AF, ZF, SF, TF, IF, DF, OF;
    logic [ 1: 0] iOPL;
    logic         NT, RF, VM;
    logic [31: 0]  EFLAGS;
    logic [15: 0]  FLAGS;

    // ============================================================
    // instruction pointer
    // ============================================================
    logic [15: 0] IP;
    logic [31: 0] EIP;

    // ============================================================
    // control registers
    // ============================================================
    logic [31: 0] cr0_data;
    logic [31: 0] cr1_data;
    logic [31: 0] cr2_data;
    logic [31: 0] cr3_data;
    logic [31: 0] cr4_data;
    logic [31: 0] cr5_data;
    logic [31: 0] cr6_data;
    logic [31: 0] cr7_data;
    logic PE, MP, EM, TS, R, PG;
    logic [19: 0] page_directory_base;

    // ============================================================
    // debug and test registers
    // ============================================================
    logic [31: 0] dr0_data;
    logic [31: 0] dr1_data;
    logic [31: 0] dr2_data;
    logic [31: 0] dr3_data;
    logic [31: 0] dr4_data;
    logic [31: 0] dr5_data;
    logic [31: 0] dr6_data;
    logic [31: 0] dr7_data;
    logic [31: 0] tr0_data;
    logic [31: 0] tr1_data;
    logic [31: 0] tr2_data;
    logic [31: 0] tr3_data;
    logic [31: 0] tr4_data;
    logic [31: 0] tr5_data;
    logic [31: 0] tr6_data;
    logic [31: 0] tr7_data;

    // ============================================================
    // GDTR/IDTR (hardwired to 0 for SGDT/SIDT instruction placeholders)
    // ============================================================
    logic [15: 0] GDTR_limit;
    logic [31: 0] GDTR_base;
    logic [15: 0] IDTR_limit;
    logic [31: 0] IDTR_base;

    // ============================================================
    // general purpose registers (individual modules)
    // ============================================================
    rf_x86_gpr_eax u_rf_gpr_eax (
        .i_write_enable (wrb_gpr_eax_write_enable),
        .i_write_data   (wrb_gpr_write_data),
        .o_read__8      (GPR_read__8[0]),
        .o_read_16      (GPR_read_16[0]),
        .o_read_32      (GPR_read_32[0]),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_gpr_ecx u_rf_gpr_ecx (
        .i_write_enable (wrb_gpr_ecx_write_enable),
        .i_write_data   (wrb_gpr_write_data),
        .o_read__8      (GPR_read__8[1]),
        .o_read_16      (GPR_read_16[1]),
        .o_read_32      (GPR_read_32[1]),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_gpr_edx u_rf_gpr_edx (
        .i_write_enable (wrb_gpr_edx_write_enable),
        .i_write_data   (wrb_gpr_write_data),
        .o_read__8      (GPR_read__8[2]),
        .o_read_16      (GPR_read_16[2]),
        .o_read_32      (GPR_read_32[2]),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_gpr_ebx u_rf_gpr_ebx (
        .i_write_enable (wrb_gpr_ebx_write_enable),
        .i_write_data   (wrb_gpr_write_data),
        .o_read__8      (GPR_read__8[3]),
        .o_read_16      (GPR_read_16[3]),
        .o_read_32      (GPR_read_32[3]),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_gpr_esp u_rf_gpr_esp (
        .i_write_enable (wrb_gpr_esp_write_enable),
        .i_write_data   (wrb_gpr_write_data),
        .o_read__8      (GPR_read__8[4]),
        .o_read_16      (GPR_read_16[4]),
        .o_read_32      (GPR_read_32[4]),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_gpr_ebp u_rf_gpr_ebp (
        .i_write_enable (wrb_gpr_ebp_write_enable),
        .i_write_data   (wrb_gpr_write_data),
        .o_read__8      (GPR_read__8[5]),
        .o_read_16      (GPR_read_16[5]),
        .o_read_32      (GPR_read_32[5]),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_gpr_esi u_rf_gpr_esi (
        .i_write_enable (wrb_gpr_esi_write_enable),
        .i_write_data   (wrb_gpr_write_data),
        .o_read__8      (GPR_read__8[6]),
        .o_read_16      (GPR_read_16[6]),
        .o_read_32      (GPR_read_32[6]),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_gpr_edi u_rf_gpr_edi (
        .i_write_enable (wrb_gpr_edi_write_enable),
        .i_write_data   (wrb_gpr_write_data),
        .o_read__8      (GPR_read__8[7]),
        .o_read_16      (GPR_read_16[7]),
        .o_read_32      (GPR_read_32[7]),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    // ============================================================
    // segment registers (individual modules)
    // ============================================================
    rf_x86_seg_es u_rf_seg_es (
        .i_write_enable    (wrb_seg_es_write_enable),
        .i_write_selector  (wrb_seg_write_selector),
        .i_write_descriptor(wrb_seg_write_descriptor),
        .o_selector        (seg_es_selector),
        .o_descriptor      (seg_es_descriptor),
        .clk               (clk),
        .rst_n             (rst_n)
    );

    rf_x86_seg_cs u_rf_seg_cs (
        .i_write_enable    (wrb_seg_cs_write_enable),
        .i_write_selector  (wrb_seg_write_selector),
        .i_write_descriptor(wrb_seg_write_descriptor),
        .o_selector        (seg_cs_selector),
        .o_descriptor      (seg_cs_descriptor),
        .clk               (clk),
        .rst_n             (rst_n)
    );

    rf_x86_seg_ss u_rf_seg_ss (
        .i_write_enable    (wrb_seg_ss_write_enable),
        .i_write_selector  (wrb_seg_write_selector),
        .i_write_descriptor(wrb_seg_write_descriptor),
        .o_selector        (seg_ss_selector),
        .o_descriptor      (seg_ss_descriptor),
        .clk               (clk),
        .rst_n             (rst_n)
    );

    rf_x86_seg_ds u_rf_seg_ds (
        .i_write_enable    (wrb_seg_ds_write_enable),
        .i_write_selector  (wrb_seg_write_selector),
        .i_write_descriptor(wrb_seg_write_descriptor),
        .o_selector        (seg_ds_selector),
        .o_descriptor      (seg_ds_descriptor),
        .clk               (clk),
        .rst_n             (rst_n)
    );

    rf_x86_seg_fs u_rf_seg_fs (
        .i_write_enable    (wrb_seg_fs_write_enable),
        .i_write_selector  (wrb_seg_write_selector),
        .i_write_descriptor(wrb_seg_write_descriptor),
        .o_selector        (seg_fs_selector),
        .o_descriptor      (seg_fs_descriptor),
        .clk               (clk),
        .rst_n             (rst_n)
    );

    rf_x86_seg_gs u_rf_seg_gs (
        .i_write_enable    (wrb_seg_gs_write_enable),
        .i_write_selector  (wrb_seg_write_selector),
        .i_write_descriptor(wrb_seg_write_descriptor),
        .o_selector        (seg_gs_selector),
        .o_descriptor      (seg_gs_descriptor),
        .clk               (clk),
        .rst_n             (rst_n)
    );

    assign segment_selector[0] = seg_es_selector;
    assign segment_selector[1] = seg_cs_selector;
    assign segment_selector[2] = seg_ss_selector;
    assign segment_selector[3] = seg_ds_selector;
    assign segment_selector[4] = seg_fs_selector;
    assign segment_selector[5] = seg_gs_selector;
    assign descriptor_cache[0] = seg_es_descriptor;
    assign descriptor_cache[1] = seg_cs_descriptor;
    assign descriptor_cache[2] = seg_ss_descriptor;
    assign descriptor_cache[3] = seg_ds_descriptor;
    assign descriptor_cache[4] = seg_fs_descriptor;
    assign descriptor_cache[5] = seg_gs_descriptor;

    // ============================================================
    // flags register file
    // ============================================================
    rf_x86_eflags u_rf_eflags (
        .i_write_enable(wrb_FLAGS_write_enable),
        .i_write_data   (wrb_FLAGS_write_data),
        .o_CF           (CF),
        .o_PF           (PF),
        .o_AF           (AF),
        .o_ZF           (ZF),
        .o_SF           (SF),
        .o_TF           (TF),
        .o_IF           (IF),
        .o_DF           (DF),
        .o_OF           (OF),
        .o_IOPL         (iOPL),
        .o_NT           (NT),
        .o_RF           (RF),
        .o_VM           (VM),
        .o_EFLAGS       (EFLAGS),
        .o_FLAGS        (FLAGS),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    // ============================================================
    // instruction pointer register file
    // ============================================================
    rf_x86_eip u_rf_eip (
        .i_write_enable(wrb_IP_write_enable),
        .i_write_data   (wrb_IP_write_data),
        .o_IP           (IP),
        .o_EIP          (EIP),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    // ============================================================
    // control registers (individual modules)
    // ============================================================
    rf_x86_cr0 u_rf_cr0 (
        .i_write_enable       (wrb_cr0_write_enable),
        .i_write_data         (wrb_cr_write_data),
        .o_data               (cr0_data),
        .o_PE                 (PE),
        .o_MP                 (MP),
        .o_EM                 (EM),
        .o_TS                 (TS),
        .o_R                  (R),
        .o_PG                 (PG),
        .clk                  (clk),
        .rst_n                (rst_n)
    );

    rf_x86_cr1 u_rf_cr1 (
        .i_write_enable (wrb_cr1_write_enable),
        .i_write_data   (wrb_cr_write_data),
        .o_data         (cr1_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_cr2 u_rf_cr2 (
        .i_write_enable (wrb_cr2_write_enable),
        .i_write_data   (wrb_cr_write_data),
        .o_data         (cr2_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_cr3 u_rf_cr3 (
        .i_write_enable       (wrb_cr3_write_enable),
        .i_write_data         (wrb_cr_write_data),
        .o_data               (cr3_data),
        .o_page_directory_base(page_directory_base),
        .clk                  (clk),
        .rst_n                (rst_n)
    );

    rf_x86_cr4 u_rf_cr4 (
        .i_write_enable (wrb_cr4_write_enable),
        .i_write_data   (wrb_cr_write_data),
        .o_data         (cr4_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_cr5 u_rf_cr5 (
        .i_write_enable (wrb_cr5_write_enable),
        .i_write_data   (wrb_cr_write_data),
        .o_data         (cr5_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_cr6 u_rf_cr6 (
        .i_write_enable (wrb_cr6_write_enable),
        .i_write_data   (wrb_cr_write_data),
        .o_data         (cr6_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_cr7 u_rf_cr7 (
        .i_write_enable (wrb_cr7_write_enable),
        .i_write_data   (wrb_cr_write_data),
        .o_data         (cr7_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    // ============================================================
    // debug registers (individual modules)
    // ============================================================
    rf_x86_dr0 u_rf_dr0 (
        .i_write_enable (wrb_dr0_write_enable),
        .i_write_data   (wrb_dr_write_data),
        .o_data         (dr0_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_dr1 u_rf_dr1 (
        .i_write_enable (wrb_dr1_write_enable),
        .i_write_data   (wrb_dr_write_data),
        .o_data         (dr1_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_dr2 u_rf_dr2 (
        .i_write_enable (wrb_dr2_write_enable),
        .i_write_data   (wrb_dr_write_data),
        .o_data         (dr2_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_dr3 u_rf_dr3 (
        .i_write_enable (wrb_dr3_write_enable),
        .i_write_data   (wrb_dr_write_data),
        .o_data         (dr3_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_dr4 u_rf_dr4 (
        .i_write_enable (wrb_dr4_write_enable),
        .i_write_data   (wrb_dr_write_data),
        .o_data         (dr4_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_dr5 u_rf_dr5 (
        .i_write_enable (wrb_dr5_write_enable),
        .i_write_data   (wrb_dr_write_data),
        .o_data         (dr5_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_dr6 u_rf_dr6 (
        .i_write_enable (wrb_dr6_write_enable),
        .i_write_data   (wrb_dr_write_data),
        .o_data         (dr6_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_dr7 u_rf_dr7 (
        .i_write_enable (wrb_dr7_write_enable),
        .i_write_data   (wrb_dr_write_data),
        .o_data         (dr7_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    // ============================================================
    // test registers (individual modules)
    // ============================================================
    rf_x86_tr0 u_rf_tr0 (
        .i_write_enable (wrb_tr0_write_enable),
        .i_write_data   (wrb_tr_write_data),
        .o_data         (tr0_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_tr1 u_rf_tr1 (
        .i_write_enable (wrb_tr1_write_enable),
        .i_write_data   (wrb_tr_write_data),
        .o_data         (tr1_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_tr2 u_rf_tr2 (
        .i_write_enable (wrb_tr2_write_enable),
        .i_write_data   (wrb_tr_write_data),
        .o_data         (tr2_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_tr3 u_rf_tr3 (
        .i_write_enable (wrb_tr3_write_enable),
        .i_write_data   (wrb_tr_write_data),
        .o_data         (tr3_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_tr4 u_rf_tr4 (
        .i_write_enable (wrb_tr4_write_enable),
        .i_write_data   (wrb_tr_write_data),
        .o_data         (tr4_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_tr5 u_rf_tr5 (
        .i_write_enable (wrb_tr5_write_enable),
        .i_write_data   (wrb_tr_write_data),
        .o_data         (tr5_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_tr6 u_rf_tr6 (
        .i_write_enable (wrb_tr6_write_enable),
        .i_write_data   (wrb_tr_write_data),
        .o_data         (tr6_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    rf_x86_tr7 u_rf_tr7 (
        .i_write_enable (wrb_tr7_write_enable),
        .i_write_data   (wrb_tr_write_data),
        .o_data         (tr7_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    // ============================================================
    // GDTR register file
    // ============================================================
    rf_x86_gdtr u_rf_gdtr (
        .gdtr_write_enable    (1'b0),
        .gdtr_write_data_limit (16'd0),
        .gdtr_write_data_base  (32'd0),
        .gdtr_limit           (GDTR_limit),
        .gdtr_base            (GDTR_base),
        .clk                  (clk),
        .rst_n                (rst_n)
    );

    // ============================================================
    // IDTR register file
    // ============================================================
    rf_x86_idtr u_rf_idtr (
        .idtr_write_enable   (1'b0),
        .idtr_write_data_limit(16'd0),
        .idtr_write_data_base (32'd0),
        .idtr_limit          (IDTR_limit),
        .idtr_base           (IDTR_base),
        .clk                (clk),
        .rst_n              (rst_n)
    );

endmodule
