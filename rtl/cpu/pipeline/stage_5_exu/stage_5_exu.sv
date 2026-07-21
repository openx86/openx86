// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without tmp_restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : stage_5_exu.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Execute unit — receives micro_op_t and operand data from
//                stage_4_reg, decodes uop to sub-unit control signals,
//                dispatches to ALU/branch/muldiv/FPU/AGU/LSU
// ============================================================================

`include "openx86_defs.h.sv"
`include "exu_common.h.sv"

module stage_5_exu (
    // =========================
    // Pipeline handshake
    // =========================
    input  logic                i_uop_valid,
    input  micro_op_t           i_uop,
    output logic                o_stage_ready,
    output logic                o_stage_valid,
    output logic                o_multicycle_stall,
    input  logic                i_wrb_ready,

    input  logic                i_mem_done,
    input  logic [31: 0]        i_mem_rdata,
    input  logic [31: 0]        i_gdtr_base,
    input  logic [15: 0]        i_gdtr_limit,
    input  logic [31: 0]        i_idtr_base,
    input  logic [15: 0]        i_idtr_limit,

    // =========================
    // Operand data from stage_4_reg
    // =========================
    input  logic [31: 0]        i_src1_data,
    input  logic [31: 0]        i_src2_data,
    input  logic [31: 0]        i_gpr_esp,
    input  logic [31: 0]        i_gpr_ebp,
    input  logic [31: 0]        i_cr0_data,
    input  logic [31: 0]        i_eip,
    input  logic [15: 0]        i_cs_selector,
    input  logic                i_slu_ready,

    // =========================
    // Flag inputs from stage_4_reg
    // =========================
    input  logic                i_cf,
    input  logic                i_pf,
    input  logic                i_af,
    input  logic                i_zf,
    input  logic                i_sf,
    input  logic                i_of,
    input  logic                i_if_flag,
    input  logic                i_df,
    input  logic [ 1: 0]        i_iopl,

    // =========================
    // Write-back outputs to i486_cpu_core
    // =========================
    output logic                o_wrb_gpr_enable_EAX,
    output logic                o_wrb_gpr_enable_AX,
    output logic                o_wrb_gpr_enable_AL,
    output logic                o_wrb_gpr_enable_AH,
    output logic                o_wrb_gpr_enable_EBX,
    output logic                o_wrb_gpr_enable_BX,
    output logic                o_wrb_gpr_enable_BL,
    output logic                o_wrb_gpr_enable_BH,
    output logic                o_wrb_gpr_enable_ECX,
    output logic                o_wrb_gpr_enable_CX,
    output logic                o_wrb_gpr_enable_CL,
    output logic                o_wrb_gpr_enable_CH,
    output logic                o_wrb_gpr_enable_EDX,
    output logic                o_wrb_gpr_enable_DX,
    output logic                o_wrb_gpr_enable_DL,
    output logic                o_wrb_gpr_enable_DH,
    output logic                o_wrb_gpr_enable_ESP,
    output logic                o_wrb_gpr_enable_SP,
    output logic                o_wrb_gpr_enable_EBP,
    output logic                o_wrb_gpr_enable_BP,
    output logic                o_wrb_gpr_enable_ESI,
    output logic                o_wrb_gpr_enable_SI,
    output logic                o_wrb_gpr_enable_EDI,
    output logic                o_wrb_gpr_enable_DI,
    output logic [31: 0]        o_wrb_gpr_data_EAX,
    output logic [15: 0]        o_wrb_gpr_data_AX,
    output logic [ 7: 0]        o_wrb_gpr_data_AL,
    output logic [ 7: 0]        o_wrb_gpr_data_AH,
    output logic [31: 0]        o_wrb_gpr_data_EBX,
    output logic [15: 0]        o_wrb_gpr_data_BX,
    output logic [ 7: 0]        o_wrb_gpr_data_BL,
    output logic [ 7: 0]        o_wrb_gpr_data_BH,
    output logic [31: 0]        o_wrb_gpr_data_ECX,
    output logic [15: 0]        o_wrb_gpr_data_CX,
    output logic [ 7: 0]        o_wrb_gpr_data_CL,
    output logic [ 7: 0]        o_wrb_gpr_data_CH,
    output logic [31: 0]        o_wrb_gpr_data_EDX,
    output logic [15: 0]        o_wrb_gpr_data_DX,
    output logic [ 7: 0]        o_wrb_gpr_data_DL,
    output logic [ 7: 0]        o_wrb_gpr_data_DH,
    output logic [31: 0]        o_wrb_gpr_data_ESP,
    output logic [15: 0]        o_wrb_gpr_data_SP,
    output logic [31: 0]        o_wrb_gpr_data_EBP,
    output logic [15: 0]        o_wrb_gpr_data_BP,
    output logic [31: 0]        o_wrb_gpr_data_ESI,
    output logic [15: 0]        o_wrb_gpr_data_SI,
    output logic [31: 0]        o_wrb_gpr_data_EDI,
    output logic [15: 0]        o_wrb_gpr_data_DI,
    output logic                o_wrb_seg_enable_es,
    output logic                o_wrb_seg_enable_cs,
    output logic                o_wrb_seg_enable_ss,
    output logic                o_wrb_seg_enable_ds,
    output logic                o_wrb_seg_enable_fs,
    output logic                o_wrb_seg_enable_gs,
    output logic [15: 0]        o_wrb_seg_selector,
    output logic [63: 0]        o_wrb_seg_descriptor,

    output logic                o_seg_load_valid,
    output logic [ 1: 0]        o_seg_load_op_type,
    output logic [ 2: 0]        o_seg_load_target_index,
    output logic [15: 0]        o_seg_load_selector,
    output logic [31: 0]        o_seg_load_far_offset,
    output logic [15: 0]        o_seg_load_far_selector,

    output logic                o_exc_ud_valid,
    output logic                o_exc_de_valid,

    output logic                o_far_ret_new_esp_valid,
    output logic [31: 0]        o_far_ret_new_esp,
    output logic                o_wrb_flags_enable,
    output logic [31: 0]        o_wrb_flags_data,
    output logic                o_wrb_ip_enable,
    output logic [31: 0]        o_wrb_ip_data,

    output logic                o_gdtr_write_enable,
    output logic [15: 0]        o_gdtr_write_limit,
    output logic [31: 0]        o_gdtr_write_base,
    output logic                o_idtr_write_enable,
    output logic [15: 0]        o_idtr_write_limit,
    output logic [31: 0]        o_idtr_write_base,
    output logic                o_cr_write_enable,
    output logic [ 2: 0]        o_cr_write_index,
    output logic [31: 0]        o_cr_write_data,
    output logic                o_invalidate_cache,
    output logic                o_wbinvd,
    output logic                o_data_io_access,

    output logic                o_mem_valid,
    output logic                o_mem_write_enable,
    output logic [31: 0]        o_mem_address,
    output logic [31: 0]        o_mem_write_data,

    input  logic [79: 0]        i_fpu_st0,
    input  logic [79: 0]        i_fpu_st1,
    input  logic [79: 0]        i_fpu_st2,
    input  logic [79: 0]        i_fpu_st3,
    input  logic [79: 0]        i_fpu_st4,
    input  logic [79: 0]        i_fpu_st5,
    input  logic [79: 0]        i_fpu_st6,
    input  logic [79: 0]        i_fpu_st7,
    input  logic [15: 0]        i_fpu_fcw,
    input  logic [15: 0]        i_fpu_fsw,
    output logic                o_fpu_st0_we,
    output logic [79: 0]        o_fpu_st0_wdata,
    output logic                o_fpu_st1_we,
    output logic [79: 0]        o_fpu_st1_wdata,
    output logic                o_fpu_st2_we,
    output logic [79: 0]        o_fpu_st2_wdata,
    output logic                o_fpu_st3_we,
    output logic [79: 0]        o_fpu_st3_wdata,
    output logic                o_fpu_st4_we,
    output logic [79: 0]        o_fpu_st4_wdata,
    output logic                o_fpu_st5_we,
    output logic [79: 0]        o_fpu_st5_wdata,
    output logic                o_fpu_st6_we,
    output logic [79: 0]        o_fpu_st6_wdata,
    output logic                o_fpu_st7_we,
    output logic [79: 0]        o_fpu_st7_wdata,
    output logic                o_fpu_fsw_we,
    output logic [15: 0]        o_fpu_fsw_wdata,
    output logic                o_fpu_exception,

    output logic                o_software_int_valid,
    output logic [ 7: 0]        o_software_int_vector,
    output logic                o_iret_valid,

    // =========================
    // Clock and tmp_reset
    // =========================
    input  logic                clk,
    input  logic                rst_n
);

    logic [31: 0] src1_data;
    logic [31: 0] src2_data;
    logic [31: 0] immediate;
    logic [31: 0] displacement;
    logic [ 2: 0] dest_reg;
    logic [ 3: 0] tttn;
    logic         has_imm;
    logic         has_disp;
    logic         mem_access;
    logic         is_store;
    logic [ 5: 0] uop_opcode;

    logic [31: 0] tmp_result;
    logic         new_cf;
    logic         new_pf;
    logic         new_af;
    logic         new_zf;
    logic         new_sf;
    logic         new_of;
    logic [31: 0] flags_data;
    logic [31: 0] eflags_base;
    // Preserve system flags across ALU flag writes (IF/DF/IOPL).
    assign eflags_base = {14'h0, 1'b0, 1'b0, 1'b0, 1'b0, i_iopl, 1'b0,
                          i_df, i_if_flag, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0, 1'b1, 1'b0};
    logic         write_gpr;
    logic         write_flags;
    logic         write_ip;
    logic [31: 0] ip_data;
    logic         mem_valid;
    logic         mem_write_enable;
    logic [31: 0] mem_address;
    logic [31: 0] mem_write_data;

    logic         load_pending_r;
    logic         seg_load_pending_r;
    logic         seg_load_complete_r;
    logic [ 2: 0] load_dest_r;
    logic         load_complete_we;
    logic [31: 0] load_complete_data;
    logic         mem_op_complete_r;
    logic [ 7: 0] mem_op_gen_r;
    logic [ 7: 0] mem_op_complete_gen_r;
    logic         alu_wb_done_r;
    logic         ret_redirect_r;
    logic         ret_redirect_bubble_r;
    logic         misc_load_pending_r;
    logic [ 7: 0] misc_subcode_r;
    logic         ret_pending_r;
    logic [ 1: 0] far_ind_step_r;
    logic [31: 0] far_ind_offset_r;
    logic [31: 0] far_ind_addr_r;
    // LGDT/LIDT beat2: set when beat0 is latched and addr+4 is issued; next mem_done
    // commits base[31:16]. Prevents reusing beat0 rdata (→ gdtr=003779f0 bug).
    logic         far_ind_beat2_issued_r;
    logic [31: 0] far_ind_hi_r;
    logic         far_ind_gdtr_commit_r;
    logic         far_ind_beat2_ok;
    logic         far_ind_beat2_rdata_fresh;
    logic         seg_load_valid;
    logic [ 1: 0] seg_load_op_type;
    logic [ 2: 0] seg_load_target_index;
    logic [15: 0] seg_load_selector;
    logic [31: 0] seg_load_far_offset;
    logic [15: 0] seg_load_far_selector;
    logic         far_call_pending_r;
    logic [ 1: 0] far_call_step_r;
    logic [31: 0] far_call_esp_base_r;
    logic [31: 0] far_call_far_offset_r;
    logic [15: 0] far_call_far_selector_r;
    logic         far_ret_new_esp_valid;
    // Hold mem request while waiting for LSU/memory_stage (comb path clears when pending)
    logic         mem_hold_valid_r;
    logic         mem_hold_we_r;
    logic         mem_hold_io_r;
    logic [31: 0] mem_hold_addr_r;
    logic [31: 0] mem_hold_wdata_r;
    logic [31: 0] far_ret_new_esp;
    logic         exc_ud_valid;
    logic         exc_de_valid;

    // Sticky complete is tagged with mem_op_gen so a later uop (pipe always
    // valid) cannot inherit the previous op's complete and skip its own issue.
    // gen_eff bumps combinationally on uop change so the new op can issue
    // the same cycle it arrives (NBA alone would leave one dead cycle with
    // stale moc_eff=1).
    logic [63: 0] uop_fp;
    logic [63: 0] uop_fp_r;
    logic         uop_changed;
    logic [ 7: 0] mem_op_gen_eff;
    logic         mem_op_complete_eff;
    assign uop_fp = {18'b0, i_uop.uop_opcode, i_uop.uop_dest_reg, i_uop.uop_immediate};
    assign uop_changed = i_uop_valid & (uop_fp != uop_fp_r);
    assign mem_op_gen_eff = mem_op_gen_r + (uop_changed ? 8'd1 : 8'd0);
    // ALU/branch after IN/OUT must not inherit sticky complete (would skip NOT/TEST
    // writeback in SeaBIOS serial wait: in/not/test/jz).
    assign mem_op_complete_eff = mem_op_complete_r &
                                 (mem_op_complete_gen_r == mem_op_gen_eff) &
                                 (uop_opcode != `UOP_NOT) &
                                 (uop_opcode != `UOP_TEST) &
                                 (uop_opcode != `UOP_BRANCH) &
                                 (uop_opcode != `UOP_AND) &
                                 (uop_opcode != `UOP_OR) &
                                 (uop_opcode != `UOP_XOR) &
                                 (uop_opcode != `UOP_ADD) &
                                 (uop_opcode != `UOP_SUB) &
                                 (uop_opcode != `UOP_INC) &
                                 (uop_opcode != `UOP_DEC);

    assign far_ind_beat2_ok =
        far_ind_beat2_issued_r &&
        (far_ind_step_r != 2'd0) &&
        (mem_hold_addr_r == (far_ind_addr_r + 32'd4));
    // Reject stale completions that replay beat0's dword (seen as gdtr=003779f0).
    assign far_ind_beat2_rdata_fresh = (i_mem_rdata != far_ind_offset_r);

    logic         mov_seg_real_enable;
    logic [ 2: 0] mov_seg_real_index;
    logic [15: 0] mov_seg_real_selector;

    logic         gdtr_we;
    logic [15: 0] gdtr_limit;
    logic [31: 0] gdtr_base;
    logic         idtr_we;
    logic [15: 0] idtr_limit;
    logic [31: 0] idtr_base;
    logic         cr_we;
    logic [ 2: 0] cr_index;
    logic [31: 0] cr_data;
    logic         inv_cache;
    logic         wbinvd_cmd;
    logic         data_io_access;
    logic         software_int_valid;
    logic [ 7: 0] software_int_vector;
    logic         iret_valid;

    logic         x87_valid;
    logic [79: 0] x87_st0_out;
    logic [79: 0] x87_st1_out;
    logic [79: 0] x87_st2_out;
    logic [79: 0] x87_st3_out;
    logic [79: 0] x87_st4_out;
    logic [79: 0] x87_st5_out;
    logic [79: 0] x87_st6_out;
    logic [79: 0] x87_st7_out;
    logic         x87_st0_we;
    logic         x87_st1_we;
    logic         x87_st2_we;
    logic         x87_st3_we;
    logic         x87_st4_we;
    logic         x87_st5_we;
    logic         x87_st6_we;
    logic         x87_st7_we;
    logic [15: 0] x87_fsw_out;
    logic         x87_fsw_we;
    exu_result_t  x87_result;

    logic [31: 0] cpuid_eax;
    logic [31: 0] cpuid_ebx;
    logic [31: 0] cpuid_ecx;
    logic [31: 0] cpuid_edx;

    assign src1_data = i_src1_data;
    assign src2_data = i_src2_data;
    assign immediate = i_uop.uop_immediate;
    assign displacement = i_uop.uop_displacement;
    assign dest_reg = i_uop.uop_dest_reg;
    assign tttn = i_uop.uop_tttn;
    assign has_imm = i_uop.uop_has_imm;
    assign has_disp = i_uop.uop_has_disp;
    assign mem_access = i_uop.uop_mem_access;
    assign is_store = i_uop.uop_is_store;
    assign uop_opcode = i_uop.uop_opcode;
    // EA = base + (index << scale) + disp. Index-only SIB (e.g. jmp *disp(,%ecx,4))
    // uses agu_index + src2; plain [reg] uses agu_base + src1.
    logic [31: 0] agu_addr;
    logic [31: 0] agu_index_term;
    assign agu_index_term = i_uop.uop_agu_index ?
                            (src2_data << i_uop.uop_sib_scale) : 32'h0;
    assign agu_addr = (i_uop.uop_agu_base ? src1_data : 32'h0) +
                      agu_index_term +
                      (has_disp ? displacement : 32'h0);

    logic         disp_handled;
    exu_dispatch_out_t disp_out;

    exu_dispatcher u_dispatcher (
        .i_valid         (i_uop_valid & ~load_pending_r),
        .i_uop_opcode    (uop_opcode),
        .i_src1_data     (src1_data),
        .i_src2_data     (src2_data),
        .i_immediate     (immediate),
        .i_displacement  (displacement),
        .i_cf            (i_cf),
        .i_has_imm       (has_imm),
        .i_has_disp      (has_disp),
        .i_mem_access    (mem_access),
        .i_is_store      (is_store),
        .i_agu_base      (i_uop.uop_agu_base),
        .i_agu_index     (i_uop.uop_agu_index),
        .i_sib_scale     (i_uop.uop_sib_scale),
        .i_tttn          (tttn),
        .i_pf            (i_pf),
        .i_af            (i_af),
        .i_zf            (i_zf),
        .i_sf            (i_sf),
        .i_of            (i_of),
        .i_dividend      ({src1_data, src2_data}),
        .i_cpuid_eax     (cpuid_eax),
        .o_handled       (disp_handled),
        .o_dispatch      (disp_out)
    );

    assign x87_valid = i_uop_valid & (uop_opcode == `UOP_X87) & ~load_pending_r;

    exu_x87 u_x87 (
        .i_valid         (x87_valid),
        .i_x87_subop     (i_uop.uop_eee),
        .i_sti_index     (i_uop.uop_src2_reg),
        .i_mem_data      (i_mem_rdata),
        .i_st0           (i_fpu_st0),
        .i_st1           (i_fpu_st1),
        .i_st2           (i_fpu_st2),
        .i_st3           (i_fpu_st3),
        .i_st4           (i_fpu_st4),
        .i_st5           (i_fpu_st5),
        .i_st6           (i_fpu_st6),
        .i_st7           (i_fpu_st7),
        .i_fcw           (i_fpu_fcw),
        .i_fsw           (i_fpu_fsw),
        .o_st0           (x87_st0_out),
        .o_st1           (x87_st1_out),
        .o_st2           (x87_st2_out),
        .o_st3           (x87_st3_out),
        .o_st4           (x87_st4_out),
        .o_st5           (x87_st5_out),
        .o_st6           (x87_st6_out),
        .o_st7           (x87_st7_out),
        .o_st0_we        (x87_st0_we),
        .o_st1_we        (x87_st1_we),
        .o_st2_we        (x87_st2_we),
        .o_st3_we        (x87_st3_we),
        .o_st4_we        (x87_st4_we),
        .o_st5_we        (x87_st5_we),
        .o_st6_we        (x87_st6_we),
        .o_st7_we        (x87_st7_we),
        .o_fsw           (x87_fsw_out),
        .o_fsw_we        (x87_fsw_we),
        .o_fpu_exception (o_fpu_exception),
        .o_result        (x87_result),
        .clk             (clk),
        .rst_n           (rst_n)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            o_fpu_st0_we    <= 1'b0;
            o_fpu_st1_we    <= 1'b0;
            o_fpu_st2_we    <= 1'b0;
            o_fpu_st3_we    <= 1'b0;
            o_fpu_st4_we    <= 1'b0;
            o_fpu_st5_we    <= 1'b0;
            o_fpu_st6_we    <= 1'b0;
            o_fpu_st7_we    <= 1'b0;
            o_fpu_fsw_we    <= 1'b0;
            o_fpu_st0_wdata <= 80'h0;
            o_fpu_st1_wdata <= 80'h0;
            o_fpu_st2_wdata <= 80'h0;
            o_fpu_st3_wdata <= 80'h0;
            o_fpu_st4_wdata <= 80'h0;
            o_fpu_st5_wdata <= 80'h0;
            o_fpu_st6_wdata <= 80'h0;
            o_fpu_st7_wdata <= 80'h0;
            o_fpu_fsw_wdata <= 16'h0;
        end else begin
            o_fpu_st0_we    <= x87_st0_we;
            o_fpu_st1_we    <= x87_st1_we;
            o_fpu_st2_we    <= x87_st2_we;
            o_fpu_st3_we    <= x87_st3_we;
            o_fpu_st4_we    <= x87_st4_we;
            o_fpu_st5_we    <= x87_st5_we;
            o_fpu_st6_we    <= x87_st6_we;
            o_fpu_st7_we    <= x87_st7_we;
            o_fpu_fsw_we    <= x87_fsw_we;
            o_fpu_st0_wdata <= x87_st0_out;
            o_fpu_st1_wdata <= x87_st1_out;
            o_fpu_st2_wdata <= x87_st2_out;
            o_fpu_st3_wdata <= x87_st3_out;
            o_fpu_st4_wdata <= x87_st4_out;
            o_fpu_st5_wdata <= x87_st5_out;
            o_fpu_st6_wdata <= x87_st6_out;
            o_fpu_st7_wdata <= x87_st7_out;
            o_fpu_fsw_wdata <= x87_fsw_out;
        end
    end

    always_comb begin
        tmp_result = 32'd0;
        new_cf = i_cf;
        new_pf = i_pf;
        new_af = i_af;
        new_zf = i_zf;
        new_sf = i_sf;
        new_of = i_of;
        flags_data = pack_eflags_status(eflags_base, i_cf, i_pf, i_af, i_zf, i_sf, i_of);
        write_gpr = 1'b0;
        write_flags = 1'b0;
        write_ip = 1'b0;
        ip_data = 32'd0;
        mem_valid = 1'b0;
        mem_write_enable = 1'b0;
        mem_address = 32'd0;
        mem_write_data = 32'd0;
        gdtr_we          = 1'b0;
        gdtr_limit       = 16'd0;
        gdtr_base        = 32'd0;
        idtr_we          = 1'b0;
        idtr_limit       = 16'd0;
        idtr_base        = 32'd0;
        cr_we            = 1'b0;
        cr_index         = 3'd0;
        cr_data          = 32'd0;
        inv_cache        = 1'b0;
        wbinvd_cmd       = 1'b0;
        data_io_access   = 1'b0;
        software_int_valid  = 1'b0;
        software_int_vector = 8'h0;
        iret_valid          = 1'b0;
        seg_load_valid      = 1'b0;
        seg_load_op_type    = 2'b00;
        seg_load_target_index = 3'b0;
        seg_load_selector   = 16'h0;
        seg_load_far_offset = 32'h0;
        seg_load_far_selector = 16'h0;
        exc_ud_valid        = 1'b0;
        exc_de_valid        = 1'b0;
        far_ret_new_esp_valid = 1'b0;
        far_ret_new_esp     = 32'h0;
        mov_seg_real_enable = 1'b0;
        mov_seg_real_index  = 3'b0;
        mov_seg_real_selector = 16'h0;

        if (i_uop_valid && ~load_pending_r && ~mem_op_complete_eff) begin
            // Memory-form CMP: load first; ALU compare runs on i_mem_done.
            if (mem_access && (uop_opcode == `UOP_CMP) && ~is_store) begin
                mem_address      = agu_addr;
                mem_valid        = 1'b1;
                mem_write_enable = 1'b0;
            end else if (disp_handled) begin
                tmp_result       = disp_out.data.result;
                new_cf           = disp_out.data.cf;
                new_pf           = disp_out.data.pf;
                new_af           = disp_out.data.af;
                new_zf           = disp_out.data.zf;
                new_sf           = disp_out.data.sf;
                new_of           = disp_out.data.of;
                write_gpr        = disp_out.write_gpr;
                write_flags      = disp_out.write_flags;
                write_ip         = disp_out.write_ip;
                ip_data          = disp_out.ip_data;
                mem_address      = disp_out.data.mem_address;
                mem_write_data   = disp_out.data.mem_write_data;
                mem_write_enable = disp_out.data.mem_write_enable;
                // Keep mem_valid while load_pending so LSU completion can handshake
                // (mem_start needs exu_mem_valid & lsu_done). Gating with
                // ~load_pending dropped the request after the first cycle.
                mem_valid        = disp_out.data.mem_valid;
                // POP: mem data → dest on done; do not write new_esp to dest on issue
                if (uop_opcode == `UOP_POP) begin
                    write_gpr = 1'b0;
                end
            end else begin
            case (uop_opcode)
                `UOP_MOV: begin
                    if (mem_access) begin
                        mem_address = src1_data + displacement;
                        mem_valid   = ~load_pending_r & ~mem_op_complete_eff;
                        if (is_store) begin
                            mem_write_enable = 1'b1;
                            mem_write_data   = src2_data;
                        end else begin
                            mem_write_enable = 1'b0;
                        end
                    end
                end
                `UOP_MOVZX, `UOP_MOVSX: begin
                    if (mem_access) begin
                        mem_address      = src1_data + displacement;
                        mem_valid        = ~load_pending_r & ~mem_op_complete_eff;
                        mem_write_enable = 1'b0;
                    end
                end
                `UOP_BRANCH: begin
                    // FF /4 mem: load target dword then redirect (not disp-as-target).
                    if (mem_access) begin
                        mem_address      = agu_addr;
                        mem_valid        = ~load_pending_r & ~mem_op_complete_eff;
                        mem_write_enable = 1'b0;
                    end
                end
                `UOP_LOAD: begin
                    mem_address      = src1_data + displacement;
                    mem_valid        = ~load_pending_r & ~mem_op_complete_eff;
                    mem_write_enable = 1'b0;
                end
                `UOP_STORE: begin
                    mem_address      = src1_data + displacement;
                    mem_write_data   = src2_data;
                    mem_valid        = 1'b1;
                    mem_write_enable = 1'b1;
                end
                `UOP_MISC: begin
                    unique case (immediate[7: 0])
                        `MISC_SUB_INVD: begin
                            inv_cache = 1'b1;
                        end
                        `MISC_SUB_WBINVD: begin
                            wbinvd_cmd = 1'b1;
                        end
                        `MISC_SUB_LGDT: begin
                            if (~misc_load_pending_r & ~mem_op_complete_eff) begin
                                mem_address      = displacement;
                                mem_valid        = 1'b1;
                                mem_write_enable = 1'b0;
                            end
                        end
                        `MISC_SUB_LIDT: begin
                            if (~misc_load_pending_r & ~mem_op_complete_eff) begin
                                mem_address      = displacement;
                                mem_valid        = 1'b1;
                                mem_write_enable = 1'b0;
                            end
                        end
                        `MISC_SUB_SGDT: begin
                            mem_address      = agu_addr;
                            mem_valid        = 1'b1;
                            mem_write_enable = 1'b1;
                            mem_write_data   = {i_gdtr_base[15: 0], i_gdtr_limit};
                        end
                        `MISC_SUB_SIDT: begin
                            mem_address      = agu_addr;
                            mem_valid        = 1'b1;
                            mem_write_enable = 1'b1;
                            mem_write_data   = {i_idtr_base[15: 0], i_idtr_limit};
                        end
                        `MISC_SUB_LMSW: begin
                            cr_we    = 1'b1;
                            cr_index = 3'd0;
                            cr_data  = {16'h0, src2_data[15: 0]};
                        end
                        `MISC_SUB_CLTS: begin
                            cr_we    = 1'b1;
                            cr_index = 3'd0;
                            cr_data  = i_cr0_data & ~32'h0000_0008;
                        end
                        `MISC_SUB_SMSW: begin
                            tmp_result = {16'h0, i_cr0_data[15: 0]};
                            write_gpr  = 1'b1;
                        end
                        `MISC_SUB_LEAVE: begin
                            // ESP := EBP; POP EBP skeleton (mem load into EBP)
                            tmp_result       = i_gpr_ebp + 32'd4;
                            write_gpr        = 1'b1;
                            mem_address      = i_gpr_ebp;
                            mem_valid        = ~load_pending_r & ~mem_op_complete_eff;
                            mem_write_enable = 1'b0;
                        end
                        `MISC_SUB_MOV_CR: begin
                            cr_we    = 1'b1;
                            cr_index = dest_reg;
                            cr_data  = src2_data;
                        end
                        `MISC_SUB_MOV_FROM_CR: begin
                            // eee selects CRn; only CR0 is wired in this core path.
                            tmp_result = (i_uop.uop_eee[2: 0] == 3'd0) ? i_cr0_data : 32'd0;
                            write_gpr  = 1'b1;
                        end
                        `MISC_SUB_IN: begin
                            data_io_access   = 1'b1;
                            // [31]=DX port via src1; else imm8 port in [15:8]
                            mem_address      = immediate[31] ?
                                               {16'h0, src1_data[15: 0]} :
                                               {24'h0, immediate[15: 8]};
                            mem_valid        = ~load_pending_r & ~mem_op_complete_eff;
                            mem_write_enable = 1'b0;
                        end
                        `MISC_SUB_OUT: begin
                            data_io_access   = 1'b1;
                            mem_address      = immediate[31] ?
                                               {16'h0, src1_data[15: 0]} :
                                               {24'h0, immediate[15: 8]};
                            mem_valid        = ~load_pending_r & ~mem_op_complete_eff;
                            mem_write_enable = 1'b1;
                            mem_write_data   = src2_data;
                        end
                        `MISC_SUB_INT: begin
                            software_int_valid  = 1'b1;
                            software_int_vector = immediate[15: 8];
                        end
                        `MISC_SUB_IRET: begin
                            iret_valid = 1'b1;
                        end
                        `MISC_SUB_MOV_SEG: begin
                            seg_load_target_index = immediate[10: 8];
                            if (mem_access) begin
                                if (~misc_load_pending_r) begin
                                    mem_address      = src1_data + displacement;
                                    mem_valid        = 1'b1;
                                    mem_write_enable = 1'b0;
                                end
                            end else begin
                                seg_load_valid    = 1'b1;
                                seg_load_op_type  = 2'b00;
                                seg_load_selector = src2_data[15: 0];
                                mov_seg_real_enable = 1'b1;
                                mov_seg_real_index  = immediate[10: 8];
                                mov_seg_real_selector = src2_data[15: 0];
                            end
                        end
                        `MISC_SUB_FAR_JMP: begin
                            seg_load_op_type = 2'b01;
                            if (mem_access) begin
                                if (~misc_load_pending_r) begin
                                    mem_address      = src1_data + displacement;
                                    mem_valid        = 1'b1;
                                    mem_write_enable = 1'b0;
                                end
                            end else begin
                                seg_load_valid        = 1'b1;
                                seg_load_far_offset   = displacement;
                                seg_load_far_selector = immediate[23: 8];
                                // Real-mode far JMP writes CS:EIP here. After PE=1 the
                                // segment_load_unit owns CS+EIP (descriptor load).
                                if (~i_cr0_data[0]) begin
                                    mov_seg_real_enable   = 1'b1;
                                    mov_seg_real_index    = `sreg_index_CS;
                                    mov_seg_real_selector = immediate[23: 8];
                                    write_ip              = 1'b1;
                                    ip_data               = displacement;
                                end
                            end
                        end
                        `MISC_SUB_FAR_CALL: begin
                            seg_load_op_type = 2'b10;
                            if (mem_access) begin
                                if (~misc_load_pending_r) begin
                                    mem_address      = src1_data + displacement;
                                    mem_valid        = 1'b1;
                                    mem_write_enable = 1'b0;
                                end
                            end else if (~far_call_pending_r) begin
                                mem_address      = i_gpr_esp - 32'd4;
                                mem_write_data   = {16'h0, i_cs_selector};
                                mem_valid        = 1'b1;
                                mem_write_enable = 1'b1;
                            end
                        end
                        `MISC_SUB_FAR_RET: begin
                            seg_load_valid      = 1'b1;
                            seg_load_op_type    = 2'b11;
                            seg_load_far_offset = i_gpr_esp + (has_disp ? displacement : 32'd0);
                            seg_load_far_selector = 16'h0;
                            far_ret_new_esp     = i_gpr_esp + (has_disp ? displacement : 32'd0) + 32'd8;
                            far_ret_new_esp_valid = 1'b1;
                        end
                        `MISC_SUB_UD: begin
                            exc_ud_valid = 1'b1;
                        end
                        default: ;
                    endcase
                end
                `UOP_X87: begin
                    tmp_result = 32'd0;
                end
                `UOP_MMX: begin
                    tmp_result = src1_data + src2_data;
                    write_gpr = 1'b1;
                end
                `UOP_SSE: begin
                    tmp_result = src1_data + src2_data;
                    write_gpr = 1'b1;
                end
                `UOP_EMMS: begin
                    tmp_result = 32'd0;
                end
                `UOP_NOP: begin
                    tmp_result = 32'd0;
                end
                default: begin
                    tmp_result = 32'd0;
                end
            endcase
            end

            if (disp_handled &&
                ((uop_opcode == `UOP_DIV) | (uop_opcode == `UOP_IDIV)) &&
                (src1_data == 32'd0)) begin
                exc_de_valid = 1'b1;
            end

            flags_data = pack_eflags_status(eflags_base, new_cf, new_pf, new_af, new_zf, new_sf, new_of);
        end

        if (load_pending_r & i_mem_done) begin
            if (uop_opcode == `UOP_BRANCH) begin
                write_ip = 1'b1;
                ip_data  = i_mem_rdata;
            end else if (uop_opcode == `UOP_CMP) begin
                new_cf      = compute_cf_sub(i_mem_rdata, has_imm ? immediate : src2_data);
                new_pf      = compute_pf(i_mem_rdata - (has_imm ? immediate : src2_data));
                new_af      = compute_af(i_mem_rdata, has_imm ? immediate : src2_data, 1'b1);
                new_zf      = compute_zf(i_mem_rdata - (has_imm ? immediate : src2_data));
                new_sf      = compute_sf(i_mem_rdata - (has_imm ? immediate : src2_data));
                new_of      = compute_of_sub(i_mem_rdata, has_imm ? immediate : src2_data);
                write_flags = 1'b1;
                write_gpr   = 1'b0;
                flags_data  = pack_eflags_status(eflags_base, new_cf, new_pf, new_af, new_zf, new_sf, new_of);
            end else if (~((uop_opcode == `UOP_PUSH) | (uop_opcode == `UOP_CALL) |
                  (uop_opcode == `UOP_RET) |
                  (uop_opcode == `UOP_STORE) |
                  (uop_opcode == `UOP_BRANCH) |
                  ((uop_opcode == `UOP_MOV) & is_store) |
                  ((uop_opcode == `UOP_MISC) &
                   ((misc_subcode_r == `MISC_SUB_MOV_SEG) |
                    (misc_subcode_r == `MISC_SUB_FAR_JMP) |
                    (misc_subcode_r == `MISC_SUB_FAR_CALL) |
                    (misc_subcode_r == `MISC_SUB_LGDT) |
                    (misc_subcode_r == `MISC_SUB_LIDT) |
                    (misc_subcode_r == `MISC_SUB_OUT))))) begin
                // Cache/BIU return an aligned dword; select lane from EA[1:0].
                // MOVSX/MOVZX mem forms are byte (0F BE/B6) unless imm[0]=1 (word).
                begin
                    logic [31: 0] lane_data;
                    unique case (mem_hold_addr_r[1: 0])
                        2'b00: lane_data = i_mem_rdata;
                        2'b01: lane_data = { 8'h0, i_mem_rdata[31: 8]};
                        2'b10: lane_data = {16'h0, i_mem_rdata[31:16]};
                        2'b11: lane_data = {24'h0, i_mem_rdata[31:24]};
                    endcase
                    if (uop_opcode == `UOP_MOVZX) begin
                        if (immediate[0])
                            tmp_result = {16'h0, lane_data[15: 0]};
                        else
                            tmp_result = {24'h0, lane_data[7: 0]};
                    end else if (uop_opcode == `UOP_MOVSX) begin
                        if (immediate[0])
                            tmp_result = {{16{lane_data[15]}}, lane_data[15: 0]};
                        else
                            tmp_result = {{24{lane_data[7]}}, lane_data[7: 0]};
                    end else begin
                        tmp_result = i_mem_rdata;
                    end
                end
                write_gpr  = 1'b1;
            end
            // CALL: commit ESP and redirect only after return address is stored.
            if (uop_opcode == `UOP_CALL) begin
                tmp_result = src2_data - 32'd4;
                write_gpr  = 1'b1;
                write_ip   = 1'b1;
                ip_data    = has_disp ? displacement : immediate;
            end
            if (ret_pending_r) begin
                ip_data  = i_mem_rdata;
                write_ip = 1'b1;
            end
            if ((uop_opcode == `UOP_MISC) && (misc_subcode_r == `MISC_SUB_MOV_SEG)) begin
                seg_load_valid        = 1'b1;
                seg_load_op_type      = 2'b00;
                seg_load_target_index = immediate[10: 8];
                seg_load_selector     = i_mem_rdata[15: 0];
                mov_seg_real_enable   = 1'b1;
                mov_seg_real_index    = immediate[10: 8];
                mov_seg_real_selector = i_mem_rdata[15: 0];
            end else if ((uop_opcode == `UOP_MISC) &&
                         ((misc_subcode_r == `MISC_SUB_FAR_JMP) ||
                          (misc_subcode_r == `MISC_SUB_FAR_CALL))) begin
                if (far_ind_step_r == 2'd0) begin
                    mem_address      = far_ind_addr_r + 32'd4;
                    mem_valid        = 1'b1;
                    mem_write_enable = 1'b0;
                end else if (misc_subcode_r == `MISC_SUB_FAR_JMP) begin
                    seg_load_valid        = 1'b1;
                    seg_load_op_type      = 2'b01;
                    seg_load_far_offset   = far_ind_offset_r;
                    seg_load_far_selector = i_mem_rdata[15: 0];
                    if (~i_cr0_data[0]) begin
                        mov_seg_real_enable   = 1'b1;
                        mov_seg_real_index    = `sreg_index_CS;
                        mov_seg_real_selector = i_mem_rdata[15: 0];
                        write_ip              = 1'b1;
                        ip_data               = far_ind_offset_r;
                    end
                end else if (~far_call_pending_r) begin
                    mem_address      = i_gpr_esp - 32'd4;
                    mem_write_data   = {16'h0, i_cs_selector};
                    mem_valid        = 1'b1;
                    mem_write_enable = 1'b1;
                end
            end
        end else if (mem_op_complete_eff & (uop_opcode == `UOP_POP)) begin
            // Sticky POP retirement: dest write used latched mem rdata path via
            // load_pending&done; ESP adjust is enabled separately below.
            write_gpr = 1'b0;
        end else if (load_pending_r & (uop_opcode == `UOP_CMP)) begin
            // Hold mem request until MMU+memory complete (one-cycle pulse is not enough).
            // Drop valid on the done beat so the cache cannot re-issue from IDLE.
            mem_address      = agu_addr;
            mem_valid        = ~i_mem_done;
            mem_write_enable = 1'b0;
        end else if (load_pending_r &
                     (((uop_opcode == `UOP_MOV) & ~is_store) |
                      (uop_opcode == `UOP_MOVZX) |
                      (uop_opcode == `UOP_MOVSX) |
                      (uop_opcode == `UOP_BRANCH))) begin
            mem_address      = (uop_opcode == `UOP_BRANCH) ? mem_hold_addr_r :
                               (src1_data + displacement);
            mem_valid        = ~i_mem_done;
            mem_write_enable = 1'b0;
        end else if (load_pending_r & (uop_opcode == `UOP_MOV) & is_store) begin
            mem_address      = src1_data + displacement;
            mem_valid        = ~i_mem_done;
            mem_write_enable = 1'b1;
            mem_write_data   = src2_data;
        end else if (load_pending_r & (uop_opcode == `UOP_MISC) &
                     ((misc_subcode_r == `MISC_SUB_LGDT) |
                      (misc_subcode_r == `MISC_SUB_LIDT))) begin
            // step0: original addr; step1+: addr+4 for base[31:16]
            mem_address      = (far_ind_step_r == 2'd0) ?
                               displacement :
                               (far_ind_addr_r + 32'd4);
            mem_valid        = ~i_mem_done;
            mem_write_enable = 1'b0;
        end else if (load_pending_r & (uop_opcode == `UOP_MISC) &
                     ((misc_subcode_r == `MISC_SUB_IN) |
                      (misc_subcode_r == `MISC_SUB_OUT))) begin
            // Hold IN/OUT until BIU completes — same one-cycle-pulse issue as CMP.
            // Deassert on done so IO is not written twice (UART THR duplicates).
            data_io_access   = 1'b1;
            mem_address      = immediate[31] ?
                               {16'h0, src1_data[15: 0]} :
                               {24'h0, immediate[15: 8]};
            mem_valid        = ~i_mem_done;
            mem_write_enable = (misc_subcode_r == `MISC_SUB_OUT);
            mem_write_data   = src2_data;
        end

        // LGDT/LIDT GDTR/IDTR write: one cycle after a fresh beat2 latch.
        if (far_ind_gdtr_commit_r) begin
            if (misc_subcode_r == `MISC_SUB_LGDT) begin
                gdtr_we    = 1'b1;
                gdtr_limit = far_ind_offset_r[15: 0];
                gdtr_base  = {far_ind_hi_r[15: 0], far_ind_offset_r[31:16]};
            end else if (misc_subcode_r == `MISC_SUB_LIDT) begin
                idtr_we    = 1'b1;
                idtr_limit = far_ind_offset_r[15: 0];
                idtr_base  = {far_ind_hi_r[15: 0], far_ind_offset_r[31:16]};
            end
        end

        if (far_call_pending_r & i_mem_done) begin
            if (far_call_step_r == 2'd0) begin
                mem_address      = far_call_esp_base_r - 32'd8;
                mem_write_data   = i_eip;
                mem_valid        = 1'b1;
                mem_write_enable = 1'b1;
            end else begin
                seg_load_valid        = 1'b1;
                seg_load_op_type      = 2'b10;
                seg_load_far_offset   = far_call_far_offset_r;
                seg_load_far_selector = far_call_far_selector_r;
                tmp_result            = far_call_esp_base_r - 32'd8;
                write_gpr             = 1'b1;
            end
        end
    end

    i486_cpuid u_cpuid (
        .i_eax_in (src1_data),
        .i_ecx_in (src2_data),
        .o_eax    (cpuid_eax),
        .o_ebx    (cpuid_ebx),
        .o_ecx    (cpuid_ecx),
        .o_edx    (cpuid_edx)
    );

    always_ff @(posedge clk or negedge rst_n) begin : ff_load_pending
        if (~rst_n) begin
            load_pending_r       <= 1'b0;
            seg_load_pending_r   <= 1'b0;
            seg_load_complete_r  <= 1'b0;
            load_dest_r          <= 3'b0;
            mem_op_complete_r    <= 1'b0;
            mem_op_gen_r         <= 8'h0;
            mem_op_complete_gen_r <= 8'h0;
            alu_wb_done_r          <= 1'b0;
            ret_redirect_r         <= 1'b0;
            ret_redirect_bubble_r  <= 1'b0;
            uop_fp_r               <= 64'h0;
            misc_load_pending_r  <= 1'b0;
            misc_subcode_r       <= 8'h0;
            ret_pending_r        <= 1'b0;
            far_ind_step_r       <= 2'd0;
            far_ind_offset_r     <= 32'd0;
            far_ind_addr_r       <= 32'd0;
            far_ind_beat2_issued_r <= 1'b0;
            far_ind_hi_r         <= 32'd0;
            far_ind_gdtr_commit_r <= 1'b0;
            far_call_pending_r   <= 1'b0;
            far_call_step_r      <= 2'd0;
            far_call_esp_base_r  <= 32'd0;
            far_call_far_offset_r <= 32'h0;
            far_call_far_selector_r <= 16'h0;
            mem_hold_valid_r     <= 1'b0;
            mem_hold_we_r        <= 1'b0;
            mem_hold_io_r        <= 1'b0;
            mem_hold_addr_r      <= 32'h0;
            mem_hold_wdata_r     <= 32'h0;
        end else begin
            // Keep mem_op_complete sticky across brief ~valid bubbles (IFU reload
            // after CALL write_ip). Clearing it here allowed the same CALL uop to
            // re-arm and push a second return address over the stack argument.
            // Near RET: after a redirect bubble, drop sticky complete so a second
            // consecutive RET (identical uop fingerprint) still pops the stack.
            if (load_pending_r & i_mem_done & ret_pending_r) begin
                ret_redirect_r        <= 1'b1;
                ret_redirect_bubble_r <= 1'b0;
            end else if (~i_uop_valid & ret_redirect_r) begin
                ret_redirect_bubble_r <= 1'b1;
                seg_load_complete_r   <= 1'b0;
            end else if (i_uop_valid & ret_redirect_r & ret_redirect_bubble_r) begin
                mem_op_complete_r     <= 1'b0;
                alu_wb_done_r         <= 1'b0;
                mem_op_gen_r          <= mem_op_gen_r + 8'd1;
                uop_fp_r              <= uop_fp;
                ret_redirect_r        <= 1'b0;
                ret_redirect_bubble_r <= 1'b0;
            end else if (~i_uop_valid) begin
                seg_load_complete_r  <= 1'b0;
            end else if (uop_changed) begin
                mem_op_complete_r    <= 1'b0;
                alu_wb_done_r        <= 1'b0;
                mem_op_gen_r         <= mem_op_gen_eff;
                uop_fp_r             <= uop_fp;
            end
            // One-shot writeback only for pure ALU (NOT/TEST/ADD/…). Mem ops and
            // CALL/PUSH keep multi-cycle write_gpr behaviour unchanged.
            if (i_uop_valid & write_gpr & ~load_pending_r & ~far_call_pending_r &
                ~mem_op_complete_eff & exu_opcode_is_alu(uop_opcode) &
                (uop_opcode != `UOP_CMP) & (uop_changed | ~alu_wb_done_r)) begin
                alu_wb_done_r <= 1'b1;
            end
            // One-cycle GDTR/IDTR commit strobe from latched beat2 dword.
            if (far_ind_gdtr_commit_r) begin
                far_ind_gdtr_commit_r <= 1'b0;
            end
            // Protected-mode segment loads: wait for SLU before retiring (avoids re-issue).
            if (i_uop_valid & i_wrb_ready & i_cr0_data[0] & ~load_pending_r &
                ~far_call_pending_r & ~seg_load_pending_r & ~seg_load_complete_r &
                seg_load_valid) begin
                seg_load_pending_r <= 1'b1;
            end else if (seg_load_pending_r & i_slu_ready) begin
                seg_load_pending_r  <= 1'b0;
                seg_load_complete_r <= 1'b1;
            end
            if (i_uop_valid & i_wrb_ready & ~load_pending_r & ~far_call_pending_r &
                ~seg_load_pending_r & ~mem_op_complete_r & mem_valid) begin
                load_pending_r <= 1'b1;
                load_dest_r    <= dest_reg;
                mem_hold_valid_r <= 1'b1;
                mem_hold_we_r    <= mem_write_enable;
                mem_hold_io_r    <= data_io_access;
                mem_hold_addr_r  <= mem_address;
                mem_hold_wdata_r <= mem_write_data;
                if (uop_opcode == `UOP_RET) begin
                    ret_pending_r <= 1'b1;
                end
                if (uop_opcode == `UOP_MISC) begin
                    misc_load_pending_r <= 1'b1;
                    misc_subcode_r      <= immediate[7: 0];
                    if (immediate[7: 0] == `MISC_SUB_LEAVE) begin
                        load_dest_r <= 3'd5; // POP into EBP
                    end
                    if ((immediate[7: 0] == `MISC_SUB_FAR_JMP) ||
                        (immediate[7: 0] == `MISC_SUB_FAR_CALL) ||
                        (immediate[7: 0] == `MISC_SUB_LGDT) ||
                        (immediate[7: 0] == `MISC_SUB_LIDT)) begin
                        far_ind_step_r         <= 2'd0;
                        far_ind_addr_r         <= mem_address;
                        far_ind_beat2_issued_r <= 1'b0;
                        far_ind_gdtr_commit_r  <= 1'b0;
                    end
                end else begin
                    // Non-MISC mem ops must not inherit a prior LGDT/LIDT/FAR_*
                    // misc_subcode: PUSH after LGDT would otherwise treat mem_done
                    // as LGDT beat0 and redirect the hold address to addr+4.
                    misc_load_pending_r    <= 1'b0;
                    misc_subcode_r         <= 8'h0;
                    far_ind_step_r         <= 2'd0;
                    far_ind_beat2_issued_r <= 1'b0;
                end
            end else if (i_uop_valid & i_wrb_ready & ~load_pending_r & ~far_call_pending_r &
                         (uop_opcode == `UOP_MISC) &&
                         (immediate[7: 0] == `MISC_SUB_FAR_CALL) && ~mem_access) begin
                far_call_pending_r    <= 1'b1;
                far_call_step_r       <= 2'd0;
                far_call_esp_base_r   <= i_gpr_esp;
                far_call_far_offset_r <= displacement;
                far_call_far_selector_r <= immediate[23: 8];
            end else if (load_pending_r & i_mem_done) begin
                load_pending_r      <= 1'b0;
                mem_hold_valid_r    <= 1'b0;
                if ((uop_opcode == `UOP_CMP) ||
                    ((uop_opcode == `UOP_MISC) &&
                     ((misc_subcode_r == `MISC_SUB_IN) ||
                      (misc_subcode_r == `MISC_SUB_OUT)))) begin
                    // Sticky complete prevents IN/OUT from re-asserting mem_valid
                    // (decode path uses ~load_pending) and double-issuing IO.
                    mem_op_complete_r     <= 1'b1;
                    mem_op_complete_gen_r <= mem_op_gen_eff;
                end
                // Multi-beat continuation only applies to the active UOP_MISC that
                // started the pending sequence — never to PUSH/POP/etc.
                if ((uop_opcode == `UOP_MISC) &&
                    ((misc_subcode_r == `MISC_SUB_FAR_JMP) ||
                     (misc_subcode_r == `MISC_SUB_FAR_CALL) ||
                     (misc_subcode_r == `MISC_SUB_LGDT) ||
                     (misc_subcode_r == `MISC_SUB_LIDT))) begin
                    if (far_ind_step_r == 2'd0) begin
                        far_ind_offset_r    <= i_mem_rdata;
                        load_pending_r      <= 1'b1;
                        misc_load_pending_r <= 1'b1;
                        // Immediately issue beat2 at addr+4 (no gap). Beat0's done
                        // pulse ends this cycle, so the next done is beat2's.
                        far_ind_step_r         <= 2'd1;
                        mem_hold_addr_r        <= far_ind_addr_r + 32'd4;
                        mem_hold_valid_r       <= 1'b1;
                        mem_hold_we_r          <= 1'b0;
                        mem_hold_io_r          <= 1'b0;
                        far_ind_beat2_issued_r <= ((misc_subcode_r == `MISC_SUB_LGDT) |
                                                   (misc_subcode_r == `MISC_SUB_LIDT));
                    end else if (misc_subcode_r == `MISC_SUB_FAR_CALL) begin
                        misc_load_pending_r   <= 1'b0;
                        far_ind_step_r        <= 2'd0;
                        far_ind_beat2_issued_r <= 1'b0;
                        far_call_pending_r    <= 1'b1;
                        far_call_step_r       <= 2'd0;
                        far_call_esp_base_r   <= i_gpr_esp;
                        far_call_far_offset_r <= far_ind_offset_r;
                        far_call_far_selector_r <= i_mem_rdata[15: 0];
                    end else if ((misc_subcode_r == `MISC_SUB_LGDT) ||
                                 (misc_subcode_r == `MISC_SUB_LIDT)) begin
                        if (far_ind_beat2_ok & far_ind_beat2_rdata_fresh) begin
                            far_ind_hi_r           <= i_mem_rdata;
                            far_ind_gdtr_commit_r  <= 1'b1;
                            misc_load_pending_r    <= 1'b0;
                            far_ind_step_r         <= 2'd0;
                            far_ind_beat2_issued_r <= 1'b0;
                            mem_op_complete_r      <= 1'b1;
                            mem_op_complete_gen_r  <= mem_op_gen_eff;
                        end else begin
                            // Stale/spurious done (rdata still beat0): re-issue addr+4
                            load_pending_r         <= 1'b1;
                            misc_load_pending_r    <= 1'b1;
                            mem_hold_addr_r        <= far_ind_addr_r + 32'd4;
                            mem_hold_valid_r       <= 1'b1;
                            mem_hold_we_r          <= 1'b0;
                            far_ind_step_r         <= 2'd1;
                            far_ind_beat2_issued_r <= 1'b1;
                        end
                    end else begin
                        misc_load_pending_r    <= 1'b0;
                        far_ind_step_r         <= 2'd0;
                        far_ind_beat2_issued_r <= 1'b0;
                        mem_op_complete_r      <= 1'b1;
                        mem_op_complete_gen_r  <= mem_op_gen_eff;
                    end
                end else begin
                    // PUSH/POP/LOAD/STORE/etc: sticky complete so mem_valid stays
                    // low after done (access_memory would otherwise re-start while
                    // load_pending still holds the request high for one cycle).
                    misc_load_pending_r   <= 1'b0;
                    mem_op_complete_r     <= 1'b1;
                    // Tag with stable gen_r (not gen_eff): on the done beat the next
                    // uop may already be combinationally visible and bump gen_eff.
                    mem_op_complete_gen_r <= mem_op_gen_eff;
                end
                ret_pending_r <= 1'b0;
            end else if (far_call_pending_r & i_mem_done) begin
                if (far_call_step_r == 2'd0) begin
                    far_call_step_r <= 2'd1;
                end else begin
                    far_call_pending_r <= 1'b0;
                    far_call_step_r    <= 2'd0;
                end
            end
        end
    end

    // All memory ops (loads, stores, IO) wait for mem_done. Stores previously
    // retired while LSU was still translating; after retire exu_mem_* dropped
    // and the store never committed (and LSU saw wrong seg/addr).
    logic mem_needs_wait;
    logic multi_beat_mid;
    assign mem_needs_wait = mem_valid;
    // Keep multi-beat uops in EXU until the final data beat retires.
    // LGDT/LIDT: retire on beat2 done (far_ind_beat2_ok).
    // Far-ind JMP/CALL: retire only after selector beat (step!=0 + done).
    assign multi_beat_mid =
        load_pending_r & (uop_opcode == `UOP_MISC) &
        (((misc_subcode_r == `MISC_SUB_LGDT) | (misc_subcode_r == `MISC_SUB_LIDT)) ?
         ~(far_ind_beat2_ok & far_ind_beat2_rdata_fresh & i_mem_done) :
         (((misc_subcode_r == `MISC_SUB_FAR_JMP) | (misc_subcode_r == `MISC_SUB_FAR_CALL)) &
          (far_ind_step_r == 2'd0)));

    // Allow ready on the mem_done beat even while load_pending is still set,
    // otherwise IN/OUT never handshake and re-issue forever after each done pulse.
    // Block ready on multi-beat mid so the uop (and CS override) stays in EXU.
    assign o_stage_ready       = i_wrb_ready & ~far_call_pending_r & ~multi_beat_mid &
                                 (~seg_load_pending_r | i_slu_ready) &
                                 (~load_pending_r | i_mem_done) &
                                 ~(mem_needs_wait & ~load_pending_r);
    assign o_multicycle_stall  = (load_pending_r & ~i_mem_done) | far_call_pending_r |
                                 multi_beat_mid |
                                 (seg_load_pending_r & ~i_slu_ready) |
                                 (mem_needs_wait & ~load_pending_r);
    assign o_stage_valid       = (i_uop_valid & mem_op_complete_eff) |
                                 ((load_pending_r | far_call_pending_r) & i_mem_done &
                                  ~multi_beat_mid) |
                                 (seg_load_pending_r & i_slu_ready) |
                                 (i_uop_valid & seg_load_complete_r) |
                                 (i_uop_valid & ~load_pending_r & ~far_call_pending_r &
                                  ~seg_load_pending_r & ~seg_load_complete_r & ~mem_needs_wait &
                                  ~(i_cr0_data[0] & seg_load_valid));

    always_comb begin
        logic [2:0] active_dest;
        active_dest = (far_call_pending_r & i_mem_done) ? 3'd4 :
                      (load_pending_r & i_mem_done) ? load_dest_r : dest_reg;

        o_wrb_gpr_enable_EAX = 1'b0;
        o_wrb_gpr_enable_AX  = 1'b0;
        o_wrb_gpr_enable_AL  = 1'b0;
        o_wrb_gpr_enable_AH  = 1'b0;
        o_wrb_gpr_enable_EBX = 1'b0;
        o_wrb_gpr_enable_BX  = 1'b0;
        o_wrb_gpr_enable_BL  = 1'b0;
        o_wrb_gpr_enable_BH  = 1'b0;
        o_wrb_gpr_enable_ECX = 1'b0;
        o_wrb_gpr_enable_CX  = 1'b0;
        o_wrb_gpr_enable_CL  = 1'b0;
        o_wrb_gpr_enable_CH  = 1'b0;
        o_wrb_gpr_enable_EDX = 1'b0;
        o_wrb_gpr_enable_DX  = 1'b0;
        o_wrb_gpr_enable_DL  = 1'b0;
        o_wrb_gpr_enable_DH  = 1'b0;
        o_wrb_gpr_enable_ESP = 1'b0;
        o_wrb_gpr_enable_SP  = 1'b0;
        o_wrb_gpr_enable_EBP = 1'b0;
        o_wrb_gpr_enable_BP  = 1'b0;
        o_wrb_gpr_enable_ESI = 1'b0;
        o_wrb_gpr_enable_SI  = 1'b0;
        o_wrb_gpr_enable_EDI = 1'b0;
        o_wrb_gpr_enable_DI  = 1'b0;

        // Do not arm RF writes on sticky mem_op_complete alone — that re-applied
        // the prior IN's AL=LSR value after NOT had already written ~LSR, so
        // TEST/JZ never saw the inverted result (SeaBIOS serial wait spin).
        // alu_wb_done_r: one write per ALU uop while it remains in EXU.
        if (((i_uop_valid & ~load_pending_r & ~far_call_pending_r & ~mem_op_complete_eff &
              (~exu_opcode_is_alu(uop_opcode) | (uop_opcode == `UOP_CMP) |
               uop_changed | ~alu_wb_done_r)) |
             (load_pending_r & i_mem_done) |
             (far_call_pending_r & i_mem_done & (far_call_step_r == 2'd1))) && write_gpr) begin
            case (active_dest)
                3'd0: begin
                    o_wrb_gpr_enable_EAX = 1'b1;
                    o_wrb_gpr_enable_AX  = 1'b1;
                    o_wrb_gpr_enable_AL  = 1'b1;
                    o_wrb_gpr_enable_AH  = 1'b1;
                end
                3'd1: begin
                    o_wrb_gpr_enable_ECX = 1'b1;
                    o_wrb_gpr_enable_CX  = 1'b1;
                    o_wrb_gpr_enable_CL  = 1'b1;
                    o_wrb_gpr_enable_CH  = 1'b1;
                end
                3'd2: begin
                    o_wrb_gpr_enable_EDX = 1'b1;
                    o_wrb_gpr_enable_DX  = 1'b1;
                    o_wrb_gpr_enable_DL  = 1'b1;
                    o_wrb_gpr_enable_DH  = 1'b1;
                end
                3'd3: begin
                    o_wrb_gpr_enable_EBX = 1'b1;
                    o_wrb_gpr_enable_BX  = 1'b1;
                    o_wrb_gpr_enable_BL  = 1'b1;
                    o_wrb_gpr_enable_BH  = 1'b1;
                end
                3'd4: begin
                    o_wrb_gpr_enable_ESP = 1'b1;
                    o_wrb_gpr_enable_SP  = 1'b1;
                end
                3'd5: begin
                    o_wrb_gpr_enable_EBP = 1'b1;
                    o_wrb_gpr_enable_BP  = 1'b1;
                end
                3'd6: begin
                    o_wrb_gpr_enable_ESI = 1'b1;
                    o_wrb_gpr_enable_SI  = 1'b1;
                end
                3'd7: begin
                    o_wrb_gpr_enable_EDI = 1'b1;
                    o_wrb_gpr_enable_DI  = 1'b1;
                end
            endcase
        end
        // LEAVE: also write ESP := EBP+4 on issue cycle
        if (i_uop_valid & ~load_pending_r & ~far_call_pending_r &
            (uop_opcode == `UOP_MISC) & (immediate[7: 0] == `MISC_SUB_LEAVE)) begin
            o_wrb_gpr_enable_ESP = 1'b1;
            o_wrb_gpr_enable_SP  = 1'b1;
        end
        // POP: update ESP := ESP+4 only on the mem_done cycle (not while
        // mem_op_complete is sticky — RF may already hold ESP+4 and src1 may
        // have been refreshed, which would add 4 again).
        if (load_pending_r & i_mem_done & (uop_opcode == `UOP_POP)) begin
            o_wrb_gpr_enable_ESP = 1'b1;
            o_wrb_gpr_enable_SP  = 1'b1;
        end
        // CPUID: write EAX/EBX/ECX/EDX together
        if (i_uop_valid & ~load_pending_r & ~far_call_pending_r &
            (uop_opcode == `UOP_MISC) & (immediate[7: 0] == `MISC_SUB_CPUID)) begin
            o_wrb_gpr_enable_EAX = 1'b1;
            o_wrb_gpr_enable_AX  = 1'b1;
            o_wrb_gpr_enable_AL  = 1'b1;
            o_wrb_gpr_enable_AH  = 1'b1;
            o_wrb_gpr_enable_EBX = 1'b1;
            o_wrb_gpr_enable_BX  = 1'b1;
            o_wrb_gpr_enable_BL  = 1'b1;
            o_wrb_gpr_enable_BH  = 1'b1;
            o_wrb_gpr_enable_ECX = 1'b1;
            o_wrb_gpr_enable_CX  = 1'b1;
            o_wrb_gpr_enable_CL  = 1'b1;
            o_wrb_gpr_enable_CH  = 1'b1;
            o_wrb_gpr_enable_EDX = 1'b1;
            o_wrb_gpr_enable_DX  = 1'b1;
            o_wrb_gpr_enable_DL  = 1'b1;
            o_wrb_gpr_enable_DH  = 1'b1;
        end
        // CDQ/CWD: write EDX with sign-extended high half (tmp_result)
        if (i_uop_valid & ~load_pending_r & ~far_call_pending_r &
            (uop_opcode == `UOP_MISC) & (immediate[7: 0] == `MISC_SUB_CDQ)) begin
            o_wrb_gpr_enable_EDX = 1'b1;
            o_wrb_gpr_enable_DX  = 1'b1;
            o_wrb_gpr_enable_DL  = 1'b1;
            o_wrb_gpr_enable_DH  = 1'b1;
        end
    end

    logic         cpuid_wb;
    assign cpuid_wb = i_uop_valid & ~load_pending_r & ~far_call_pending_r &
                      (uop_opcode == `UOP_MISC) & (immediate[7: 0] == `MISC_SUB_CPUID);

    assign o_wrb_gpr_data_EAX = cpuid_wb ? cpuid_eax : tmp_result;
    assign o_wrb_gpr_data_AX  = cpuid_wb ? cpuid_eax[15: 0] : tmp_result[15: 0];
    assign o_wrb_gpr_data_AL  = cpuid_wb ? cpuid_eax[ 7: 0] : tmp_result[ 7: 0];
    assign o_wrb_gpr_data_AH  = cpuid_wb ? cpuid_eax[15: 8] : tmp_result[15: 8];
    assign o_wrb_gpr_data_EBX = cpuid_wb ? cpuid_ebx : tmp_result;
    assign o_wrb_gpr_data_BX  = cpuid_wb ? cpuid_ebx[15: 0] : tmp_result[15: 0];
    assign o_wrb_gpr_data_BL  = cpuid_wb ? cpuid_ebx[ 7: 0] : tmp_result[ 7: 0];
    assign o_wrb_gpr_data_BH  = cpuid_wb ? cpuid_ebx[15: 8] : tmp_result[15: 8];
    assign o_wrb_gpr_data_ECX = cpuid_wb ? cpuid_ecx : tmp_result;
    assign o_wrb_gpr_data_CX  = cpuid_wb ? cpuid_ecx[15: 0] : tmp_result[15: 0];
    assign o_wrb_gpr_data_CL  = cpuid_wb ? cpuid_ecx[ 7: 0] : tmp_result[ 7: 0];
    assign o_wrb_gpr_data_CH  = cpuid_wb ? cpuid_ecx[15: 8] : tmp_result[15: 8];
    assign o_wrb_gpr_data_EDX = cpuid_wb ? cpuid_edx : tmp_result;
    assign o_wrb_gpr_data_DX  = cpuid_wb ? cpuid_edx[15: 0] : tmp_result[15: 0];
    assign o_wrb_gpr_data_DL  = cpuid_wb ? cpuid_edx[ 7: 0] : tmp_result[ 7: 0];
    assign o_wrb_gpr_data_DH  = cpuid_wb ? cpuid_edx[15: 8] : tmp_result[15: 8];
    assign o_wrb_gpr_data_ESP = (load_pending_r & i_mem_done & (uop_opcode == `UOP_POP)) ?
                                (src1_data + 32'd4) : tmp_result;
    assign o_wrb_gpr_data_SP  = o_wrb_gpr_data_ESP[15: 0];
    assign o_wrb_gpr_data_EBP = tmp_result;
    assign o_wrb_gpr_data_BP  = tmp_result[15: 0];
    assign o_wrb_gpr_data_ESI = tmp_result;
    assign o_wrb_gpr_data_SI  = tmp_result[15: 0];
    assign o_wrb_gpr_data_EDI = tmp_result;
    assign o_wrb_gpr_data_DI  = tmp_result[15: 0];

    assign o_wrb_seg_enable_es = mov_seg_real_enable & (mov_seg_real_index == `sreg_index_ES);
    assign o_wrb_seg_enable_cs = mov_seg_real_enable & (mov_seg_real_index == `sreg_index_CS);
    assign o_wrb_seg_enable_ss = mov_seg_real_enable & (mov_seg_real_index == `sreg_index_SS);
    assign o_wrb_seg_enable_ds = mov_seg_real_enable & (mov_seg_real_index == `sreg_index_DS);
    assign o_wrb_seg_enable_fs = mov_seg_real_enable & (mov_seg_real_index == `sreg_index_FS);
    assign o_wrb_seg_enable_gs = mov_seg_real_enable & (mov_seg_real_index == `sreg_index_GS);
    assign o_wrb_seg_selector   = mov_seg_real_selector;
    // Real-mode MOV/JMP to Sreg must fill hidden cache (base=sel<<4, limit=FFFF).
    // SLU is PE-only; writing descriptor 0 causes #GP on fetch after PE=1.
    assign o_wrb_seg_descriptor = {
        {mov_seg_real_selector[11: 0], 4'h0},
        16'hFFFF,
        8'h00,
        8'h00,
        (mov_seg_real_index == `sreg_index_CS) ? 8'h9B : 8'h93,
        {4'h0, mov_seg_real_selector[15: 12]}
    };

    // Start SLU once; hold off while pending/complete so ready→idle does not re-pulse.
    assign o_seg_load_valid       = seg_load_valid & ~seg_load_complete_r &
                                    ((i_uop_valid & ~load_pending_r & ~far_call_pending_r &
                                      ~seg_load_pending_r) |
                                     (load_pending_r & i_mem_done) |
                                     (far_call_pending_r & i_mem_done & (far_call_step_r == 2'd1)));
    assign o_seg_load_op_type     = seg_load_op_type;
    assign o_seg_load_target_index = seg_load_target_index;
    assign o_seg_load_selector    = seg_load_selector;
    assign o_seg_load_far_offset  = seg_load_far_offset;
    assign o_seg_load_far_selector = seg_load_far_selector;
    assign o_exc_ud_valid         = exc_ud_valid & i_uop_valid & ~load_pending_r & ~far_call_pending_r;
    assign o_exc_de_valid         = exc_de_valid & i_uop_valid & ~load_pending_r & ~far_call_pending_r;
    assign o_far_ret_new_esp_valid = far_ret_new_esp_valid & i_uop_valid & ~load_pending_r & ~far_call_pending_r;
    assign o_far_ret_new_esp       = far_ret_new_esp;

    assign o_wrb_flags_enable = ((i_uop_valid && ~load_pending_r) | (load_pending_r & i_mem_done)) && write_flags;
    assign o_wrb_flags_data   = flags_data;

    assign o_wrb_ip_enable = ((i_uop_valid && ~load_pending_r) | (load_pending_r & i_mem_done)) && write_ip;
    assign o_wrb_ip_data   = ip_data;

    // While load_pending: non-IO keeps request for LSU→mem_start handshake; IO was a
    // one-cycle pulse (holding it high re-fires memory_stage forever).
    // Drop valid on mem_done / mem_op_complete so access_memory cannot re-enter
    // S_WAIT from S_IDLE while EXU still has load_pending set.
    assign o_mem_valid        = mem_op_complete_eff ? 1'b0 :
                                load_pending_r ?
                                (mem_hold_io_r ? 1'b0 : (mem_hold_valid_r & ~i_mem_done)) :
                                ((i_uop_valid | far_call_pending_r) && mem_valid);
    assign o_mem_write_enable = load_pending_r ? mem_hold_we_r :
                                (i_uop_valid && mem_write_enable);
    assign o_mem_address      = load_pending_r ? mem_hold_addr_r : mem_address;
    assign o_mem_write_data   = load_pending_r ? mem_hold_wdata_r : mem_write_data;
    assign o_data_io_access   = load_pending_r ? mem_hold_io_r : data_io_access;

    assign o_gdtr_write_enable = gdtr_we;
    assign o_gdtr_write_limit  = gdtr_limit;
    assign o_gdtr_write_base   = gdtr_base;
    assign o_idtr_write_enable = idtr_we;
    assign o_idtr_write_limit  = idtr_limit;
    assign o_idtr_write_base   = idtr_base;
    assign o_cr_write_enable   = cr_we;
    assign o_cr_write_index    = cr_index;
    assign o_cr_write_data     = cr_data;
    assign o_invalidate_cache     = inv_cache;
    assign o_wbinvd               = wbinvd_cmd;
    assign o_software_int_valid   = software_int_valid & i_uop_valid & ~load_pending_r;
    assign o_software_int_vector  = software_int_vector;
    assign o_iret_valid           = iret_valid & i_uop_valid & ~load_pending_r;

endmodule
