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
//  File        : i486_cpu_pipeline.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Integrated IFU/DEC/UOP/REG/EXU pipeline with EIU
// ============================================================================

`include "openx86_defs.h.sv"

module i486_cpu_pipeline (
    // =========================
    // MMU / CODE / DATA bus
    // =========================
    output logic         o_mmu_valid,
    input  logic         i_mmu_ready,
    output logic [31: 0] o_mmu_address,
    input  logic [31: 0] i_mmu_data_read,

    output logic         o_code_valid,
    input  logic         i_code_ready,
    output logic [31: 0] o_code_address,
    input  logic [31: 0] i_code_data_read,

    output logic         o_data_valid,
    input  logic         i_data_ready,
    output logic         o_data_write_enable,
    output logic         o_data_io_access,
    output logic [31: 0] o_data_address,
    input  logic [31: 0] i_data_data_read,
    output logic [31: 0] o_data_data_write,

    // =========================
    // GPR read (from register file)
    // =========================
    input  logic [31: 0] i_gpr_eax,
    input  logic [31: 0] i_gpr_ebx,
    input  logic [31: 0] i_gpr_ecx,
    input  logic [31: 0] i_gpr_edx,
    input  logic [31: 0] i_gpr_esp,
    input  logic [31: 0] i_gpr_ebp,
    input  logic [31: 0] i_gpr_esi,
    input  logic [31: 0] i_gpr_edi,

    // =========================
    // Flags read
    // =========================
    input  logic         i_cf,
    input  logic         i_pf,
    input  logic         i_af,
    input  logic         i_zf,
    input  logic         i_sf,
    input  logic         i_of,
    input  logic         i_if_flag,

    // =========================
    // Segment / MMU context
    // =========================
    input  logic         i_protected_mode,
    input  logic [ 5: 0][15: 0] i_segment_selector,
    input  logic [ 5: 0][63: 0] i_segment_descriptor,
    input  logic [ 1: 0]        i_cpl,
    input  logic         i_paging_enable,
    input  logic [31: 0] i_page_directory_base,
    input  logic [31: 0] i_idtr_base,
    input  logic [15: 0] i_idtr_limit,
    input  logic [31: 0] i_eip,

    // =========================
    // Write-back to register file
    // =========================
    output logic         o_wrb_gpr_write_enable_EAX,
    output logic         o_wrb_gpr_write_enable_AX,
    output logic         o_wrb_gpr_write_enable_AL,
    output logic         o_wrb_gpr_write_enable_AH,
    output logic         o_wrb_gpr_write_enable_EBX,
    output logic         o_wrb_gpr_write_enable_BX,
    output logic         o_wrb_gpr_write_enable_BL,
    output logic         o_wrb_gpr_write_enable_BH,
    output logic         o_wrb_gpr_write_enable_ECX,
    output logic         o_wrb_gpr_write_enable_CX,
    output logic         o_wrb_gpr_write_enable_CL,
    output logic         o_wrb_gpr_write_enable_CH,
    output logic         o_wrb_gpr_write_enable_EDX,
    output logic         o_wrb_gpr_write_enable_DX,
    output logic         o_wrb_gpr_write_enable_DL,
    output logic         o_wrb_gpr_write_enable_DH,
    output logic         o_wrb_gpr_write_enable_ESP,
    output logic         o_wrb_gpr_write_enable_SP,
    output logic         o_wrb_gpr_write_enable_EBP,
    output logic         o_wrb_gpr_write_enable_BP,
    output logic         o_wrb_gpr_write_enable_ESI,
    output logic         o_wrb_gpr_write_enable_SI,
    output logic         o_wrb_gpr_write_enable_EDI,
    output logic         o_wrb_gpr_write_enable_DI,
    output logic [31: 0] o_wrb_gpr_write_data_EAX,
    output logic [15: 0] o_wrb_gpr_write_data_AX,
    output logic [ 7: 0] o_wrb_gpr_write_data_AL,
    output logic [ 7: 0] o_wrb_gpr_write_data_AH,
    output logic [31: 0] o_wrb_gpr_write_data_EBX,
    output logic [15: 0] o_wrb_gpr_write_data_BX,
    output logic [ 7: 0] o_wrb_gpr_write_data_BL,
    output logic [ 7: 0] o_wrb_gpr_write_data_BH,
    output logic [31: 0] o_wrb_gpr_write_data_ECX,
    output logic [15: 0] o_wrb_gpr_write_data_CX,
    output logic [ 7: 0] o_wrb_gpr_write_data_CL,
    output logic [ 7: 0] o_wrb_gpr_write_data_CH,
    output logic [31: 0] o_wrb_gpr_write_data_EDX,
    output logic [15: 0] o_wrb_gpr_write_data_DX,
    output logic [ 7: 0] o_wrb_gpr_write_data_DL,
    output logic [ 7: 0] o_wrb_gpr_write_data_DH,
    output logic [31: 0] o_wrb_gpr_write_data_ESP,
    output logic [15: 0] o_wrb_gpr_write_data_SP,
    output logic [31: 0] o_wrb_gpr_write_data_EBP,
    output logic [15: 0] o_wrb_gpr_write_data_BP,
    output logic [31: 0] o_wrb_gpr_write_data_ESI,
    output logic [15: 0] o_wrb_gpr_write_data_SI,
    output logic [31: 0] o_wrb_gpr_write_data_EDI,
    output logic [15: 0] o_wrb_gpr_write_data_DI,
    output logic         o_wrb_FLAGS_write_enable,
    output logic [31: 0] o_wrb_FLAGS_write_data,
    output logic         o_wrb_IP_write_enable,
    output logic [31: 0] o_wrb_IP_write_data,

    // =========================
    // Interrupts
    // =========================
    input  logic         i_intr,
    input  logic         i_nmi,
    output logic         o_ferr_n,
    output logic         o_invalidate_cache,
    output logic         o_wbinvd,
    output logic         o_wrb_gdtr_write_enable,
    output logic [15: 0] o_wrb_gdtr_write_limit,
    output logic [31: 0] o_wrb_gdtr_write_base,
    output logic         o_wrb_idtr_write_enable,
    output logic [15: 0] o_wrb_idtr_write_limit,
    output logic [31: 0] o_wrb_idtr_write_base,

    input  logic         clk,
    input  logic         rst_n
);

    logic [15: 0][ 7: 0] ifu_instruction;
    logic                ifu_instruction_valid;
    logic                ifu_segment_fault;
    logic [ 4: 0]        ifu_fifo_count;
    logic [31: 0]        ifu_eip;
    logic                ifu_dec_ready;
    logic                ifu_dec_fire;
    logic [ 3: 0]        ifu_dec_consume_bytes;
    logic                ifu_dec_error;

    logic                uop_valid;
    micro_op_t           uop;
    logic                reg_stage_ready;
    logic                reg_stage_valid;
    logic                exu_stage_ready;

    micro_op_t           reg_uop;
    logic [31: 0]        reg_src1;
    logic [31: 0]        reg_src2;
    logic                reg_cf;
    logic                reg_pf;
    logic                reg_af;
    logic                reg_zf;
    logic                reg_sf;
    logic                reg_of;

    logic                exu_valid;
    logic                mem_busy;
    logic                mem_stall;
    logic                branch_taken;
    logic                pipe_flush;
    logic                pipe_hlt;

    logic                exu_mem_valid;
    logic                exu_mem_we;
    logic [31: 0]        exu_mem_addr;
    logic [31: 0]        exu_mem_wdata;
    logic [31: 0]        mem_rdata;
    logic                mem_done;

    pipeline_controller u_pipe_ctrl (
        .i_branch_taken      (branch_taken),
        .i_mem_stall         (mem_stall),
        .i_multicycle_stall  (1'b0),
        .i_exception_valid   (1'b0),
        .i_hlt               (pipe_hlt),
        .o_stall_ifu         (),
        .o_stall_dec         (),
        .o_stall_reg         (),
        .o_stall_exu         (),
        .o_flush_ifu         (pipe_flush),
        .o_flush_dec         (),
        .o_flush_reg         (),
        .o_flush_exu         (),
        .o_halted            (),
        .clk                 (clk),
        .rst_n               (rst_n)
    );

    exception_interrupt_unit u_eiu (
        .i_exception_valid   (1'b0),
        .i_exception_vector  (8'h0),
        .i_has_error_code    (1'b0),
        .i_error_code        (32'h0),
        .i_external_intr     (i_intr),
        .i_nmi               (i_nmi),
        .i_if_flag           (i_if_flag),
        .i_idtr_base         (i_idtr_base),
        .i_idtr_limit        (i_idtr_limit),
        .i_current_eip       (i_eip),
        .i_current_cs_base   (32'h0),
        .i_cpl               (i_cpl),
        .o_flush_pipeline    (),
        .o_clear_if          (),
        .o_new_eip_valid     (),
        .o_new_eip           (),
        .o_vector            (),
        .o_error_code_valid  (),
        .o_error_code        (),
        .o_ferr_n            (o_ferr_n),
        .i_fpu_exception     (1'b0),
        .clk                 (clk),
        .rst_n               (rst_n)
    );

    stage_1_ifu u_ifu (
        .o_code_valid              (o_code_valid),
        .i_code_ready              (i_code_ready),
        .o_code_address            (o_code_address),
        .i_code_data_read          (i_code_data_read),
        .o_mmu_bus_valid           (o_mmu_valid),
        .i_mmu_bus_ready           (i_mmu_ready),
        .o_mmu_bus_addr            (o_mmu_address),
        .i_mmu_bus_rdata           (i_mmu_data_read),
        .i_protected_mode          (i_protected_mode),
        .i_segment_selector        (i_segment_selector),
        .i_segment_descriptor      (i_segment_descriptor),
        .i_current_privilege_level (i_cpl),
        .i_paging_enable           (i_paging_enable),
        .i_page_directory_base     (i_page_directory_base),
        .i_start                   (1'b1),
        .i_initial_eip             (32'hFFFFFFF0),
        .i_reload_eip              (o_wrb_IP_write_enable),
        .i_reload_eip_value        (o_wrb_IP_write_data),
        .o_instruction             (ifu_instruction),
        .o_instruction_valid       (ifu_instruction_valid),
        .o_segment_fault           (ifu_segment_fault),
        .o_fifo_count              (ifu_fifo_count),
        .o_eip                     (ifu_eip),
        .i_dec_ready               (ifu_dec_ready),
        .i_dec_fire                (ifu_dec_fire),
        .i_dec_consume_bytes       (ifu_dec_consume_bytes),
        .i_dec_error               (ifu_dec_error),
        .clk                       (clk),
        .rst_n                     (rst_n)
    );

    i486_dec_uop_stage u_dec_uop (
        .i_ifu_instruction        (ifu_instruction),
        .i_ifu_instruction_valid  (ifu_instruction_valid),
        .i_ifu_segment_fault      (ifu_segment_fault),
        .i_ifu_fifo_count         (ifu_fifo_count),
        .i_ifu_eip                (ifu_eip),
        .o_ifu_dec_ready          (ifu_dec_ready),
        .o_ifu_dec_fire           (ifu_dec_fire),
        .o_ifu_dec_consume_bytes  (ifu_dec_consume_bytes),
        .o_ifu_dec_error          (ifu_dec_error),
        .i_uop_flush              (pipe_flush),
        .o_uop_valid              (uop_valid),
        .o_uop                    (uop),
        .i_reg_ready              (reg_stage_ready),
        .clk                      (clk),
        .rst_n                    (rst_n)
    );

    stage_4_reg u_reg (
        .i_uop_valid    (uop_valid),
        .i_uop          (uop),
        .o_stage3_ready (reg_stage_ready),
        .o_stage_ready  (reg_stage_ready),
        .o_stage_valid  (reg_stage_valid),
        .i_exu_ready    (exu_stage_ready),
        .i_flush        (pipe_flush),
        .i_gpr_eax      (i_gpr_eax),
        .i_gpr_ebx      (i_gpr_ebx),
        .i_gpr_ecx      (i_gpr_ecx),
        .i_gpr_edx      (i_gpr_edx),
        .i_gpr_esp      (i_gpr_esp),
        .i_gpr_ebp      (i_gpr_ebp),
        .i_gpr_esi      (i_gpr_esi),
        .i_gpr_edi      (i_gpr_edi),
        .i_flag_cf      (i_cf),
        .i_flag_pf      (i_pf),
        .i_flag_af      (i_af),
        .i_flag_zf      (i_zf),
        .i_flag_sf      (i_sf),
        .i_flag_of      (i_of),
        .o_uop          (reg_uop),
        .o_src1_data    (reg_src1),
        .o_src2_data    (reg_src2),
        .o_flag_cf      (reg_cf),
        .o_flag_pf      (reg_pf),
        .o_flag_af      (reg_af),
        .o_flag_zf      (reg_zf),
        .o_flag_sf      (reg_sf),
        .o_flag_of      (reg_of),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    stage_5_exu u_exu (
        .i_uop_valid             (reg_stage_valid),
        .i_uop                   (reg_uop),
        .o_stage_ready           (exu_stage_ready),
        .o_stage_valid           (exu_valid),
        .i_wrb_ready             (1'b1),
        .i_src1_data             (reg_src1),
        .i_src2_data             (reg_src2),
        .i_cf                    (reg_cf),
        .i_pf                    (reg_pf),
        .i_af                    (reg_af),
        .i_zf                    (reg_zf),
        .i_sf                    (reg_sf),
        .i_of                    (reg_of),
        .o_wrb_gpr_enable_EAX    (o_wrb_gpr_write_enable_EAX),
        .o_wrb_gpr_enable_AX     (o_wrb_gpr_write_enable_AX),
        .o_wrb_gpr_enable_AL     (o_wrb_gpr_write_enable_AL),
        .o_wrb_gpr_enable_AH     (o_wrb_gpr_write_enable_AH),
        .o_wrb_gpr_enable_EBX    (o_wrb_gpr_write_enable_EBX),
        .o_wrb_gpr_enable_BX     (o_wrb_gpr_write_enable_BX),
        .o_wrb_gpr_enable_BL     (o_wrb_gpr_write_enable_BL),
        .o_wrb_gpr_enable_BH     (o_wrb_gpr_write_enable_BH),
        .o_wrb_gpr_enable_ECX    (o_wrb_gpr_write_enable_ECX),
        .o_wrb_gpr_enable_CX     (o_wrb_gpr_write_enable_CX),
        .o_wrb_gpr_enable_CL     (o_wrb_gpr_write_enable_CL),
        .o_wrb_gpr_enable_CH     (o_wrb_gpr_write_enable_CH),
        .o_wrb_gpr_enable_EDX    (o_wrb_gpr_write_enable_EDX),
        .o_wrb_gpr_enable_DX     (o_wrb_gpr_write_enable_DX),
        .o_wrb_gpr_enable_DL     (o_wrb_gpr_write_enable_DL),
        .o_wrb_gpr_enable_DH     (o_wrb_gpr_write_enable_DH),
        .o_wrb_gpr_enable_ESP    (o_wrb_gpr_write_enable_ESP),
        .o_wrb_gpr_enable_SP     (o_wrb_gpr_write_enable_SP),
        .o_wrb_gpr_enable_EBP    (o_wrb_gpr_write_enable_EBP),
        .o_wrb_gpr_enable_BP     (o_wrb_gpr_write_enable_BP),
        .o_wrb_gpr_enable_ESI    (o_wrb_gpr_write_enable_ESI),
        .o_wrb_gpr_enable_SI     (o_wrb_gpr_write_enable_SI),
        .o_wrb_gpr_enable_EDI    (o_wrb_gpr_write_enable_EDI),
        .o_wrb_gpr_enable_DI     (o_wrb_gpr_write_enable_DI),
        .o_wrb_seg_enable_es    (),
        .o_wrb_seg_enable_cs    (),
        .o_wrb_seg_enable_ss    (),
        .o_wrb_seg_enable_ds    (),
        .o_wrb_seg_enable_fs    (),
        .o_wrb_seg_enable_gs    (),
        .o_wrb_seg_selector      (),
        .o_wrb_seg_descriptor    (),
        .o_wrb_gpr_data_EAX      (o_wrb_gpr_write_data_EAX),
        .o_wrb_gpr_data_AX       (o_wrb_gpr_write_data_AX),
        .o_wrb_gpr_data_AL       (o_wrb_gpr_write_data_AL),
        .o_wrb_gpr_data_AH       (o_wrb_gpr_write_data_AH),
        .o_wrb_gpr_data_EBX      (o_wrb_gpr_write_data_EBX),
        .o_wrb_gpr_data_BX       (o_wrb_gpr_write_data_BX),
        .o_wrb_gpr_data_BL       (o_wrb_gpr_write_data_BL),
        .o_wrb_gpr_data_BH       (o_wrb_gpr_write_data_BH),
        .o_wrb_gpr_data_ECX      (o_wrb_gpr_write_data_ECX),
        .o_wrb_gpr_data_CX       (o_wrb_gpr_write_data_CX),
        .o_wrb_gpr_data_CL       (o_wrb_gpr_write_data_CL),
        .o_wrb_gpr_data_CH       (o_wrb_gpr_write_data_CH),
        .o_wrb_gpr_data_EDX      (o_wrb_gpr_write_data_EDX),
        .o_wrb_gpr_data_DX       (o_wrb_gpr_write_data_DX),
        .o_wrb_gpr_data_DL       (o_wrb_gpr_write_data_DL),
        .o_wrb_gpr_data_DH       (o_wrb_gpr_write_data_DH),
        .o_wrb_gpr_data_ESP      (o_wrb_gpr_write_data_ESP),
        .o_wrb_gpr_data_SP       (o_wrb_gpr_write_data_SP),
        .o_wrb_gpr_data_EBP      (o_wrb_gpr_write_data_EBP),
        .o_wrb_gpr_data_BP       (o_wrb_gpr_write_data_BP),
        .o_wrb_gpr_data_ESI      (o_wrb_gpr_write_data_ESI),
        .o_wrb_gpr_data_SI       (o_wrb_gpr_write_data_SI),
        .o_wrb_gpr_data_EDI      (o_wrb_gpr_write_data_EDI),
        .o_wrb_gpr_data_DI       (o_wrb_gpr_write_data_DI),
        .o_wrb_flags_enable      (o_wrb_FLAGS_write_enable),
        .o_wrb_flags_data        (o_wrb_FLAGS_write_data),
        .o_wrb_ip_enable         (o_wrb_IP_write_enable),
        .o_wrb_ip_data           (o_wrb_IP_write_data),
        .o_mem_valid             (exu_mem_valid),
        .o_mem_write_enable      (exu_mem_we),
        .o_mem_address           (exu_mem_addr),
        .o_mem_write_data        (exu_mem_wdata),
        .clk                     (clk),
        .rst_n                   (rst_n)
    );

    memory_stage u_mem (
        .i_stage3_valid (exu_mem_valid),
        .o_stage_valid  (),
        .o_stage_ready  (),
        .i_start        (exu_mem_valid),
        .i_is_store     (exu_mem_we),
        .i_addr         (exu_mem_addr),
        .i_wdata        (exu_mem_wdata),
        .o_rdata        (mem_rdata),
        .o_done         (mem_done),
        .o_busy         (mem_busy),
        .o_mem_valid    (o_data_valid),
        .o_mem_we       (o_data_write_enable),
        .o_mem_addr     (o_data_address),
        .o_mem_wdata    (o_data_data_write),
        .i_mem_rdata    (i_data_data_read),
        .i_mem_ready    (i_data_ready),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    assign o_data_io_access = 1'b0;
    assign mem_stall      = mem_busy;
    assign branch_taken   = o_wrb_IP_write_enable;
    assign pipe_hlt       = (reg_uop.uop_opcode == `UOP_MISC) & reg_stage_valid;
    assign o_invalidate_cache   = 1'b0;
    assign o_wbinvd             = 1'b0;
    assign o_wrb_gdtr_write_enable = 1'b0;
    assign o_wrb_gdtr_write_limit  = 16'd0;
    assign o_wrb_gdtr_write_base   = 32'd0;
    assign o_wrb_idtr_write_enable = 1'b0;
    assign o_wrb_idtr_write_limit  = 16'd0;
    assign o_wrb_idtr_write_base   = 32'd0;

endmodule
