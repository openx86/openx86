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
    input  logic [31: 0] i_gdtr_base,
    input  logic [15: 0] i_gdtr_limit,
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

    output logic         o_wrb_cr0_write_enable,
    output logic         o_wrb_cr2_write_enable,
    output logic         o_wrb_cr3_write_enable,
    output logic [31: 0] o_wrb_cr_write_data,

    output logic         o_wrb_seg_es_write_enable,
    output logic         o_wrb_seg_cs_write_enable,
    output logic         o_wrb_seg_ss_write_enable,
    output logic         o_wrb_seg_ds_write_enable,
    output logic         o_wrb_seg_fs_write_enable,
    output logic         o_wrb_seg_gs_write_enable,
    output logic [15: 0] o_wrb_seg_write_selector,
    output logic [63: 0] o_wrb_seg_write_descriptor,

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

    input  logic [79: 0] i_fpu_st0,
    input  logic [79: 0] i_fpu_st1,
    output logic         o_fpu_st0_we,
    output logic [79: 0] o_fpu_st0_wdata,
    output logic         o_fpu_st1_we,
    output logic [79: 0] o_fpu_st1_wdata,
    output logic         o_fpu_exception,

    input  logic         clk,
    input  logic         rst_n
);

    logic [15: 0][ 7: 0] ifu_instruction;
    logic                ifu_instruction_valid;
    logic                ifu_segment_fault;
    logic                ifu_page_fault;
    logic [31: 0]        ifu_fault_linear;
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
    logic                multicycle_stall;
    logic                branch_taken;
    logic                pipe_flush;
    logic                pipe_flush_ctrl;
    logic                pipe_hlt;

    logic                eiu_flush;
    logic                eiu_ip_valid;
    logic [31: 0]        eiu_new_eip;
    logic                exc_valid;
    logic [ 7: 0]        exc_vector;
    logic                exc_has_ec;
    logic [31: 0]        exc_error_code;

    logic                exu_flags_enable;
    logic [31: 0]        exu_flags_data;

    logic                exu_mem_valid;
    logic                exu_mem_we;
    logic [31: 0]        exu_mem_addr;
    logic [31: 0]        exu_mem_wdata;
    logic                exu_data_io;
    logic [31: 0]        mem_rdata;
    logic                mem_done;

    logic                exu_ip_enable;
    logic [31: 0]        exu_ip_data;
    logic                wbu_ip_enable;
    logic [31: 0]        wbu_ip_data;

    logic                exu_gdtr_we;
    logic [15: 0]        exu_gdtr_limit;
    logic [31: 0]        exu_gdtr_base;
    logic                exu_idtr_we;
    logic [15: 0]        exu_idtr_limit;
    logic [31: 0]        exu_idtr_base;
    logic                exu_cr_we;
    logic [ 2: 0]        exu_cr_index;
    logic [31: 0]        exu_cr_data;
    logic                exu_inv_cache;
    logic                exu_wbinvd;

    logic                exu_seg_es;
    logic                exu_seg_cs;
    logic                exu_seg_ss;
    logic                exu_seg_ds;
    logic                exu_seg_fs;
    logic                exu_seg_gs;
    logic [15: 0]        exu_seg_selector;
    logic [63: 0]        exu_seg_descriptor;

    logic                load_pending;
    logic [ 2: 0]        load_dest_reg;
    logic                load_wb_valid;
    logic [31: 0]        load_wb_data;
    logic                load_wb_ip_valid;
    logic [31: 0]        load_wb_ip_data;

    logic [31: 0]        exu_gpr_data;

    logic                ifu_mmu_bus_valid;
    logic [31: 0]        ifu_mmu_bus_addr;
    logic                lsu_mmu_bus_valid;
    logic [31: 0]        lsu_mmu_bus_addr;
    logic                lsu_mmu_done;
    logic                lsu_mmu_busy;
    logic [31: 0]        lsu_phys_addr;
    logic                lsu_seg_fault;
    logic                lsu_page_fault;
    logic                lsu_fault_present;
    logic [31: 0]        lsu_fault_linear;
    logic [ 2: 0]        lsu_seg_index;
    logic                mem_translate_done;
    logic                mem_start;
    logic [31: 0]        mem_phys_addr;
    logic                page_fault_event;
    logic                seg_fault_event;
    logic [31: 0]        pf_cr2_addr;
    logic [31: 0]        pf_error_code;
    logic                ifu_mmu_ready;
    logic                lsu_mmu_ready;
    logic [31: 0]        wbu_cr_write_data;

    logic                lsu_mmu_start;
    logic                fpu_exception_r;

    assign lsu_mmu_start = exu_mem_valid & ~exu_data_io;

    assign lsu_seg_index = (reg_uop.uop_opcode == `UOP_PUSH) |
                           (reg_uop.uop_opcode == `UOP_POP)  |
                           (reg_uop.uop_opcode == `UOP_CALL) |
                           (reg_uop.uop_opcode == `UOP_RET)
                           ? `index_reg_seg__SS : reg_uop.uop_seg_index;

    assign page_fault_event = ifu_page_fault | lsu_page_fault;
    assign seg_fault_event  = ifu_segment_fault | lsu_seg_fault;

    assign pf_cr2_addr = ifu_page_fault ? ifu_fault_linear : lsu_fault_linear;

    assign pf_error_code = {29'h0,
                            i_cpl[0],
                            lsu_page_fault ? exu_mem_we : 1'b0,
                            lsu_page_fault ? lsu_fault_present : 1'b0};

    assign exc_valid      = seg_fault_event | page_fault_event;
    assign exc_vector     = page_fault_event ? 8'd14 : 8'd13;
    assign exc_has_ec     = page_fault_event;
    assign exc_error_code = pf_error_code;

    assign pipe_flush     = pipe_flush_ctrl | eiu_flush;
    assign mem_stall      = mem_busy | multicycle_stall | (lsu_mmu_busy & ~exu_data_io);
    assign mem_start      = exu_data_io ? exu_mem_valid :
                            (exu_mem_valid & lsu_mmu_done &
                             ~lsu_seg_fault & ~lsu_page_fault);
    assign mem_phys_addr  = exu_data_io ? exu_mem_addr : lsu_phys_addr;

    pipeline_controller u_pipe_ctrl (
        .i_branch_taken      (branch_taken),
        .i_mem_stall         (mem_stall),
        .i_multicycle_stall  (multicycle_stall),
        .i_exception_valid   (eiu_flush),
        .i_hlt               (pipe_hlt),
        .o_stall_ifu         (),
        .o_stall_dec         (),
        .o_stall_reg         (),
        .o_stall_exu         (),
        .o_flush_ifu         (pipe_flush_ctrl),
        .o_flush_dec         (),
        .o_flush_reg         (),
        .o_flush_exu         (),
        .o_halted            (),
        .clk                 (clk),
        .rst_n               (rst_n)
    );

    exception_interrupt_unit u_eiu (
        .i_exception_valid   (exc_valid),
        .i_exception_vector  (exc_vector),
        .i_has_error_code    (exc_has_ec),
        .i_error_code        (exc_error_code),
        .i_external_intr     (i_intr),
        .i_nmi               (i_nmi),
        .i_if_flag           (i_if_flag),
        .i_idtr_base         (i_idtr_base),
        .i_idtr_limit        (i_idtr_limit),
        .i_current_eip       (i_eip),
        .i_current_cs_base   (32'h0),
        .i_cpl               (i_cpl),
        .o_flush_pipeline    (eiu_flush),
        .o_clear_if          (),
        .o_new_eip_valid     (eiu_ip_valid),
        .o_new_eip           (eiu_new_eip),
        .o_vector            (),
        .o_error_code_valid  (),
        .o_error_code        (),
        .o_ferr_n            (o_ferr_n),
        .i_fpu_exception     (fpu_exception_r),
        .clk                 (clk),
        .rst_n               (rst_n)
    );

    stage_1_ifu u_ifu (
        .o_code_valid              (o_code_valid),
        .i_code_ready              (i_code_ready),
        .o_code_address            (o_code_address),
        .i_code_data_read          (i_code_data_read),
        .o_mmu_bus_valid           (ifu_mmu_bus_valid),
        .i_mmu_bus_ready           (ifu_mmu_ready),
        .o_mmu_bus_addr            (ifu_mmu_bus_addr),
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
        .o_page_fault              (ifu_page_fault),
        .o_fault_linear_address    (ifu_fault_linear),
        .o_fifo_count              (ifu_fifo_count),
        .o_eip                     (ifu_eip),
        .i_dec_ready               (ifu_dec_ready),
        .i_dec_fire                (ifu_dec_fire),
        .i_dec_consume_bytes       (ifu_dec_consume_bytes),
        .i_dec_error               (ifu_dec_error),
        .clk                       (clk),
        .rst_n                     (rst_n)
    );

    mmu_bus_arbiter u_mmu_arb (
        .i_ifu_valid   (ifu_mmu_bus_valid),
        .o_ifu_ready   (ifu_mmu_ready),
        .i_ifu_address (ifu_mmu_bus_addr),
        .i_lsu_valid   (lsu_mmu_bus_valid),
        .o_lsu_ready   (lsu_mmu_ready),
        .i_lsu_address (lsu_mmu_bus_addr),
        .o_mmu_valid   (o_mmu_valid),
        .i_mmu_ready   (i_mmu_ready),
        .o_mmu_address (o_mmu_address),
        .clk           (clk),
        .rst_n         (rst_n)
    );

    lsu_mmu_translate u_lsu_mmu (
        .i_start                 (lsu_mmu_start),
        .i_is_write              (exu_mem_we),
        .i_effective_address     (exu_mem_addr),
        .i_segment_index         (lsu_seg_index),
        .i_protected_mode        (i_protected_mode),
        .i_segment_selector      (i_segment_selector),
        .i_segment_descriptor    (i_segment_descriptor),
        .i_cpl                   (i_cpl),
        .i_paging_enable         (i_paging_enable),
        .i_page_directory_base   (i_page_directory_base),
        .o_done                  (lsu_mmu_done),
        .o_busy                  (lsu_mmu_busy),
        .o_physical_address      (lsu_phys_addr),
        .o_segment_fault         (lsu_seg_fault),
        .o_page_fault            (lsu_page_fault),
        .o_fault_present         (lsu_fault_present),
        .o_fault_linear_address  (lsu_fault_linear),
        .o_mmu_bus_valid         (lsu_mmu_bus_valid),
        .i_mmu_bus_ready         (lsu_mmu_ready),
        .o_mmu_bus_addr          (lsu_mmu_bus_addr),
        .i_mmu_bus_rdata         (i_mmu_data_read),
        .clk                     (clk),
        .rst_n                   (rst_n)
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
        .o_multicycle_stall      (multicycle_stall),
        .i_wrb_ready             (1'b1),
        .i_mem_done              (mem_done),
        .i_mem_rdata             (mem_rdata),
        .i_gdtr_base             (i_gdtr_base),
        .i_gdtr_limit            (i_gdtr_limit),
        .i_idtr_base             (i_idtr_base),
        .i_idtr_limit            (i_idtr_limit),
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
        .o_wrb_seg_enable_es     (exu_seg_es),
        .o_wrb_seg_enable_cs     (exu_seg_cs),
        .o_wrb_seg_enable_ss     (exu_seg_ss),
        .o_wrb_seg_enable_ds     (exu_seg_ds),
        .o_wrb_seg_enable_fs     (exu_seg_fs),
        .o_wrb_seg_enable_gs     (exu_seg_gs),
        .o_wrb_seg_selector      (exu_seg_selector),
        .o_wrb_seg_descriptor    (exu_seg_descriptor),
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
        .o_wrb_flags_enable      (exu_flags_enable),
        .o_wrb_flags_data        (exu_flags_data),
        .o_wrb_ip_enable         (exu_ip_enable),
        .o_wrb_ip_data           (exu_ip_data),
        .o_gdtr_write_enable     (exu_gdtr_we),
        .o_gdtr_write_limit      (exu_gdtr_limit),
        .o_gdtr_write_base       (exu_gdtr_base),
        .o_idtr_write_enable     (exu_idtr_we),
        .o_idtr_write_limit      (exu_idtr_limit),
        .o_idtr_write_base       (exu_idtr_base),
        .o_cr_write_enable       (exu_cr_we),
        .o_cr_write_index        (exu_cr_index),
        .o_cr_write_data         (exu_cr_data),
        .o_invalidate_cache      (exu_inv_cache),
        .o_wbinvd                (exu_wbinvd),
        .o_data_io_access        (exu_data_io),
        .o_mem_valid             (exu_mem_valid),
        .o_mem_write_enable      (exu_mem_we),
        .o_mem_address           (exu_mem_addr),
        .o_mem_write_data        (exu_mem_wdata),
        .i_fpu_st0               (i_fpu_st0),
        .i_fpu_st1               (i_fpu_st1),
        .o_fpu_st0_we            (o_fpu_st0_we),
        .o_fpu_st0_wdata         (o_fpu_st0_wdata),
        .o_fpu_st1_we            (o_fpu_st1_we),
        .o_fpu_st1_wdata         (o_fpu_st1_wdata),
        .o_fpu_exception         (fpu_exception_r),
        .clk                     (clk),
        .rst_n                   (rst_n)
    );

    stage_6_wbu u_wbu (
        .i_stage4_valid          (exu_valid),
        .o_stage_valid           (),
        .i_stage5_ready          (1'b1),
        .o_stage4_ready          (),
        .i_gpr_write_enable      (1'b0),
        .i_gpr_write_index       (3'b0),
        .i_gpr_write_data        (32'h0),
        .o_gpr_write_enable      (),
        .o_gpr_write_index       (),
        .o_gpr_write_data        (),
        .i_sreg_write_enable     (exu_seg_es | exu_seg_cs | exu_seg_ss | exu_seg_ds | exu_seg_fs | exu_seg_gs),
        .i_sreg_write_index      (3'b0),
        .i_sreg_write_selector   (exu_seg_selector),
        .i_sreg_write_descriptor (exu_seg_descriptor),
        .o_sreg_write_enable     (),
        .o_sreg_write_index      (),
        .o_sreg_write_selector   (o_wrb_seg_write_selector),
        .o_sreg_write_descriptor (o_wrb_seg_write_descriptor),
        .i_flags_write_enable    (exu_flags_enable),
        .i_flags_write_data      (exu_flags_data),
        .o_flags_write_enable    (o_wrb_FLAGS_write_enable),
        .o_flags_write_data      (o_wrb_FLAGS_write_data),
        .i_ip_write_enable       (exu_ip_enable | eiu_ip_valid),
        .i_ip_write_data         (eiu_ip_valid ? eiu_new_eip : exu_ip_data),
        .o_ip_write_enable       (wbu_ip_enable),
        .o_ip_write_data         (wbu_ip_data),
        .i_cr_write_enable       (exu_cr_we),
        .i_cr_write_index        (exu_cr_index),
        .i_cr_write_data         (exu_cr_data),
        .o_cr_write_enable       (),
        .o_cr_write_index        (),
        .o_cr_write_data         (wbu_cr_write_data),
        .i_dr_write_enable       (1'b0),
        .i_dr_write_index        (3'b0),
        .i_dr_write_data         (32'h0),
        .o_dr_write_enable       (),
        .o_dr_write_index        (),
        .o_dr_write_data         (),
        .i_tr_write_enable       (1'b0),
        .i_tr_write_index        (3'b0),
        .i_tr_write_data         (32'h0),
        .o_tr_write_enable       (),
        .o_tr_write_index        (),
        .o_tr_write_data         (),
        .i_gdtr_write_enable     (exu_gdtr_we),
        .i_gdtr_write_limit      (exu_gdtr_limit),
        .i_gdtr_write_base       (exu_gdtr_base),
        .o_gdtr_write_enable     (o_wrb_gdtr_write_enable),
        .o_gdtr_write_limit      (o_wrb_gdtr_write_limit),
        .o_gdtr_write_base       (o_wrb_gdtr_write_base),
        .i_idtr_write_enable     (exu_idtr_we),
        .i_idtr_write_limit      (exu_idtr_limit),
        .i_idtr_write_base       (exu_idtr_base),
        .o_idtr_write_enable     (o_wrb_idtr_write_enable),
        .o_idtr_write_limit      (o_wrb_idtr_write_limit),
        .o_idtr_write_base       (o_wrb_idtr_write_base),
        .i_invalidate_cache      (exu_inv_cache),
        .i_wbinvd                (exu_wbinvd),
        .o_invalidate_cache      (o_invalidate_cache),
        .o_wbinvd                (o_wbinvd),
        .i_mem_valid             (exu_mem_valid),
        .i_mem_write_enable      (exu_mem_we),
        .i_mem_address           (exu_mem_addr),
        .i_mem_write_data        (exu_mem_wdata),
        .o_mem_valid             (),
        .o_mem_write_enable      (),
        .o_mem_address           (),
        .o_mem_write_data        (),
        .clk                     (clk),
        .rst_n                   (rst_n)
    );

    assign o_wrb_IP_write_enable = wbu_ip_enable;
    assign o_wrb_IP_write_data   = wbu_ip_data;
    assign o_wrb_cr0_write_enable = exu_cr_we & (exu_cr_index == 3'd0);
    assign o_wrb_cr2_write_enable = page_fault_event | (exu_cr_we & (exu_cr_index == 3'd2));
    assign o_wrb_cr3_write_enable = exu_cr_we & (exu_cr_index == 3'd3);
    assign o_wrb_cr_write_data    = page_fault_event ? pf_cr2_addr : wbu_cr_write_data;
    assign o_wrb_seg_es_write_enable = exu_seg_es;
    assign o_wrb_seg_cs_write_enable = exu_seg_cs;
    assign o_wrb_seg_ss_write_enable = exu_seg_ss;
    assign o_wrb_seg_ds_write_enable = exu_seg_ds;
    assign o_wrb_seg_fs_write_enable = exu_seg_fs;
    assign o_wrb_seg_gs_write_enable = exu_seg_gs;
    assign branch_taken   = wbu_ip_enable & ~eiu_ip_valid;
    assign pipe_hlt       = (reg_uop.uop_opcode == `UOP_MISC) &
                              (reg_uop.uop_immediate[7: 0] == `MISC_SUB_HLT) &
                              reg_stage_valid;
    assign o_data_io_access = exu_data_io;
    assign o_fpu_exception  = fpu_exception_r;

    memory_stage u_mem (
        .i_stage3_valid (mem_start),
        .o_stage_valid  (),
        .o_stage_ready  (),
        .i_start        (mem_start),
        .i_is_store     (exu_mem_we),
        .i_addr         (mem_phys_addr),
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

endmodule
