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
//  File        : dec_to_uop.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Convert decoded macro-instruction to micro-op
// ============================================================================

`include "openx86_defs.h.sv"

module dec_to_uop (
    // =========================
    // Decoded macro-instruction inputs from stage_2_dec
    // =========================
    input  logic                i_opcode_aaa,
    input  logic                i_opcode_aad,
    input  logic                i_opcode_aam,
    input  logic                i_opcode_aas,
    input  logic                i_opcode_adc_reg_to_reg_mem,
    input  logic                i_opcode_adc_reg_mem_to_reg,
    input  logic                i_opcode_adc_imm_to_reg_mem,
    input  logic                i_opcode_adc_imm_to_acc,
    input  logic                i_opcode_add_reg_to_reg_mem,
    input  logic                i_opcode_add_reg_mem_to_reg,
    input  logic                i_opcode_add_imm_to_reg_mem,
    input  logic                i_opcode_add_imm_to_acc,
    input  logic                i_opcode_and_reg_to_reg_mem,
    input  logic                i_opcode_and_reg_mem_to_reg,
    input  logic                i_opcode_and_imm_to_reg_mem,
    input  logic                i_opcode_and_imm_to_acc,
    input  logic                i_opcode_arpl,
    input  logic                i_opcode_bound,
    input  logic                i_opcode_bsf,
    input  logic                i_opcode_bsr,
    input  logic                i_opcode_bswap,
    input  logic                i_opcode_bt_imm,
    input  logic                i_opcode_bt_reg,
    input  logic                i_opcode_btc_imm,
    input  logic                i_opcode_btc_reg,
    input  logic                i_opcode_btr_imm,
    input  logic                i_opcode_btr_reg,
    input  logic                i_opcode_bts_imm,
    input  logic                i_opcode_bts_reg,
    input  logic                i_opcode_call_near_direct,
    input  logic                i_opcode_call_near_indirect,
    input  logic                i_opcode_call_far_direct,
    input  logic                i_opcode_call_far_indirect,
    input  logic                i_opcode_cbw,
    input  logic                i_opcode_cdq,
    input  logic                i_opcode_clc,
    input  logic                i_opcode_cld,
    input  logic                i_opcode_cli,
    input  logic                i_opcode_clts,
    input  logic                i_opcode_cmc,
    input  logic                i_opcode_cmp_mem_reg,
    input  logic                i_opcode_cmp_reg_mem,
    input  logic                i_opcode_cmp_imm_reg_mem,
    input  logic                i_opcode_cmp_imm_acc,
    input  logic                i_opcode_cmps,
    input  logic                i_opcode_cmpxchg,
    input  logic                i_opcode_cpuid,
    input  logic                i_opcode_cwd,
    input  logic                i_opcode_cwde,
    input  logic                i_opcode_daa,
    input  logic                i_opcode_das,
    input  logic                i_opcode_dec_reg_mem,
    input  logic                i_opcode_dec_reg,
    input  logic                i_opcode_div,
    input  logic                i_opcode_hlt,
    input  logic                i_opcode_idiv,
    input  logic                i_opcode_imul_acc,
    input  logic                i_opcode_imul_reg,
    input  logic                i_opcode_imul_imm,
    input  logic                i_opcode_in_fixed,
    input  logic                i_opcode_in_var,
    input  logic                i_opcode_inc_reg_mem,
    input  logic                i_opcode_inc_reg,
    input  logic                i_opcode_ins,
    input  logic                i_opcode_int_n,
    input  logic                i_opcode_int_3,
    input  logic                i_opcode_int_4,
    input  logic                i_opcode_invd,
    input  logic                i_opcode_invlpg,
    input  logic                i_opcode_invpcid,
    input  logic                i_opcode_iret,
    input  logic                i_opcode_jcc_short,
    input  logic                i_opcode_jcc_near,
    input  logic                i_opcode_jcxz,
    input  logic                i_opcode_jmp_short,
    input  logic                i_opcode_jmp_near_direct,
    input  logic                i_opcode_jmp_near_indirect,
    input  logic                i_opcode_jmp_far_direct,
    input  logic                i_opcode_jmp_far_indirect,
    input  logic                i_opcode_lahf,
    input  logic                i_opcode_lar,
    input  logic                i_opcode_lds,
    input  logic                i_opcode_lea,
    input  logic                i_opcode_leave,
    input  logic                i_opcode_les,
    input  logic                i_opcode_lfs,
    input  logic                i_opcode_lgdt,
    input  logic                i_opcode_lgs,
    input  logic                i_opcode_lidt,
    input  logic                i_opcode_lldt,
    input  logic                i_opcode_lmsw,
    input  logic                i_opcode_lods,
    input  logic                i_opcode_loop,
    input  logic                i_opcode_loopz,
    input  logic                i_opcode_loopnz,
    input  logic                i_opcode_lsl,
    input  logic                i_opcode_lss,
    input  logic                i_opcode_ltr,
    input  logic                i_opcode_mov_reg_to_reg_mem,
    input  logic                i_opcode_mov_reg_mem_to_reg,
    input  logic                i_opcode_mov_imm_to_reg_mem,
    input  logic                i_opcode_mov_imm_to_reg,
    input  logic                i_opcode_mov_mem_to_acc,
    input  logic                i_opcode_mov_acc_to_mem,
    input  logic                i_opcode_mov_cr_from_reg,
    input  logic                i_opcode_mov_reg_from_cr,
    input  logic                i_opcode_mov_dr_from_reg,
    input  logic                i_opcode_mov_reg_from_dr,
    input  logic                i_opcode_mov_tr_from_reg,
    input  logic                i_opcode_mov_reg_from_tr,
    input  logic                i_opcode_mov_reg_mem_to_sreg,
    input  logic                i_opcode_mov_sreg_to_reg_mem,
    input  logic                i_opcode_movbe_mem_reg,
    input  logic                i_opcode_movbe_reg_mem,
    input  logic                i_opcode_movs,
    input  logic                i_opcode_movsx,
    input  logic                i_opcode_movzx,
    input  logic                i_opcode_mul,
    input  logic                i_opcode_neg,
    input  logic                i_opcode_nop,
    input  logic                i_opcode_nop_multibyte,
    input  logic                i_opcode_not,
    input  logic                i_opcode_or_reg_to_reg_mem,
    input  logic                i_opcode_or_reg_mem_to_reg,
    input  logic                i_opcode_or_imm_to_reg_mem,
    input  logic                i_opcode_or_imm_to_acc,
    input  logic                i_opcode_out_fixed,
    input  logic                i_opcode_out_var,
    input  logic                i_opcode_outs,
    input  logic                i_opcode_pop_reg_mem,
    input  logic                i_opcode_pop_reg,
    input  logic                i_opcode_pop_sreg_2,
    input  logic                i_opcode_pop_sreg_3,
    input  logic                i_opcode_popa,
    input  logic                i_opcode_popf,
    input  logic                i_opcode_push_reg_mem,
    input  logic                i_opcode_push_reg,
    input  logic                i_opcode_push_sreg_2,
    input  logic                i_opcode_push_sreg_3,
    input  logic                i_opcode_push_imm,
    input  logic                i_opcode_pusha,
    input  logic                i_opcode_pushf,
    input  logic                i_opcode_rcl_1,
    input  logic                i_opcode_rcl_cl,
    input  logic                i_opcode_rcl_imm,
    input  logic                i_opcode_rcr_1,
    input  logic                i_opcode_rcr_cl,
    input  logic                i_opcode_rcr_imm,
    input  logic                i_opcode_rdmsr,
    input  logic                i_opcode_rdpmc,
    input  logic                i_opcode_rdtsc,
    input  logic                i_opcode_rdtscp,
    input  logic                i_opcode_ret_near,
    input  logic                i_opcode_ret_near_imm,
    input  logic                i_opcode_ret_far,
    input  logic                i_opcode_ret_far_imm,
    input  logic                i_opcode_rol_1,
    input  logic                i_opcode_rol_cl,
    input  logic                i_opcode_rol_imm,
    input  logic                i_opcode_ror_1,
    input  logic                i_opcode_ror_cl,
    input  logic                i_opcode_ror_imm,
    input  logic                i_opcode_rsm,
    input  logic                i_opcode_sahf,
    input  logic                i_opcode_sar_1,
    input  logic                i_opcode_sar_cl,
    input  logic                i_opcode_sar_imm,
    input  logic                i_opcode_sbb_reg_to_reg_mem,
    input  logic                i_opcode_sbb_reg_mem_to_reg,
    input  logic                i_opcode_sbb_imm_to_reg_mem,
    input  logic                i_opcode_sbb_imm_to_acc,
    input  logic                i_opcode_scas,
    input  logic                i_opcode_setcc,
    input  logic                i_opcode_sgdt,
    input  logic                i_opcode_shl_1,
    input  logic                i_opcode_shl_cl,
    input  logic                i_opcode_shl_imm,
    input  logic                i_opcode_shld_imm,
    input  logic                i_opcode_shld_cl,
    input  logic                i_opcode_shr_1,
    input  logic                i_opcode_shr_cl,
    input  logic                i_opcode_shr_imm,
    input  logic                i_opcode_shrd_imm,
    input  logic                i_opcode_shrd_cl,
    input  logic                i_opcode_sidt,
    input  logic                i_opcode_sldt,
    input  logic                i_opcode_smsw,
    input  logic                i_opcode_stc,
    input  logic                i_opcode_std,
    input  logic                i_opcode_sti,
    input  logic                i_opcode_stos,
    input  logic                i_opcode_str,
    input  logic                i_opcode_sub_reg_to_reg_mem,
    input  logic                i_opcode_sub_reg_mem_to_reg,
    input  logic                i_opcode_sub_imm_to_reg_mem,
    input  logic                i_opcode_sub_imm_to_acc,
    input  logic                i_opcode_test_reg_mem,
    input  logic                i_opcode_test_imm_reg_mem,
    input  logic                i_opcode_test_imm_acc,
    input  logic                i_opcode_ud0,
    input  logic                i_opcode_ud1,
    input  logic                i_opcode_ud2,
    input  logic                i_opcode_verr,
    input  logic                i_opcode_verw,
    input  logic                i_opcode_wait,
    input  logic                i_opcode_wbinvd,
    input  logic                i_opcode_wrmsr,
    input  logic                i_opcode_xadd,
    input  logic                i_opcode_xchg_reg_mem,
    input  logic                i_opcode_xchg_acc,
    input  logic                i_opcode_xlat,
    input  logic                i_opcode_xor_reg_to_reg_mem,
    input  logic                i_opcode_xor_reg_mem_to_reg,
    input  logic                i_opcode_xor_imm_to_reg_mem,
    input  logic                i_opcode_xor_imm_to_acc,
    input  logic                i_opcode_x87_esc,
    input  logic [ 4: 0]        i_x87_exe_subop,
    input  logic [ 2: 0]        i_x87_sti,
    input  logic                i_x87_mem_access,
    input  logic                i_x87_is_store,
    input  logic                i_opcode_mmx_any,
    input  logic                i_opcode_mmx_emms,
    input  logic                i_opcode_sse_any,
    input  logic [ 3: 0]        i_tttn,
    input  logic [ 2: 0]        i_eee,

    input  logic [31: 0]        i_dec_displacement,
    input  logic [31: 0]        i_dec_immediate,
    input  logic                i_dec_base_reg_is_present,
    input  logic [ 2: 0]        i_dec_base_reg_index,
    input  logic                i_dec_index_reg_is_present,
    input  logic [ 2: 0]        i_dec_index_reg_index,
    input  logic [ 2: 0]        i_dec_segment_reg_index,
    input  logic [ 2: 0]        i_dec_target_sreg_index,
    input  logic [ 1: 0]        i_dec_sib_scale_factor,
    input  logic [ 1: 0]        i_dec_modrm_mod,

    // =========================
    // Stage handshake
    // =========================
    input  logic                i_stage2_valid,

    // =========================
    // Micro-op output
    // =========================
    output micro_op_t           o_uop
);

    // ============================================================
    // Micro-op conversion signals
    // ============================================================
    micro_op_t uop_next;

    // Default micro-op (NOP)
    micro_op_t uop_default;
    assign uop_default = '{
        uop_opcode:      `UOP_NOP,
        uop_dest_reg:    3'b0,
        uop_src1_reg:    3'b0,
        uop_src2_reg:    3'b0,
        uop_immediate:   32'd0,
        uop_displacement: 32'd0,
        uop_tttn:        4'b0,
        uop_eee:         6'b0,
        uop_seg_index:   `index_reg_seg__DS,
        uop_sib_scale:   2'b0,
        uop_has_imm:     1'b0,
        uop_has_disp:    1'b0,
        uop_mem_access:  1'b0,
        uop_is_store:    1'b0,
        uop_rep:         1'b0,
        uop_repne:       1'b0,
        uop_valid:       1'b0
    };

    // Macro-instruction to micro-op conversion logic
    always_comb begin
        uop_next = uop_default;

        if (i_stage2_valid) begin
            uop_next.uop_valid    = 1'b1;
            uop_next.uop_tttn       = i_tttn;
            uop_next.uop_eee        = {3'b0, i_eee};
            uop_next.uop_seg_index  = i_dec_segment_reg_index;
            uop_next.uop_sib_scale  = i_dec_sib_scale_factor;

            // Data transfer instructions: MOV, MOVSX, MOVZX, XCHG, LEA
            if (i_opcode_mov_reg_mem_to_sreg) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {13'h0, i_dec_target_sreg_index, `MISC_SUB_MOV_SEG};
                uop_next.uop_mem_access = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_mov_reg_to_reg_mem || i_opcode_mov_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_MOV;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_mov_imm_to_reg_mem || i_opcode_mov_imm_to_reg) begin
                uop_next.uop_opcode = `UOP_MOV;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_mov_mem_to_acc || i_opcode_mov_acc_to_mem) begin
                uop_next.uop_opcode = `UOP_MOV;
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_is_store = i_opcode_mov_acc_to_mem;
                uop_next.uop_dest_reg = 3'b0; // EAX
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_movsx) begin
                uop_next.uop_opcode = `UOP_MOVSX;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_movzx) begin
                uop_next.uop_opcode = `UOP_MOVZX;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_xchg_reg_mem || i_opcode_xchg_acc) begin
                uop_next.uop_opcode = `UOP_XCHG;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_lea) begin
                uop_next.uop_opcode = `UOP_LEA;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
            end

            // Arithmetic instructions: ADD, ADC, SUB, SBB, INC, DEC, NEG, CMP
            else if (i_opcode_add_reg_to_reg_mem || i_opcode_add_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_ADD;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_add_imm_to_reg_mem || i_opcode_add_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_ADD;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_adc_reg_to_reg_mem || i_opcode_adc_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_ADC;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_adc_imm_to_reg_mem || i_opcode_adc_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_ADC;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_sub_reg_to_reg_mem || i_opcode_sub_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_SUB;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_sub_imm_to_reg_mem || i_opcode_sub_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_SUB;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_sbb_reg_to_reg_mem || i_opcode_sbb_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_SBB;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_sbb_imm_to_reg_mem || i_opcode_sbb_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_SBB;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_inc_reg_mem || i_opcode_inc_reg) begin
                uop_next.uop_opcode = `UOP_INC;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_dec_reg_mem || i_opcode_dec_reg) begin
                uop_next.uop_opcode = `UOP_DEC;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_neg) begin
                uop_next.uop_opcode = `UOP_NEG;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_cmp_mem_reg || i_opcode_cmp_reg_mem) begin
                uop_next.uop_opcode = `UOP_CMP;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_cmp_imm_reg_mem || i_opcode_cmp_imm_acc) begin
                uop_next.uop_opcode = `UOP_CMP;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end

            // Logic instructions: AND, OR, XOR, NOT, TEST
            else if (i_opcode_and_reg_to_reg_mem || i_opcode_and_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_AND;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_and_imm_to_reg_mem || i_opcode_and_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_AND;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_or_reg_to_reg_mem || i_opcode_or_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_OR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_or_imm_to_reg_mem || i_opcode_or_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_OR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_xor_reg_to_reg_mem || i_opcode_xor_reg_mem_to_reg) begin
                uop_next.uop_opcode = `UOP_XOR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_xor_imm_to_reg_mem || i_opcode_xor_imm_to_acc) begin
                uop_next.uop_opcode = `UOP_XOR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_not) begin
                uop_next.uop_opcode = `UOP_NOT;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_test_reg_mem) begin
                uop_next.uop_opcode = `UOP_TEST;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_test_imm_reg_mem || i_opcode_test_imm_acc) begin
                uop_next.uop_opcode = `UOP_TEST;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end

            // Shift instructions: SHL, SHR, SAR, ROL, ROR, RCL, RCR, SHLD, SHRD
            else if (i_opcode_shl_1 || i_opcode_shl_cl || i_opcode_shl_imm) begin
                uop_next.uop_opcode = `UOP_SHL;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_shl_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_shr_1 || i_opcode_shr_cl || i_opcode_shr_imm) begin
                uop_next.uop_opcode = `UOP_SHR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_shr_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_sar_1 || i_opcode_sar_cl || i_opcode_sar_imm) begin
                uop_next.uop_opcode = `UOP_SAR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_sar_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_rol_1 || i_opcode_rol_cl || i_opcode_rol_imm) begin
                uop_next.uop_opcode = `UOP_ROL;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_rol_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_ror_1 || i_opcode_ror_cl || i_opcode_ror_imm) begin
                uop_next.uop_opcode = `UOP_ROR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_ror_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_rcl_1 || i_opcode_rcl_cl || i_opcode_rcl_imm) begin
                uop_next.uop_opcode = `UOP_RCL;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_rcl_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_rcr_1 || i_opcode_rcr_cl || i_opcode_rcr_imm) begin
                uop_next.uop_opcode = `UOP_RCR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_rcr_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_shld_imm || i_opcode_shld_cl) begin
                uop_next.uop_opcode = `UOP_SHLD;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_shld_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_shrd_imm || i_opcode_shrd_cl) begin
                uop_next.uop_opcode = `UOP_SHRD;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
                uop_next.uop_has_imm = (i_opcode_shrd_imm);
                uop_next.uop_immediate = i_dec_immediate;
            end

            // Multiply/Divide instructions: MUL, IMUL, DIV, IDIV
            else if (i_opcode_mul) begin
                uop_next.uop_opcode = `UOP_MUL;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_imul_acc || i_opcode_imul_reg) begin
                uop_next.uop_opcode = `UOP_IMUL;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_imul_imm) begin
                uop_next.uop_opcode = `UOP_IMUL;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = 1'b1;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_div) begin
                uop_next.uop_opcode = `UOP_DIV;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_idiv) begin
                uop_next.uop_opcode = `UOP_IDIV;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end

            // Stack instructions: PUSH, POP
            else if (i_opcode_push_reg || i_opcode_push_reg_mem || i_opcode_push_imm) begin
                uop_next.uop_opcode = `UOP_PUSH;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = i_opcode_push_imm;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_pusha || i_opcode_pushf) begin
                uop_next.uop_opcode = `UOP_PUSH;
            end else if (i_opcode_pop_reg || i_opcode_pop_reg_mem) begin
                uop_next.uop_opcode = `UOP_POP;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_popa || i_opcode_popf) begin
                uop_next.uop_opcode = `UOP_POP;
            end

            // Control flow instructions: JMP, CALL, RET, LOOP, Jcc
            else if (i_opcode_jmp_far_direct) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {8'h0, i_dec_immediate[15: 0], `MISC_SUB_FAR_JMP};
                uop_next.uop_displacement = i_dec_displacement;
                uop_next.uop_has_disp = 1'b1;
            end else if (i_opcode_jmp_far_indirect) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_FAR_JMP};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_call_far_direct) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {8'h0, i_dec_immediate[15: 0], `MISC_SUB_FAR_CALL};
                uop_next.uop_displacement = i_dec_displacement;
                uop_next.uop_has_disp = 1'b1;
            end else if (i_opcode_call_far_indirect) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_FAR_CALL};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_ret_far || i_opcode_ret_far_imm) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_FAR_RET};
                uop_next.uop_has_disp = (i_opcode_ret_far_imm);
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_jmp_short || i_opcode_jmp_near_direct || i_opcode_jmp_near_indirect) begin
                uop_next.uop_opcode = `UOP_BRANCH;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_call_near_direct || i_opcode_call_near_indirect) begin
                uop_next.uop_opcode = `UOP_CALL;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_ret_near || i_opcode_ret_near_imm) begin
                uop_next.uop_opcode = `UOP_RET;
                uop_next.uop_has_disp = i_opcode_ret_near_imm;
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_loop || i_opcode_loopz || i_opcode_loopnz || i_opcode_jcxz) begin
                uop_next.uop_opcode = `UOP_BRANCH;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_jcc_short || i_opcode_jcc_near) begin
                uop_next.uop_opcode = `UOP_BRANCH;
                uop_next.uop_has_disp = 1'b1;
                uop_next.uop_displacement = i_dec_displacement;
            end

            // String instructions: MOVS, CMPS, SCAS, LODS, STOS, INS, OUTS
            else if (i_opcode_movs || i_opcode_cmps || i_opcode_scas ||
                     i_opcode_lods || i_opcode_stos || i_opcode_ins || i_opcode_outs) begin
                uop_next.uop_opcode = `UOP_STRING;
            end

            // Bit manipulation instructions: BT, BTS, BTR, BTC, BSF, BSR
            else if (i_opcode_bt_imm || i_opcode_bt_reg) begin
                uop_next.uop_opcode = `UOP_BT;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = i_opcode_bt_imm;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_bts_imm || i_opcode_bts_reg) begin
                uop_next.uop_opcode = `UOP_BTS;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = i_opcode_bts_imm;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_btr_imm || i_opcode_btr_reg) begin
                uop_next.uop_opcode = `UOP_BTR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = i_opcode_btr_imm;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_btc_imm || i_opcode_btc_reg) begin
                uop_next.uop_opcode = `UOP_BTC;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_has_imm = i_opcode_btc_imm;
                uop_next.uop_immediate = i_dec_immediate;
            end else if (i_opcode_bsf) begin
                uop_next.uop_opcode = `UOP_BSF;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_bsr) begin
                uop_next.uop_opcode = `UOP_BSR;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end

            // Flag control instructions: CLC, STC, CMC, CLD, STD, CLI, STI, LAHF, SAHF
            else if (i_opcode_clc) begin
                uop_next.uop_opcode = `UOP_FLAG_CTRL;
                uop_next.uop_immediate = {24'h0, 8'h01};
            end else if (i_opcode_stc) begin
                uop_next.uop_opcode = `UOP_FLAG_CTRL;
                uop_next.uop_immediate = {24'h0, 8'h02};
            end else if (i_opcode_cmc) begin
                uop_next.uop_opcode = `UOP_FLAG_CTRL;
                uop_next.uop_immediate = {24'h0, 8'h03};
            end else if (i_opcode_cld || i_opcode_std || i_opcode_cli || i_opcode_sti ||
                     i_opcode_lahf || i_opcode_sahf) begin
                uop_next.uop_opcode = `UOP_FLAG_CTRL;
                uop_next.uop_immediate = {24'h0,
                    i_opcode_cld ? 8'h04 :
                    i_opcode_std ? 8'h05 :
                    i_opcode_cli ? 8'h06 :
                    i_opcode_sti ? 8'h07 :
                    i_opcode_lahf ? 8'h08 : 8'h09};
            end

            // Other instructions: NOP, BSWAP, XADD, CMPXCHG, SETcc, XLAT, CBW, CWDE, CDQ
            else if (i_opcode_nop || i_opcode_nop_multibyte) begin
                uop_next.uop_opcode = `UOP_NOP;
            end             else if (i_opcode_bswap) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_BSWAP};
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_xadd) begin
                uop_next.uop_opcode = `UOP_XADD;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_cmpxchg) begin
                uop_next.uop_opcode = `UOP_CMPXCHG;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
                uop_next.uop_src1_reg = i_dec_index_reg_is_present ? i_dec_index_reg_index : 3'b0;
            end else if (i_opcode_setcc) begin
                uop_next.uop_opcode = `UOP_SETCC;
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_xlat) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_XLAT};
                uop_next.uop_mem_access = 1'b1;
            end else if (i_opcode_cbw) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_CBW};
                uop_next.uop_dest_reg = 3'd0; // EAX/AX
                uop_next.uop_src1_reg = 3'd0;
            end else if (i_opcode_cwde) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_CWDE};
                uop_next.uop_dest_reg = 3'd0;
                uop_next.uop_src1_reg = 3'd0;
            end else if (i_opcode_cdq || i_opcode_cwd) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_CDQ};
                uop_next.uop_dest_reg = 3'd2; // EDX
                uop_next.uop_src1_reg = 3'd0; // EAX
            end

            // x87 instructions
            else if (i_opcode_x87_esc) begin
                uop_next.uop_opcode     = `UOP_X87;
                uop_next.uop_eee        = {1'b0, i_x87_exe_subop};
                uop_next.uop_src2_reg   = i_x87_sti;
                uop_next.uop_mem_access = i_x87_mem_access;
                uop_next.uop_is_store   = i_x87_is_store;
                if (i_x87_mem_access) begin
                    uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                    uop_next.uop_displacement = i_dec_displacement;
                    uop_next.uop_src1_reg = i_dec_base_reg_is_present ?
                                            i_dec_base_reg_index : 3'b0;
                end
            end

            // Post-486 decode noise: raise #UD (not in 80486DX ISA contract)
            else if (i_opcode_mmx_emms || i_opcode_mmx_any || i_opcode_sse_any) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_UD};
            end

            // CPUID
            else if (i_opcode_cpuid) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_CPUID};
                uop_next.uop_src1_reg = 3'd0; // EAX
                uop_next.uop_src2_reg = 3'd1; // ECX
            end

            // BCD adjust
            else if (i_opcode_aaa) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_AAA};
            end else if (i_opcode_aas) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_AAS};
            end else if (i_opcode_daa) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_DAA};
            end else if (i_opcode_das) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_DAS};
            end else if (i_opcode_aad) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_AAD};
            end else if (i_opcode_aam) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_AAM};
            end

            // System instructions (HLT, INT, IRET, etc.)
            else if (i_opcode_hlt) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_HLT};
            end else if (i_opcode_invd) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_INVD};
            end else if (i_opcode_invlpg) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_INVLPG};
            end else if (i_opcode_wbinvd) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_WBINVD};
            end else if (i_opcode_int_n) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {16'h0, i_dec_immediate[7: 0], `MISC_SUB_INT};
            end else if (i_opcode_int_3) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {16'h0, 8'h03, `MISC_SUB_INT};
            end else if (i_opcode_int_4) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {16'h0, 8'h04, `MISC_SUB_INT};
            end else if (i_opcode_iret) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_IRET};
            end else if (i_opcode_invpcid ||
                     i_opcode_rdmsr || i_opcode_wrmsr || i_opcode_rdtsc || i_opcode_rdtscp ||
                     i_opcode_rdpmc || i_opcode_rsm) begin
                // Post-486 / unimplemented system → #UD
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_UD};
            end else if (i_opcode_wait) begin
                // WAIT: treat as NOP when no pending FPU exception (486DX subset)
                uop_next.uop_opcode = `UOP_NOP;
            end

            // Segment/Privilege instructions
            else if (i_opcode_lgdt) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LGDT};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_lidt) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LIDT};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_sgdt) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_SGDT};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_is_store = 1'b1;
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_sidt) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_SIDT};
                uop_next.uop_mem_access = 1'b1;
                uop_next.uop_is_store = 1'b1;
                uop_next.uop_has_disp = (i_dec_modrm_mod != 2'b11);
                uop_next.uop_displacement = i_dec_displacement;
            end else if (i_opcode_lmsw || i_opcode_mov_cr_from_reg) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, i_opcode_lmsw ? `MISC_SUB_LMSW : `MISC_SUB_MOV_CR};
            end else if (i_opcode_clts) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_CLTS};
            end else if (i_opcode_smsw) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_SMSW};
                uop_next.uop_dest_reg = i_dec_base_reg_is_present ? i_dec_base_reg_index : 3'b0;
            end else if (i_opcode_lldt) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LLDT};
            end else if (i_opcode_ltr) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LTR};
            end else if (i_opcode_lar) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LAR};
            end else if (i_opcode_lsl) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LSL};
            end else if (i_opcode_verr) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_VERR};
            end else if (i_opcode_verw) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_VERW};
            end else if (i_opcode_arpl) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_ARPL};
            end else if (i_opcode_bound) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_BOUND};
                uop_next.uop_mem_access = 1'b1;
            end else if (i_opcode_leave) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LEAVE};
                uop_next.uop_dest_reg = 3'd5; // EBP receives POP; ESP via special enable
            end else if (i_opcode_lds) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LDS};
                uop_next.uop_mem_access = 1'b1;
            end else if (i_opcode_les) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LES};
                uop_next.uop_mem_access = 1'b1;
            end else if (i_opcode_lfs) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LFS};
                uop_next.uop_mem_access = 1'b1;
            end else if (i_opcode_lgs) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LGS};
                uop_next.uop_mem_access = 1'b1;
            end else if (i_opcode_lss) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_LSS};
                uop_next.uop_mem_access = 1'b1;
            end else if (i_opcode_push_sreg_2 || i_opcode_push_sreg_3) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {13'h0, i_dec_target_sreg_index, `MISC_SUB_PUSH_SEG};
            end else if (i_opcode_pop_sreg_2 || i_opcode_pop_sreg_3) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {13'h0, i_dec_target_sreg_index, `MISC_SUB_POP_SEG};
            end else if (i_opcode_str || i_opcode_sldt || i_opcode_mov_reg_from_cr ||
                         i_opcode_mov_dr_from_reg || i_opcode_mov_reg_from_dr ||
                         i_opcode_mov_tr_from_reg || i_opcode_mov_reg_from_tr) begin
                // Partially wired control/debug/test register ops — #UD until complete
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_UD};
            end

            // I/O instructions (IN, OUT)
            else if (i_opcode_in_fixed || i_opcode_in_var) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_IN};
            end else if (i_opcode_out_fixed || i_opcode_out_var) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_OUT};
            end

            // Explicit undefined opcodes
            else if (i_opcode_ud0 || i_opcode_ud1 || i_opcode_ud2) begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_UD};
            end

            // Unmapped decode → architectural #UD (never silent NOP)
            else begin
                uop_next.uop_opcode = `UOP_MISC;
                uop_next.uop_immediate = {24'h0, `MISC_SUB_UD};
            end
        end
    end

    // ============================================================
    // Output assignment
    // ============================================================
    assign o_uop = uop_next;

endmodule
