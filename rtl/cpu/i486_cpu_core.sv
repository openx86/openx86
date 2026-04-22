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
    output logic         o_mmu_vaild,
    input  logic          i_mmu_ready,
    output logic [31: 0] o_mmu_address,
    input  logic [31: 0] i_mmu_data_read,

    // =========================
    // instruction fetch channel
    // =========================
    output logic         o_code_vaild,
    input  logic          i_code_ready,
    output logic [31: 0] o_code_address,
    input  logic [31: 0] i_code_data_read,

    // =========================
    // data access channel
    // =========================
    output logic         o_data_vaild,
    input  logic          i_data_ready,
    output logic         o_data_write_enable,
    output logic         o_data_io_access,
    output logic [31: 0] o_data_address,
    input  logic [31: 0] i_data_data_read,
    output logic [31: 0] o_data_data_write,

    // =========================
    // clock and reset
    // =========================
    input  logic          clk,
    input  logic          rst_n
);
    // 译码子模块 .* 互连线：必须放在模块内，避免在编译单元顶层声明而与子模块端口同名（VARHIDDEN）
`include "iu_decode_outputs_decl.svh"

    // ============================================================
    // GPR write ports (combinational and WRB stage)
    // ============================================================
    logic        write_enable;
    logic [ 2: 0] write_index;
    logic [31: 0] write_data;
    logic        wrb_write_enable;
    logic [ 2: 0] wrb_write_index;
    logic [31: 0] wrb_write_data;

    // ============================================================
    // segment register write ports
    // ============================================================
    logic        SREG_write_enable;
    logic [ 2: 0] SREG_write_index;
    logic [15: 0] SREG_write_selector;
    logic [63: 0] SREG_write_descriptor;
    logic        wrb_SREG_write_enable;
    logic [ 2: 0] wrb_SREG_write_index;
    logic [15: 0] wrb_SREG_write_selector;
    logic [63: 0] wrb_SREG_write_descriptor;

    // ============================================================
    // flags register write ports
    // ============================================================
    logic         FLAGS_write_enable;
    logic [31: 0]  FLAGS_write_data;
    logic         wrb_FLAGS_write_enable;
    logic [31: 0]  wrb_FLAGS_write_data;

    // ============================================================
    // EIP write ports
    // ============================================================
    logic        IP_write_enable;
    logic [31: 0] IP_write_data;
    logic        wrb_IP_write_enable;
    logic [31: 0] wrb_IP_write_data;

    // ============================================================
    // control registers write ports
    // ============================================================
    logic         CR_write_enable;
    logic [ 2: 0] CR_write_index;
    logic [31: 0] CR_write_data;
    logic         wrb_CR_write_enable;
    logic [ 2: 0] wrb_CR_write_index;
    logic [31: 0] wrb_CR_write_data;

    // ============================================================
    // debug registers write ports
    // ============================================================
    logic         DR_write_enable;
    logic [ 2: 0] DR_write_index;
    logic [31: 0] DR_write_data;
    logic         wrb_DR_write_enable;
    logic [ 2: 0] wrb_DR_write_index;
    logic [31: 0] wrb_DR_write_data;

    // ============================================================
    // test registers write ports
    // ============================================================
    logic         TR_write_enable;
    logic [ 2: 0] TR_write_index;
    logic [31: 0] TR_write_data;
    logic         wrb_TR_write_enable;
    logic [ 2: 0] wrb_TR_write_index;
    logic [31: 0] wrb_TR_write_data;

    // ============================================================
    // GPR read ports (8/16/32-bit views broadcast to decode and EU)
    // ============================================================
    logic [ 7: 0][31: 0] GPR_read__8;
    logic [ 7: 0][31: 0] GPR_read_16;
    logic [ 7: 0][31: 0] GPR_read_32;

    // ============================================================
    // segment registers (selector + descriptor cache)
    // ============================================================
    logic [ 5: 0][15: 0] segment_selector;
    logic [ 5: 0][63: 0] descriptor_cache;

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
    logic [ 7: 0][31: 0] CR;
    logic         PE, MP, EM, TS, R, PG;
    logic [19: 0] page_directory_base;

    // ============================================================
    // debug and test registers
    // ============================================================
    logic [ 7: 0][31: 0] DR;
    logic [ 7: 0][31: 0] TR;

    // ============================================================
    // GDTR/IDTR (hardwired to 0 for SGDT/SIDT instruction placeholders)
    // ============================================================
    logic [15: 0] GDTR_limit;
    logic [31: 0] GDTR_base;
    logic [15: 0] IDTR_limit;
    logic [31: 0] IDTR_base;

    // ============================================================
    // general purpose register file
    // ============================================================
    rf_x86_general_purpose u_rf_gpr (
        .write_enable ( wrb_write_enable ),
        .write_index ( wrb_write_index ),
        .write_data ( wrb_write_data ),
        .read__8 ( GPR_read__8 ),
        .read_16 ( GPR_read_16 ),
        .read_32 ( GPR_read_32 ),
        .clk ( clk ),
        .rst_n ( rst_n )
    );

    // ============================================================
    // segment register file
    // ============================================================
    rf_x86_segment u_rf_sreg (
        .write_enable ( wrb_SREG_write_enable ),
        .write_index ( wrb_SREG_write_index ),
        .write_selector ( wrb_SREG_write_selector ),
        .write_descriptor ( wrb_SREG_write_descriptor ),
        .segment_selector ( segment_selector ),
        .descriptor_cache ( descriptor_cache ),
        .clk ( clk ),
        .rst_n ( rst_n )
    );

    // ============================================================
    // flags register file
    // ============================================================
    rf_x86_flags u_rf_flags (
        .write_enable ( wrb_FLAGS_write_enable ),
        .write_data ( wrb_FLAGS_write_data ),
        .CF ( CF ),
        .PF ( PF ),
        .AF ( AF ),
        .ZF ( ZF ),
        .SF ( SF ),
        .TF ( TF ),
        .IF ( IF ),
        .DF ( DF ),
        .OF ( OF ),
        .IOPL ( iOPL ),
        .NT ( NT ),
        .RF ( RF ),
        .VM ( VM ),
        .EFLAGS ( EFLAGS ),
        .FLAGS ( FLAGS ),
        .clk ( clk ),
        .rst_n ( rst_n )
    );

    // ============================================================
    // instruction pointer register file
    // ============================================================
    rf_x86_instruction_pointer u_rf_ip (
        .write_enable ( wrb_IP_write_enable ),
        .write_data ( wrb_IP_write_data ),
        .IP ( IP ),
        .EIP ( EIP ),
        .clk ( clk ),
        .rst_n ( rst_n )
    );

    // ============================================================
    // control register file
    // ============================================================
    rf_x86_control u_rf_cr (
        .write_enable ( wrb_CR_write_enable ),
        .write_index ( wrb_CR_write_index ),
        .write_data ( wrb_CR_write_data ),
        .CR ( CR ),
        .PE ( PE ),
        .MP ( MP ),
        .EM ( EM ),
        .TS ( TS ),
        .R ( R ),
        .PG ( PG ),
        .page_directory_base ( page_directory_base ),
        .clk ( clk ),
        .rst_n ( rst_n )
    );

    // ============================================================
    // debug register file
    // ============================================================
    rf_x86_debug u_rf_dr (
        .write_enable ( wrb_DR_write_enable ),
        .write_index ( wrb_DR_write_index ),
        .write_data ( wrb_DR_write_data ),
        .DR ( DR ),
        .clk ( clk ),
        .rst_n ( rst_n )
    );

    // ============================================================
    // test register file
    // ============================================================
    rf_x86_test u_rf_tr (
        .write_enable ( wrb_TR_write_enable ),
        .write_index ( wrb_TR_write_index ),
        .write_data ( wrb_TR_write_data ),
        .TR ( TR ),
        .clk ( clk ),
        .rst_n ( rst_n )
    );

    // ============================================================
    // GDTR register file
    // ============================================================
    rf_x86_gdtr u_rf_gdtr (
        .gdtr_write_enable ( 1'b0 ),
        .gdtr_write_data_limit ( 16'd0 ),
        .gdtr_write_data_base ( 32'd0 ),
        .gdtr_limit ( GDTR_limit ),
        .gdtr_base ( GDTR_base ),
        .clk ( clk ),
        .rst_n ( rst_n )
    );

    // ============================================================
    // IDTR register file
    // ============================================================
    rf_x86_idtr u_rf_idtr (
        .idtr_write_enable ( 1'b0 ),
        .idtr_write_data_limit ( 16'd0 ),
        .idtr_write_data_base ( 32'd0 ),
        .idtr_limit ( IDTR_limit ),
        .idtr_base ( IDTR_base ),
        .clk ( clk ),
        .rst_n ( rst_n )
    );

endmodule
