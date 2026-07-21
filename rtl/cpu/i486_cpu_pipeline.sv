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
`include "exu_common.h.sv"

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
    output logic [ 1: 0] o_data_size,
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
    input  logic         i_df,

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
    input  logic [31: 0] i_cr0_data,
    input  logic         i_vm,
    input  logic [ 1: 0] i_iopl,
    input  logic [31: 0] i_tss_base,

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
    input  logic [ 7: 0] i_inta_vector,
    output logic         o_inta,
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
    input  logic [79: 0] i_fpu_st2,
    input  logic [79: 0] i_fpu_st3,
    input  logic [79: 0] i_fpu_st4,
    input  logic [79: 0] i_fpu_st5,
    input  logic [79: 0] i_fpu_st6,
    input  logic [79: 0] i_fpu_st7,
    input  logic [15: 0] i_fpu_fcw,
    input  logic [15: 0] i_fpu_fsw,
    output logic         o_fpu_st0_we,
    output logic [79: 0] o_fpu_st0_wdata,
    output logic         o_fpu_st1_we,
    output logic [79: 0] o_fpu_st1_wdata,
    output logic         o_fpu_st2_we,
    output logic [79: 0] o_fpu_st2_wdata,
    output logic         o_fpu_st3_we,
    output logic [79: 0] o_fpu_st3_wdata,
    output logic         o_fpu_st4_we,
    output logic [79: 0] o_fpu_st4_wdata,
    output logic         o_fpu_st5_we,
    output logic [79: 0] o_fpu_st5_wdata,
    output logic         o_fpu_st6_we,
    output logic [79: 0] o_fpu_st6_wdata,
    output logic         o_fpu_st7_we,
    output logic [79: 0] o_fpu_st7_wdata,
    output logic         o_fpu_fsw_we,
    output logic [15: 0] o_fpu_fsw_wdata,
    output logic         o_fpu_exception,

    input  logic         clk,
    input  logic         rst_n
);

    logic [15: 0][ 7: 0] ifu_instruction;
    logic                ifu_instruction_valid;
    logic                ifu_segment_fault;
    logic                ifu_page_fault;
    logic [31: 0]        ifu_fault_linear;
    logic [ 5: 0]        ifu_fifo_count;
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
    logic                eiu_cs_valid;
    logic [15: 0]        eiu_cs_selector;
    logic [63: 0]        eiu_cs_real_desc;
    // Real-mode INT/IRET CS reload: base = selector<<4, limit = FFFFh, code access
    assign eiu_cs_real_desc = {
        {eiu_cs_selector[11: 0], 4'h0},
        16'hFFFF,
        8'h00,
        8'h00,
        8'h9B,
        {4'h0, eiu_cs_selector[15: 12]}
    };
    logic                eiu_esp_we;
    logic [31: 0]        eiu_esp_data;
    logic                eiu_eflags_we;
    logic [31: 0]        eiu_eflags_data;
    logic                eiu_clear_if;
    logic                eiu_inta_req;
    logic                idu_busy;
    logic                slu_busy;
    logic                slu_seg_write_enable;
    logic [ 2: 0]        slu_seg_write_index;
    logic [15: 0]        slu_seg_write_selector;
    logic [63: 0]        slu_seg_write_descriptor;
    logic                slu_ip_write_enable;
    logic [31: 0]        slu_ip_write_data;
    logic                slu_seg_np_fault;
    logic                slu_seg_ss_fault;
    logic                slu_seg_gp_fault;
    logic                slu_bus_valid;
    logic                slu_bus_we;
    logic [31: 0]        slu_bus_addr;
    logic [31: 0]        slu_bus_wdata;
    logic                slu_ready;
    logic                slu_active_r;
    logic                slu_start_pulse;
    logic [15: 0]        exu_seg_load_selector;
    logic                exu_seg_load_valid;
    logic [ 1: 0]        exu_seg_load_op_type;
    logic [ 2: 0]        exu_seg_load_target_index;
    logic [31: 0]        exu_seg_load_far_offset;
    logic [15: 0]        exu_seg_load_far_selector;
    logic [ 1: 0]        slu_req_op_type;
    logic [31: 0]        slu_req_far_offset;
    logic [15: 0]        slu_req_far_selector;
    logic [ 2: 0]        slu_req_target_index;
    logic [15: 0]        slu_req_selector;
    logic                exu_exc_ud_valid;
    logic                exu_exc_de_valid;
    logic                exu_far_ret_new_esp_valid;
    logic [31: 0]        exu_far_ret_new_esp;
    logic [31: 0]        slu_far_ret_new_esp_r;
    logic                slu_far_ret_esp_we;
    logic                idu_slu_req;
    logic [ 1: 0]        slu_op_type_r;
    logic [31: 0]        slu_far_offset_r;
    logic [15: 0]        slu_far_selector_r;
    logic [ 2: 0]        slu_target_index_r;
    logic [15: 0]        slu_selector_r;
    logic                exu_gpr_esp_we;
    logic [31: 0]        exu_gpr_esp_data;
    logic                exu_software_int_valid;
    logic [ 7: 0]        exu_software_int_vector;
    logic [31: 0]        exu_software_int_eip;
    logic                exu_iret_valid;
    logic [31: 0]        current_eflags;
    logic [31: 0]        eflags_if_cleared;
    logic                pipe_mem_valid;
    logic                pipe_mem_we;
    logic [31: 0]        pipe_mem_addr;
    logic [31: 0]        pipe_mem_wdata;
    logic                pipe_mem_ready;
    logic                eiu_mem_valid;
    logic                eiu_mem_we;
    logic [ 1: 0]        eiu_mem_size;
    logic [31: 0]        eiu_mem_addr;
    logic [31: 0]        eiu_mem_wdata;
    logic [31: 0]        eiu_ss_base;
    // SS.base from descriptor cache: {base31:24, base23:16, base15:0}
    assign eiu_ss_base = {
        i_segment_descriptor[`index_reg_seg__SS][31: 24],
        i_segment_descriptor[`index_reg_seg__SS][ 7:  0],
        i_segment_descriptor[`index_reg_seg__SS][63: 48]
    };
    logic                inta_vector_valid;
    logic [15: 0]        wbu_seg_selector;
    logic [ 7: 0]        inta_vector_mux;
    logic                exc_valid;
    logic [ 7: 0]        exc_vector;
    logic                v86_trap_gp;
    logic                x87_nm;
    logic                exc_has_ec;
    logic [31: 0]        exc_error_code;

    logic                exu_flags_enable;
    logic [31: 0]        exu_flags_data;

    logic                exu_mem_valid;
    logic                exu_mem_we;
    logic [ 1: 0]        exu_mem_size;
    logic [31: 0]        exu_mem_addr;
    logic [31: 0]        exu_mem_wdata;
    logic                exu_lsu_seg_force;
    logic [ 2: 0]        exu_lsu_seg_index;
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
    logic [ 2: 0]        lsu_seg_hold_r;
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
    logic                stall_ifu;
    logic                stall_dec;
    logic                stall_reg;
    logic                stall_exu;
    logic                dec_reg_ready;
    // Hold LSU translate result until memory_stage accepts (avoids LSU restart
    // while EXU still asserts mem_valid, and survives the LSU done pulse).
    // Match held effective address so multi-beat ops (LGDT beat2 at addr+4) cannot
    // reuse a stale translate / mem_done from the previous beat.
    logic                lsu_result_hold_r;
    logic [31: 0]        lsu_hold_eff_addr_r;
    logic                lsu_hold_addr_match;
    logic                lsu_hold_addr_mismatch;

    // Requested segment for this EXU mem op (before hold override).
    // MOVS load (DS) → store (ES) often keeps the same SI/DI offset; matching on
    // offset alone would reuse the DS phys addr for the ES store and hang/corrupt.
    logic [2: 0] lsu_seg_req;
    assign lsu_seg_req = exu_lsu_seg_force ? exu_lsu_seg_index :
                         ((reg_uop.uop_opcode == `UOP_PUSH) |
                          (reg_uop.uop_opcode == `UOP_POP)  |
                          (reg_uop.uop_opcode == `UOP_CALL) |
                          (reg_uop.uop_opcode == `UOP_RET)  |
                          ((reg_uop.uop_opcode == `UOP_MISC) &
                           ((reg_uop.uop_immediate[7: 0] == `MISC_SUB_PUSH_SEG) |
                            (reg_uop.uop_immediate[7: 0] == `MISC_SUB_POP_SEG)))
                          ? `index_reg_seg__SS : reg_uop.uop_seg_index);
    assign lsu_hold_addr_match    = lsu_result_hold_r &
                                    (exu_mem_addr == lsu_hold_eff_addr_r) &
                                    (lsu_seg_req == lsu_seg_hold_r);
    assign lsu_hold_addr_mismatch = lsu_result_hold_r &
                                    ((exu_mem_addr != lsu_hold_eff_addr_r) |
                                     (lsu_seg_req != lsu_seg_hold_r));

    assign lsu_mmu_start = exu_mem_valid & ~exu_data_io & ~lsu_mmu_busy &
                           (~lsu_result_hold_r | lsu_hold_addr_mismatch);

    // Latch segment for the outstanding data access so a later uop (default DS)
    // cannot change LSU translation while CMP/LGDT still holds mem_valid.
    assign lsu_seg_index = (lsu_mmu_busy | lsu_result_hold_r) ? lsu_seg_hold_r :
                           lsu_seg_req;

    assign page_fault_event = ifu_page_fault | lsu_page_fault;
    assign seg_fault_event  = ifu_segment_fault | lsu_seg_fault;

    assign pf_cr2_addr = ifu_page_fault ? ifu_fault_linear : lsu_fault_linear;

    assign pf_error_code = {29'h0,
                            i_cpl[0],
                            lsu_page_fault ? exu_mem_we : 1'b0,
                            lsu_page_fault ? lsu_fault_present : 1'b0};

    assign exc_valid      = seg_fault_event | page_fault_event |
                            slu_seg_np_fault | slu_seg_ss_fault | slu_seg_gp_fault |
                            exu_exc_ud_valid | exu_exc_de_valid |
                            ifu_dec_error | (fpu_exception_r & exu_valid) |
                            v86_trap_gp | x87_nm;
    assign exc_vector     = exu_exc_de_valid ? 8'd0 :
                            x87_nm ? 8'd7 :
                            exu_exc_ud_valid ? 8'd6 :
                            ifu_dec_error ? 8'd6 :
                            (fpu_exception_r & exu_valid) ? 8'd16 :
                            slu_seg_np_fault ? 8'd11 :
                            slu_seg_ss_fault ? 8'd12 :
                            (slu_seg_gp_fault | seg_fault_event | v86_trap_gp) ? 8'd13 :
                            page_fault_event ? 8'd14 : 8'd13;
    assign exc_has_ec     = page_fault_event;
    assign exc_error_code = pf_error_code;

    assign pipe_flush     = pipe_flush_ctrl | eiu_flush;
    assign mem_stall      = mem_busy | multicycle_stall | (lsu_mmu_busy & ~exu_data_io) |
                            idu_busy;
    // slu_busy is not in mem_stall: EXU seg_load_pending waits for SLU; including
    // slu_busy here deadlocks retirement on the SLU ready cycle.
    assign mem_start      = exu_data_io ? exu_mem_valid :
                            (exu_mem_valid & lsu_hold_addr_match &
                             ~lsu_seg_fault & ~lsu_page_fault);
    assign mem_phys_addr  = exu_data_io ? exu_mem_addr : lsu_phys_addr;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            lsu_result_hold_r   <= 1'b0;
            lsu_hold_eff_addr_r <= 32'h0;
            lsu_seg_hold_r      <= 3'b0;
        end else begin
            if (lsu_mmu_start) begin
                lsu_seg_hold_r <= lsu_seg_req;
            end
            if (lsu_mmu_done) begin
                lsu_result_hold_r   <= 1'b1;
                lsu_hold_eff_addr_r <= exu_mem_addr;
            end else if (lsu_hold_addr_mismatch |
                         (mem_start & ~exu_data_io & ~mem_busy) |
                         // Keep translate hold until EXU drops the request; clearing on
                         // mem_done while exu_mem_valid is still high restarts LSU and
                         // re-fires access_memory (POP then increments ESP forever).
                         (mem_done & ~exu_mem_valid) |
                         (~exu_mem_valid & ~lsu_mmu_busy)) begin
                lsu_result_hold_r <= 1'b0;
            end
        end
    end

    assign dec_reg_ready = reg_stage_ready & ~stall_reg;

    pipeline_controller u_pipe_ctrl (
        .i_branch_taken      (branch_taken),
        .i_mem_stall         (mem_stall),
        .i_multicycle_stall  (multicycle_stall),
        .i_exception_valid   (eiu_flush),
        .i_hlt               (pipe_hlt),
        .o_stall_ifu         (stall_ifu),
        .o_stall_dec         (stall_dec),
        .o_stall_reg         (stall_reg),
        .o_stall_exu         (stall_exu),
        .o_flush_ifu         (pipe_flush_ctrl),
        .o_flush_dec         (),
        .o_flush_reg         (),
        .o_flush_exu         (),
        .o_halted            (),
        .clk                 (clk),
        .rst_n               (rst_n)
    );

    assign current_eflags = pack_eflags_status(
        {14'h0, i_vm, 1'b0, 1'b0, 1'b0, i_iopl, 1'b0, i_df, i_if_flag, 1'b0,
         1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0},
        i_cf, i_pf, i_af, i_zf, i_sf, i_of);
    assign eflags_if_cleared = current_eflags & ~32'h0000_0200;
    assign inta_vector_mux   = (i_inta_vector != 8'h00) ? i_inta_vector : 8'h20;
    assign inta_vector_valid = eiu_inta_req;
    assign o_inta            = eiu_inta_req;
    assign pipe_mem_ready    = i_data_ready & ~idu_busy & ~slu_busy;
    assign o_data_valid      = slu_busy ? slu_bus_valid :
                                 idu_busy ? eiu_mem_valid : pipe_mem_valid;
    assign o_data_write_enable = slu_busy ? slu_bus_we :
                                   idu_busy ? eiu_mem_we : pipe_mem_we;
    assign o_data_address    = slu_busy ? slu_bus_addr :
                                 idu_busy ? eiu_mem_addr : pipe_mem_addr;
    assign o_data_data_write = slu_busy ? slu_bus_wdata :
                                   idu_busy ? eiu_mem_wdata : pipe_mem_wdata;

    assign idu_slu_req = eiu_cs_valid & i_protected_mode;
    // Present live EXU/EIU request on the start pulse — SLU latches on rise;
    // delayed slu_*_r would feed stale op/selector/offset (often 0 → #GP/null).
    assign slu_req_op_type       = idu_slu_req ? 2'b01 : exu_seg_load_op_type;
    assign slu_req_far_offset    = idu_slu_req ? eiu_new_eip : exu_seg_load_far_offset;
    assign slu_req_far_selector  = idu_slu_req ? eiu_cs_selector : exu_seg_load_far_selector;
    assign slu_req_target_index  = idu_slu_req ? `sreg_index_CS : exu_seg_load_target_index;
    assign slu_req_selector      = idu_slu_req ? eiu_cs_selector : exu_seg_load_selector;
    assign slu_start_pulse = ((exu_seg_load_valid & i_protected_mode) |
                              idu_slu_req) & ~slu_active_r;
    // Include start pulse so bus mux/ready see SLU on the latch cycle.
    assign slu_busy        = slu_active_r | slu_start_pulse;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            slu_active_r          <= 1'b0;
            slu_op_type_r         <= 2'b00;
            slu_far_offset_r      <= 32'h0;
            slu_far_selector_r    <= 16'h0;
            slu_target_index_r    <= 3'b0;
            slu_selector_r        <= 16'h0;
            slu_far_ret_new_esp_r <= 32'h0;
            slu_far_ret_esp_we    <= 1'b0;
        end else begin
            slu_far_ret_esp_we <= 1'b0;
            if (slu_start_pulse) begin
                slu_active_r       <= 1'b1;
                slu_op_type_r      <= slu_req_op_type;
                slu_far_offset_r   <= slu_req_far_offset;
                slu_far_selector_r <= slu_req_far_selector;
                slu_target_index_r <= slu_req_target_index;
                slu_selector_r     <= slu_req_selector;
                if (slu_req_op_type == 2'b11) begin
                    slu_far_ret_new_esp_r <= exu_far_ret_new_esp;
                end
            end else if (slu_active_r & slu_ready) begin
                slu_active_r <= 1'b0;
                if (slu_op_type_r == 2'b11) begin
                    slu_far_ret_esp_we <= 1'b1;
                end
            end
        end
    end

    segment_load_unit u_seg_load (
        .i_valid                 (slu_start_pulse),
        .o_ready                 (slu_ready),
        .i_op_type               (slu_req_op_type),
        .i_protected_mode        (i_protected_mode),
        .i_cpl                   (i_cpl),
        .i_selector              (slu_req_selector),
        .i_target_seg_index      (slu_req_target_index),
        .i_gdtr_base             (i_gdtr_base),
        .i_gdtr_limit            (i_gdtr_limit),
        .i_ldtr_selector         (16'h0),
        .i_ldtr_descriptor       (64'h0),
        .i_far_offset            (slu_req_far_offset),
        .i_far_selector          (slu_req_far_selector),
        .o_seg_write_enable      (slu_seg_write_enable),
        .o_seg_write_index       (slu_seg_write_index),
        .o_seg_write_selector    (slu_seg_write_selector),
        .o_seg_write_descriptor  (slu_seg_write_descriptor),
        .o_ip_write_enable       (slu_ip_write_enable),
        .o_ip_write_data         (slu_ip_write_data),
        .o_segment_not_present   (slu_seg_np_fault),
        .o_stack_segment_fault   (slu_seg_ss_fault),
        .o_segment_fault         (slu_seg_gp_fault),
        .o_bus_valid             (slu_bus_valid),
        .i_bus_ready             (i_data_ready & slu_busy),
        .o_bus_write_enable      (slu_bus_we),
        .o_bus_address           (slu_bus_addr),
        .i_bus_data_read         (i_data_data_read),
        .o_bus_data_write        (slu_bus_wdata),
        .clk                     (clk),
        .rst_n                   (rst_n)
    );

    exception_interrupt_unit u_eiu (
        .i_exception_valid       (exc_valid),
        .i_exception_vector      (exc_vector),
        .i_has_error_code        (exc_has_ec),
        .i_error_code            (exc_error_code),
        .i_external_intr         (i_intr),
        .i_nmi                   (i_nmi),
        .i_if_flag               (i_if_flag),
        .i_software_int_valid    (exu_software_int_valid),
        .i_software_int_vector   (exu_software_int_vector),
        .i_software_int_eip      (exu_software_int_eip),
        .i_iret_valid            (exu_iret_valid),
        .i_idtr_base             (i_idtr_base),
        .i_idtr_limit            (i_idtr_limit),
        .i_protected_mode        (i_protected_mode),
        .i_ss_base               (eiu_ss_base),
        .i_current_eip           (i_eip),
        .i_current_cs_selector   (i_segment_selector[`index_reg_seg__CS]),
        .i_current_ss_selector   (i_segment_selector[`index_reg_seg__SS]),
        .i_current_eflags        (current_eflags),
        .i_current_esp           (i_gpr_esp),
        .i_cpl                   (i_cpl),
        .i_tss_base              (i_tss_base),
        .i_inta_vector_valid     (inta_vector_valid),
        .i_inta_vector           (inta_vector_mux),
        .o_flush_pipeline        (eiu_flush),
        .o_clear_if              (eiu_clear_if),
        .o_new_eip_valid         (eiu_ip_valid),
        .o_new_eip               (eiu_new_eip),
        .o_new_cs_valid          (eiu_cs_valid),
        .o_new_cs_selector       (eiu_cs_selector),
        .o_esp_write_enable      (eiu_esp_we),
        .o_esp_write_data        (eiu_esp_data),
        .o_eflags_write_enable   (eiu_eflags_we),
        .o_eflags_write_data     (eiu_eflags_data),
        .o_vector                (),
        .o_error_code_valid      (),
        .o_error_code            (),
        .o_inta_req              (eiu_inta_req),
        .o_idu_busy              (idu_busy),
        .o_mem_valid             (eiu_mem_valid),
        .i_mem_ready             (i_data_ready & idu_busy),
        .o_mem_write_enable      (eiu_mem_we),
        .o_mem_size              (eiu_mem_size),
        .o_mem_address           (eiu_mem_addr),
        .o_mem_write_data        (eiu_mem_wdata),
        .i_mem_rdata             (i_data_data_read),
        .o_ferr_n                (o_ferr_n),
        .i_fpu_exception         (fpu_exception_r),
        .clk                     (clk),
        .rst_n                   (rst_n)
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
        .i_initial_eip             (32'h0000_FFF0),
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
        .i_stall                   (stall_ifu),
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
        .i_reg_ready              (dec_reg_ready),
        .i_stall                  (stall_dec),
        .i_default_size_32        (i_segment_descriptor[`index_reg_seg__CS][22]),
        .clk                      (clk),
        .rst_n                    (rst_n)
    );

    stage_4_reg u_reg (
        .i_uop_valid    (uop_valid),
        .i_uop          (uop),
        .o_stage3_ready (reg_stage_ready),
        .o_stage_ready  (reg_stage_ready),
        .o_stage_valid  (reg_stage_valid),
        .i_exu_ready    (exu_stage_ready & ~stall_exu),
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
        .i_gpr_eax               (i_gpr_eax),
        .i_gpr_edx               (i_gpr_edx),
        .i_gpr_esp               (i_gpr_esp),
        .i_gpr_ebp               (i_gpr_ebp),
        .i_gpr_ecx               (i_gpr_ecx),
        .i_cr0_data              (i_cr0_data),
        .i_eip                   (i_eip),
        .i_cs_selector           (i_segment_selector[`index_reg_seg__CS]),
        .i_segment_selector      (i_segment_selector),
        .i_slu_ready             (slu_ready),
        .i_cf                    (reg_cf),
        .i_pf                    (reg_pf),
        .i_af                    (reg_af),
        .i_zf                    (reg_zf),
        .i_sf                    (reg_sf),
        .i_of                    (reg_of),
        .i_if_flag               (i_if_flag),
        .i_df                    (i_df),
        .i_iopl                  (i_iopl),
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
        .o_wrb_gpr_enable_ESP    (exu_gpr_esp_we),
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
        .o_seg_load_valid        (exu_seg_load_valid),
        .o_seg_load_op_type      (exu_seg_load_op_type),
        .o_seg_load_target_index (exu_seg_load_target_index),
        .o_seg_load_selector     (exu_seg_load_selector),
        .o_seg_load_far_offset   (exu_seg_load_far_offset),
        .o_seg_load_far_selector (exu_seg_load_far_selector),
        .o_exc_ud_valid          (exu_exc_ud_valid),
        .o_exc_de_valid          (exu_exc_de_valid),
        .o_far_ret_new_esp_valid (exu_far_ret_new_esp_valid),
        .o_far_ret_new_esp       (exu_far_ret_new_esp),
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
        .o_wrb_gpr_data_ESP      (exu_gpr_esp_data),
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
        .o_mem_size              (exu_mem_size),
        .o_mem_address           (exu_mem_addr),
        .o_mem_write_data        (exu_mem_wdata),
        .o_lsu_seg_force         (exu_lsu_seg_force),
        .o_lsu_seg_index         (exu_lsu_seg_index),
        .i_fpu_st0               (i_fpu_st0),
        .i_fpu_st1               (i_fpu_st1),
        .i_fpu_st2               (i_fpu_st2),
        .i_fpu_st3               (i_fpu_st3),
        .i_fpu_st4               (i_fpu_st4),
        .i_fpu_st5               (i_fpu_st5),
        .i_fpu_st6               (i_fpu_st6),
        .i_fpu_st7               (i_fpu_st7),
        .i_fpu_fcw               (i_fpu_fcw),
        .i_fpu_fsw               (i_fpu_fsw),
        .o_fpu_st0_we            (o_fpu_st0_we),
        .o_fpu_st0_wdata         (o_fpu_st0_wdata),
        .o_fpu_st1_we            (o_fpu_st1_we),
        .o_fpu_st1_wdata         (o_fpu_st1_wdata),
        .o_fpu_st2_we            (o_fpu_st2_we),
        .o_fpu_st2_wdata         (o_fpu_st2_wdata),
        .o_fpu_st3_we            (o_fpu_st3_we),
        .o_fpu_st3_wdata         (o_fpu_st3_wdata),
        .o_fpu_st4_we            (o_fpu_st4_we),
        .o_fpu_st4_wdata         (o_fpu_st4_wdata),
        .o_fpu_st5_we            (o_fpu_st5_we),
        .o_fpu_st5_wdata         (o_fpu_st5_wdata),
        .o_fpu_st6_we            (o_fpu_st6_we),
        .o_fpu_st6_wdata         (o_fpu_st6_wdata),
        .o_fpu_st7_we            (o_fpu_st7_we),
        .o_fpu_st7_wdata         (o_fpu_st7_wdata),
        .o_fpu_fsw_we            (o_fpu_fsw_we),
        .o_fpu_fsw_wdata         (o_fpu_fsw_wdata),
        .o_fpu_exception         (fpu_exception_r),
        .o_software_int_valid    (exu_software_int_valid),
        .o_software_int_vector   (exu_software_int_vector),
        .o_software_int_eip      (exu_software_int_eip),
        .o_iret_valid            (exu_iret_valid),
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
        .i_sreg_write_enable     (slu_seg_write_enable |
                                   (eiu_cs_valid & ~i_protected_mode) |
                                   ((exu_seg_es | exu_seg_cs | exu_seg_ss | exu_seg_ds |
                                     exu_seg_fs | exu_seg_gs) & ~i_protected_mode)),
        .i_sreg_write_index      (slu_seg_write_enable ? slu_seg_write_index :
                                   ((eiu_cs_valid & ~i_protected_mode) ? 3'd1 :
                                    (exu_seg_gs ? 3'd5 :
                                     exu_seg_fs ? 3'd4 :
                                     exu_seg_ds ? 3'd3 :
                                     exu_seg_ss ? 3'd2 :
                                     exu_seg_cs ? 3'd1 : 3'd0))),
        .i_sreg_write_selector   (slu_seg_write_enable ? slu_seg_write_selector :
                                   ((eiu_cs_valid & ~i_protected_mode) ? eiu_cs_selector :
                                    exu_seg_selector)),
        .i_sreg_write_descriptor (slu_seg_write_enable ? slu_seg_write_descriptor :
                                   ((eiu_cs_valid & ~i_protected_mode) ? eiu_cs_real_desc :
                                    exu_seg_descriptor)),
        .o_sreg_write_enable     (),
        .o_sreg_write_index      (),
        .o_sreg_write_selector   (wbu_seg_selector),
        .o_sreg_write_descriptor (o_wrb_seg_write_descriptor),
        .i_flags_write_enable    (exu_flags_enable | eiu_eflags_we |
                                   (eiu_clear_if & eiu_ip_valid)),
        .i_flags_write_data      (eiu_eflags_we ? eiu_eflags_data :
                                   (eiu_clear_if ? eflags_if_cleared : exu_flags_data)),
        .o_flags_write_enable    (o_wrb_FLAGS_write_enable),
        .o_flags_write_data      (o_wrb_FLAGS_write_data),
        .i_ip_write_enable       (exu_ip_enable |
                                   (eiu_ip_valid & ~i_protected_mode) | slu_ip_write_enable),
        .i_ip_write_data         (slu_ip_write_enable ? slu_ip_write_data :
                                   (eiu_ip_valid ? eiu_new_eip : exu_ip_data)),
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
    assign o_wrb_seg_es_write_enable = (exu_seg_es & ~i_protected_mode) |
                                        (slu_seg_write_enable & (slu_seg_write_index == 3'd0));
    assign o_wrb_gpr_write_enable_ESP = exu_gpr_esp_we | eiu_esp_we | slu_far_ret_esp_we;
    assign o_wrb_gpr_write_data_ESP   = slu_far_ret_esp_we ? slu_far_ret_new_esp_r :
                                          eiu_esp_we ? eiu_esp_data : exu_gpr_esp_data;
    assign o_wrb_seg_cs_write_enable  = (exu_seg_cs & ~i_protected_mode) |
                                         (eiu_cs_valid & ~i_protected_mode) |
                                         (slu_seg_write_enable & (slu_seg_write_index == 3'd1));
    assign o_wrb_seg_write_selector   = (eiu_cs_valid & ~i_protected_mode) ?
                                         eiu_cs_selector : wbu_seg_selector;
    assign o_wrb_seg_ss_write_enable = (exu_seg_ss & ~i_protected_mode) |
                                        (slu_seg_write_enable & (slu_seg_write_index == 3'd2));
    assign o_wrb_seg_ds_write_enable = (exu_seg_ds & ~i_protected_mode) |
                                        (slu_seg_write_enable & (slu_seg_write_index == 3'd3));
    assign o_wrb_seg_fs_write_enable = (exu_seg_fs & ~i_protected_mode) |
                                        (slu_seg_write_enable & (slu_seg_write_index == 3'd4));
    assign o_wrb_seg_gs_write_enable = (exu_seg_gs & ~i_protected_mode) |
                                        (slu_seg_write_enable & (slu_seg_write_index == 3'd5));
    assign branch_taken   = wbu_ip_enable & ~eiu_ip_valid;
    assign pipe_hlt       = (reg_uop.uop_opcode == `UOP_MISC) &
                              (reg_uop.uop_immediate[7: 0] == `MISC_SUB_HLT) &
                              reg_stage_valid;
    assign o_data_io_access = exu_data_io;
    assign o_data_size      = slu_busy ? 2'b10 :
                              (idu_busy ? eiu_mem_size : exu_mem_size);
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
        .o_mem_valid    (pipe_mem_valid),
        .o_mem_we       (pipe_mem_we),
        .o_mem_addr     (pipe_mem_addr),
        .o_mem_wdata    (pipe_mem_wdata),
        .i_mem_rdata    (i_data_data_read),
        .i_mem_ready    (pipe_mem_ready),
        .clk            (clk),
        .rst_n          (rst_n)
    );

    // V86 sensitive-opcode checker driven from current REG-stage uop
    logic v86_op_cli;
    logic v86_op_sti;
    logic v86_op_pushf;
    logic v86_op_popf;
    logic v86_op_int;
    logic v86_op_iret;
    logic v86_op_in;
    logic v86_op_out;
    assign v86_op_cli = reg_stage_valid & (reg_uop.uop_opcode == `UOP_FLAG_CTRL) &
                        (reg_uop.uop_immediate[7: 0] == 8'h06);
    assign v86_op_sti = reg_stage_valid & (reg_uop.uop_opcode == `UOP_FLAG_CTRL) &
                        (reg_uop.uop_immediate[7: 0] == 8'h07);
    assign v86_op_pushf = reg_stage_valid & (reg_uop.uop_opcode == `UOP_PUSH) &
                          (reg_uop.uop_immediate[7: 0] == `UOP_TAG_PUSHF);
    assign v86_op_popf  = reg_stage_valid & (reg_uop.uop_opcode == `UOP_POP) &
                          (reg_uop.uop_immediate[7: 0] == `UOP_TAG_POPF);
    assign v86_op_int  = reg_stage_valid & (reg_uop.uop_opcode == `UOP_MISC) &
                         (reg_uop.uop_immediate[7: 0] == `MISC_SUB_INT);
    assign v86_op_iret = reg_stage_valid & (reg_uop.uop_opcode == `UOP_MISC) &
                         (reg_uop.uop_immediate[7: 0] == `MISC_SUB_IRET);
    assign v86_op_in   = reg_stage_valid & (reg_uop.uop_opcode == `UOP_MISC) &
                         (reg_uop.uop_immediate[7: 0] == `MISC_SUB_IN);
    assign v86_op_out  = reg_stage_valid & (reg_uop.uop_opcode == `UOP_MISC) &
                         (reg_uop.uop_immediate[7: 0] == `MISC_SUB_OUT);
    v86_sensitive_check u_v86_sensitive (
        .i_vm       (i_vm),
        .i_iopl     (i_iopl),
        .i_op_cli   (v86_op_cli),
        .i_op_sti   (v86_op_sti),
        .i_op_pushf (v86_op_pushf),
        .i_op_popf  (v86_op_popf),
        .i_op_int   (v86_op_int),
        .i_op_iret  (v86_op_iret),
        .i_op_in    (v86_op_in),
        .i_op_out   (v86_op_out),
        .o_trap_gp  (v86_trap_gp)
    );

    // x87 #NM gate (EM|TS) → exception vector 7 via exc_valid/exc_vector
    x87_cr0_gate u_x87_cr0_gate (
        .i_x87_op       (reg_stage_valid & (reg_uop.uop_opcode == `UOP_X87)),
        .i_cr0_em       (i_cr0_data[2]),
        .i_cr0_ts       (i_cr0_data[3]),
        .o_nm_exception (x87_nm)
    );

endmodule
