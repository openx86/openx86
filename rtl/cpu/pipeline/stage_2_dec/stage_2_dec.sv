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
//  File        : stage_2_dec.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : 3-stage pipelined x86 instruction decoder (prefix -> opcode -> operand)
// ============================================================================

`include "openx86_defs.h.sv"

module stage_2_dec (
    // =========================
    // IFU to DEC handshake
    // =========================
    input  logic [15: 0][ 7: 0] i_ifu_instruction,
    input  logic                i_ifu_instruction_valid,
    input  logic                i_ifu_segment_fault,
    input  logic [ 4: 0]        i_ifu_fifo_count,
    input  logic [31: 0]        i_ifu_eip,
    output logic                o_ifu_dec_ready,
    output logic                o_ifu_dec_fire,
    output logic [ 3: 0]        o_ifu_dec_consume_bytes,
    output logic                o_ifu_dec_error,

    // =========================
    // DEC to UOP handshake
    // =========================
    output logic                o_uop_stage2_valid,
    input  logic                i_uop_stage2_ready,
    input  logic                i_uop_flush,

    // =========================
    // Decoded opcode outputs (to stage_3_uop)
    // =========================
    output logic                o_opcode_aaa,
    output logic                o_opcode_aad,
    output logic                o_opcode_aam,
    output logic                o_opcode_aas,
    output logic                o_opcode_adc_reg_to_reg_mem,
    output logic                o_opcode_adc_reg_mem_to_reg,
    output logic                o_opcode_adc_imm_to_reg_mem,
    output logic                o_opcode_adc_imm_to_acc,
    output logic                o_opcode_add_reg_to_reg_mem,
    output logic                o_opcode_add_reg_mem_to_reg,
    output logic                o_opcode_add_imm_to_reg_mem,
    output logic                o_opcode_add_imm_to_acc,
    output logic                o_opcode_and_reg_to_reg_mem,
    output logic                o_opcode_and_reg_mem_to_reg,
    output logic                o_opcode_and_imm_to_reg_mem,
    output logic                o_opcode_and_imm_to_acc,
    output logic                o_opcode_arpl,
    output logic                o_opcode_bound,
    output logic                o_opcode_bsf,
    output logic                o_opcode_bsr,
    output logic                o_opcode_bswap,
    output logic                o_opcode_bt_imm,
    output logic                o_opcode_bt_reg,
    output logic                o_opcode_btc_imm,
    output logic                o_opcode_btc_reg,
    output logic                o_opcode_btr_imm,
    output logic                o_opcode_btr_reg,
    output logic                o_opcode_bts_imm,
    output logic                o_opcode_bts_reg,
    output logic                o_opcode_call_near_direct,
    output logic                o_opcode_call_near_indirect,
    output logic                o_opcode_call_far_direct,
    output logic                o_opcode_call_far_indirect,
    output logic                o_opcode_cbw,
    output logic                o_opcode_cdq,
    output logic                o_opcode_clc,
    output logic                o_opcode_cld,
    output logic                o_opcode_cli,
    output logic                o_opcode_clts,
    output logic                o_opcode_cmc,
    output logic                o_opcode_cmp_mem_reg,
    output logic                o_opcode_cmp_reg_mem,
    output logic                o_opcode_cmp_imm_reg_mem,
    output logic                o_opcode_cmp_imm_acc,
    output logic                o_opcode_cmps,
    output logic                o_opcode_cmpxchg,
    output logic                o_opcode_cpuid,
    output logic                o_opcode_cwd,
    output logic                o_opcode_cwde,
    output logic                o_opcode_daa,
    output logic                o_opcode_das,
    output logic                o_opcode_dec_reg_mem,
    output logic                o_opcode_dec_reg,
    output logic                o_opcode_div,
    output logic                o_opcode_hlt,
    output logic                o_opcode_idiv,
    output logic                o_opcode_imul_acc,
    output logic                o_opcode_imul_reg,
    output logic                o_opcode_imul_imm,
    output logic                o_opcode_in_fixed,
    output logic                o_opcode_in_var,
    output logic                o_opcode_inc_reg_mem,
    output logic                o_opcode_inc_reg,
    output logic                o_opcode_ins,
    output logic                o_opcode_int_n,
    output logic                o_opcode_int_3,
    output logic                o_opcode_int_4,
    output logic                o_opcode_invd,
    output logic                o_opcode_invlpg,
    output logic                o_opcode_invpcid,
    output logic                o_opcode_iret,
    output logic                o_opcode_jcc_short,
    output logic                o_opcode_jcc_near,
    output logic                o_opcode_jcxz,
    output logic                o_opcode_jmp_short,
    output logic                o_opcode_jmp_near_direct,
    output logic                o_opcode_jmp_near_indirect,
    output logic                o_opcode_jmp_far_direct,
    output logic                o_opcode_jmp_far_indirect,
    output logic                o_opcode_lahf,
    output logic                o_opcode_lar,
    output logic                o_opcode_lds,
    output logic                o_opcode_lea,
    output logic                o_opcode_leave,
    output logic                o_opcode_les,
    output logic                o_opcode_lfs,
    output logic                o_opcode_lgdt,
    output logic                o_opcode_lgs,
    output logic                o_opcode_lidt,
    output logic                o_opcode_lldt,
    output logic                o_opcode_lmsw,
    output logic                o_opcode_lods,
    output logic                o_opcode_loop,
    output logic                o_opcode_loopz,
    output logic                o_opcode_loopnz,
    output logic                o_opcode_lsl,
    output logic                o_opcode_lss,
    output logic                o_opcode_ltr,
    output logic                o_opcode_mov_reg_to_reg_mem,
    output logic                o_opcode_mov_reg_mem_to_reg,
    output logic                o_opcode_mov_imm_to_reg_mem,
    output logic                o_opcode_mov_imm_to_reg,
    output logic                o_opcode_mov_mem_to_acc,
    output logic                o_opcode_mov_acc_to_mem,
    output logic                o_opcode_mov_cr_from_reg,
    output logic                o_opcode_mov_reg_from_cr,
    output logic                o_opcode_mov_dr_from_reg,
    output logic                o_opcode_mov_reg_from_dr,
    output logic                o_opcode_mov_tr_from_reg,
    output logic                o_opcode_mov_reg_from_tr,
    output logic                o_opcode_mov_reg_mem_to_sreg,
    output logic                o_opcode_mov_sreg_to_reg_mem,
    output logic                o_opcode_movbe_mem_reg,
    output logic                o_opcode_movbe_reg_mem,
    output logic                o_opcode_movs,
    output logic                o_opcode_movsx,
    output logic                o_opcode_movzx,
    output logic                o_opcode_mul,
    output logic                o_opcode_neg,
    output logic                o_opcode_nop,
    output logic                o_opcode_nop_multibyte,
    output logic                o_opcode_not,
    output logic                o_opcode_or_reg_to_reg_mem,
    output logic                o_opcode_or_reg_mem_to_reg,
    output logic                o_opcode_or_imm_to_reg_mem,
    output logic                o_opcode_or_imm_to_acc,
    output logic                o_opcode_out_fixed,
    output logic                o_opcode_out_var,
    output logic                o_opcode_outs,
    output logic                o_opcode_pop_reg_mem,
    output logic                o_opcode_pop_reg,
    output logic                o_opcode_pop_sreg_2,
    output logic                o_opcode_pop_sreg_3,
    output logic                o_opcode_popa,
    output logic                o_opcode_popf,
    output logic                o_opcode_push_reg_mem,
    output logic                o_opcode_push_reg,
    output logic                o_opcode_push_sreg_2,
    output logic                o_opcode_push_sreg_3,
    output logic                o_opcode_push_imm,
    output logic                o_opcode_pusha,
    output logic                o_opcode_pushf,
    output logic                o_opcode_rcl_1,
    output logic                o_opcode_rcl_cl,
    output logic                o_opcode_rcl_imm,
    output logic                o_opcode_rcr_1,
    output logic                o_opcode_rcr_cl,
    output logic                o_opcode_rcr_imm,
    output logic                o_opcode_rdmsr,
    output logic                o_opcode_rdpmc,
    output logic                o_opcode_rdtsc,
    output logic                o_opcode_rdtscp,
    output logic                o_opcode_ret_near,
    output logic                o_opcode_ret_near_imm,
    output logic                o_opcode_ret_far,
    output logic                o_opcode_ret_far_imm,
    output logic                o_opcode_rol_1,
    output logic                o_opcode_rol_cl,
    output logic                o_opcode_rol_imm,
    output logic                o_opcode_ror_1,
    output logic                o_opcode_ror_cl,
    output logic                o_opcode_ror_imm,
    output logic                o_opcode_rsm,
    output logic                o_opcode_sahf,
    output logic                o_opcode_sar_1,
    output logic                o_opcode_sar_cl,
    output logic                o_opcode_sar_imm,
    output logic                o_opcode_sbb_reg_to_reg_mem,
    output logic                o_opcode_sbb_reg_mem_to_reg,
    output logic                o_opcode_sbb_imm_to_reg_mem,
    output logic                o_opcode_sbb_imm_to_acc,
    output logic                o_opcode_scas,
    output logic                o_opcode_setcc,
    output logic                o_opcode_sgdt,
    output logic                o_opcode_shl_1,
    output logic                o_opcode_shl_cl,
    output logic                o_opcode_shl_imm,
    output logic                o_opcode_shld_imm,
    output logic                o_opcode_shld_cl,
    output logic                o_opcode_shr_1,
    output logic                o_opcode_shr_cl,
    output logic                o_opcode_shr_imm,
    output logic                o_opcode_shrd_imm,
    output logic                o_opcode_shrd_cl,
    output logic                o_opcode_sidt,
    output logic                o_opcode_sldt,
    output logic                o_opcode_smsw,
    output logic                o_opcode_stc,
    output logic                o_opcode_std,
    output logic                o_opcode_sti,
    output logic                o_opcode_stos,
    output logic                o_opcode_str,
    output logic                o_opcode_sub_reg_to_reg_mem,
    output logic                o_opcode_sub_reg_mem_to_reg,
    output logic                o_opcode_sub_imm_to_reg_mem,
    output logic                o_opcode_sub_imm_to_acc,
    output logic                o_opcode_test_reg_mem,
    output logic                o_opcode_test_imm_reg_mem,
    output logic                o_opcode_test_imm_acc,
    output logic                o_opcode_ud0,
    output logic                o_opcode_ud1,
    output logic                o_opcode_ud2,
    output logic                o_opcode_verr,
    output logic                o_opcode_verw,
    output logic                o_opcode_wait,
    output logic                o_opcode_wbinvd,
    output logic                o_opcode_wrmsr,
    output logic                o_opcode_xadd,
    output logic                o_opcode_xchg_reg_mem,
    output logic                o_opcode_xchg_acc,
    output logic                o_opcode_xlat,
    output logic                o_opcode_xor_reg_to_reg_mem,
    output logic                o_opcode_xor_reg_mem_to_reg,
    output logic                o_opcode_xor_imm_to_reg_mem,
    output logic                o_opcode_xor_imm_to_acc,
    output logic                o_opcode_x87_esc,
    output logic [ 3: 0]        o_tttn,
    output logic [ 2: 0]        o_eee,

    // =========================
    // Decoded operand outputs (to stage_3_uop)
    // =========================
    output logic [31: 0]        o_dec_displacement,
    output logic [31: 0]        o_dec_immediate,
    output logic                o_dec_base_reg_is_present,
    output logic [ 2: 0]        o_dec_base_reg_index,
    output logic                o_dec_index_reg_is_present,
    output logic [ 2: 0]        o_dec_index_reg_index,
    output logic [ 2: 0]        o_dec_segment_reg_index,
    output logic [ 1: 0]        o_dec_sib_scale_factor,
    output logic [ 1: 0]        o_dec_modrm_mod,

    // =========================
    // Clock and reset
    // =========================
    input  logic                clk,
    input  logic                rst_n
);

    // ============================================================
    // FSM state definition
    // ============================================================
    typedef enum logic [2: 0] {
        LP_STATE_IDLE          = 3'b000,
        LP_STATE_DECODE_PREFIX = 3'b001,
        LP_STATE_DECODE_OPCODE = 3'b010,
        LP_STATE_DECODE_OPERAND = 3'b011,
        LP_STATE_READY         = 3'b100
    } dec_state_t;

    // ============================================================
    // Pipeline stage registers
    // ============================================================
    dec_state_t               state_r;
    dec_state_t               state_n;

    logic                     stage1_valid_r;
    logic                     stage1_valid_n;
    logic                     stage1_error_r;
    logic                     stage1_error_n;
    logic [ 3: 0]             stage1_prefix_bytes_r;
    logic [ 3: 0]             stage1_prefix_bytes_n;
    logic                     stage1_group_3_operand_size_r;
    logic                     stage1_group_3_operand_size_n;
    logic                     stage1_group_4_address_size_r;
    logic                     stage1_group_4_address_size_n;

    logic                     stage2_valid_r;
    logic                     stage2_valid_n;
    logic                     stage2_error_r;
    logic                     stage2_error_n;
    logic [ 3: 0]             stage2_prefix_bytes_r;
    logic [ 3: 0]             stage2_prefix_bytes_n;
    logic [ 3: 0]             stage2_opcode_bytes_r;
    logic [ 3: 0]             stage2_opcode_bytes_n;
    logic                     stage2_group_3_operand_size_r;
    logic                     stage2_group_3_operand_size_n;
    logic                     stage2_group_4_address_size_r;
    logic                     stage2_group_4_address_size_n;

    logic                     stage3_valid_r;
    logic                     stage3_valid_n;
    logic                     stage3_error_r;
    logic                     stage3_error_n;
    logic [ 3: 0]             stage3_total_bytes_r;
    logic [ 3: 0]             stage3_total_bytes_n;

    // ============================================================
    // Prefix module outputs
    // ============================================================
    logic                     prefix_group_1_lock_bus;
    logic                     prefix_group_1_repeat_not_equal;
    logic                     prefix_group_1_repeat_equal;
    logic                     prefix_group_1_bound;
    logic                     prefix_group_2_segment_override;
    logic                     prefix_group_2_hint_branch_not_taken;
    logic                     prefix_group_2_hint_branch_taken;
    logic                     prefix_group_3_operand_size;
    logic                     prefix_group_4_address_size;
    logic                     prefix_group_1_is_present;
    logic                     prefix_group_2_is_present;
    logic                     prefix_group_3_is_present;
    logic                     prefix_group_4_is_present;
    logic [ 2: 0]             prefix_segment_override_index;
    logic                     prefix_consume_bytes_prefix_1;
    logic                     prefix_consume_bytes_prefix_2;
    logic                     prefix_consume_bytes_prefix_3;
    logic                     prefix_consume_bytes_prefix_4;
    logic                     prefix_error;

    // ============================================================
    // Opcode module outputs (selected subset)
    // ============================================================
    logic                     opcode_aaa;
    logic                     opcode_aad;
    logic                     opcode_aam;
    logic                     opcode_aas;
    logic                     opcode_adc_reg_to_reg_mem;
    logic                     opcode_adc_reg_mem_to_reg;
    logic                     opcode_adc_imm_to_reg_mem;
    logic                     opcode_adc_imm_to_acc;
    logic                     opcode_add_reg_to_reg_mem;
    logic                     opcode_add_reg_mem_to_reg;
    logic                     opcode_add_imm_to_reg_mem;
    logic                     opcode_add_imm_to_acc;
    logic                     opcode_and_reg_to_reg_mem;
    logic                     opcode_and_reg_mem_to_reg;
    logic                     opcode_and_imm_to_reg_mem;
    logic                     opcode_and_imm_to_acc;
    logic                     opcode_arpl;
    logic                     opcode_bound;
    logic                     opcode_bsf;
    logic                     opcode_bsr;
    logic                     opcode_bswap;
    logic                     opcode_bt_imm;
    logic                     opcode_bt_reg;
    logic                     opcode_btc_imm;
    logic                     opcode_btc_reg;
    logic                     opcode_btr_imm;
    logic                     opcode_btr_reg;
    logic                     opcode_bts_imm;
    logic                     opcode_bts_reg;
    logic                     opcode_call_near_direct;
    logic                     opcode_call_near_indirect;
    logic                     opcode_call_far_direct;
    logic                     opcode_call_far_indirect;
    logic                     opcode_cbw;
    logic                     opcode_cdq;
    logic                     opcode_clc;
    logic                     opcode_cld;
    logic                     opcode_cli;
    logic                     opcode_clts;
    logic                     opcode_cmc;
    logic                     opcode_cmp_mem_reg;
    logic                     opcode_cmp_reg_mem;
    logic                     opcode_cmp_imm_reg_mem;
    logic                     opcode_cmp_imm_acc;
    logic                     opcode_cmps;
    logic                     opcode_cmpxchg;
    logic                     opcode_cpuid;
    logic                     opcode_cwd;
    logic                     opcode_cwde;
    logic                     opcode_daa;
    logic                     opcode_das;
    logic                     opcode_dec_reg_mem;
    logic                     opcode_dec_reg;
    logic                     opcode_div;
    logic                     opcode_hlt;
    logic                     opcode_idiv;
    logic                     opcode_imul_acc;
    logic                     opcode_imul_reg;
    logic                     opcode_imul_imm;
    logic                     opcode_in_fixed;
    logic                     opcode_in_var;
    logic                     opcode_inc_reg_mem;
    logic                     opcode_inc_reg;
    logic                     opcode_ins;
    logic                     opcode_int_n;
    logic                     opcode_int_3;
    logic                     opcode_int_4;
    logic                     opcode_invd;
    logic                     opcode_invlpg;
    logic                     opcode_invpcid;
    logic                     opcode_iret;
    logic                     opcode_jcc_short;
    logic                     opcode_jcc_near;
    logic                     opcode_jcxz;
    logic                     opcode_jmp_short;
    logic                     opcode_jmp_near_direct;
    logic                     opcode_jmp_near_indirect;
    logic                     opcode_jmp_far_direct;
    logic                     opcode_jmp_far_indirect;
    logic                     opcode_lahf;
    logic                     opcode_lar;
    logic                     opcode_lds;
    logic                     opcode_lea;
    logic                     opcode_leave;
    logic                     opcode_les;
    logic                     opcode_lfs;
    logic                     opcode_lgdt;
    logic                     opcode_lgs;
    logic                     opcode_lidt;
    logic                     opcode_lldt;
    logic                     opcode_lmsw;
    logic                     opcode_lods;
    logic                     opcode_loop;
    logic                     opcode_loopz;
    logic                     opcode_loopnz;
    logic                     opcode_lsl;
    logic                     opcode_lss;
    logic                     opcode_ltr;
    logic                     opcode_mov_reg_to_reg_mem;
    logic                     opcode_mov_reg_mem_to_reg;
    logic                     opcode_mov_imm_to_reg_mem;
    logic                     opcode_mov_imm_to_reg;
    logic                     opcode_mov_mem_to_acc;
    logic                     opcode_mov_acc_to_mem;
    logic                     opcode_mov_cr_from_reg;
    logic                     opcode_mov_reg_from_cr;
    logic                     opcode_mov_dr_from_reg;
    logic                     opcode_mov_reg_from_dr;
    logic                     opcode_mov_tr_from_reg;
    logic                     opcode_mov_reg_from_tr;
    logic                     opcode_mov_reg_mem_to_sreg;
    logic                     opcode_mov_sreg_to_reg_mem;
    logic                     opcode_movbe_mem_reg;
    logic                     opcode_movbe_reg_mem;
    logic                     opcode_movs;
    logic                     opcode_movsx;
    logic                     opcode_movzx;
    logic                     opcode_mul;
    logic                     opcode_neg;
    logic                     opcode_nop;
    logic                     opcode_nop_multibyte;
    logic                     opcode_not;
    logic                     opcode_or_reg_to_reg_mem;
    logic                     opcode_or_reg_mem_to_reg;
    logic                     opcode_or_imm_to_reg_mem;
    logic                     opcode_or_imm_to_acc;
    logic                     opcode_out_fixed;
    logic                     opcode_out_var;
    logic                     opcode_outs;
    logic                     opcode_pop_reg_mem;
    logic                     opcode_pop_reg;
    logic                     opcode_pop_sreg_2;
    logic                     opcode_pop_sreg_3;
    logic                     opcode_popa;
    logic                     opcode_popf;
    logic                     opcode_push_reg_mem;
    logic                     opcode_push_reg;
    logic                     opcode_push_sreg_2;
    logic                     opcode_push_sreg_3;
    logic                     opcode_push_imm;
    logic                     opcode_pusha;
    logic                     opcode_pushf;
    logic                     opcode_rcl_1;
    logic                     opcode_rcl_cl;
    logic                     opcode_rcl_imm;
    logic                     opcode_rcr_1;
    logic                     opcode_rcr_cl;
    logic                     opcode_rcr_imm;
    logic                     opcode_rdmsr;
    logic                     opcode_rdpmc;
    logic                     opcode_rdtsc;
    logic                     opcode_rdtscp;
    logic                     opcode_ret_near;
    logic                     opcode_ret_near_imm;
    logic                     opcode_ret_far;
    logic                     opcode_ret_far_imm;
    logic                     opcode_rol_1;
    logic                     opcode_rol_cl;
    logic                     opcode_rol_imm;
    logic                     opcode_ror_1;
    logic                     opcode_ror_cl;
    logic                     opcode_ror_imm;
    logic                     opcode_rsm;
    logic                     opcode_sahf;
    logic                     opcode_sar_1;
    logic                     opcode_sar_cl;
    logic                     opcode_sar_imm;
    logic                     opcode_sbb_reg_to_reg_mem;
    logic                     opcode_sbb_reg_mem_to_reg;
    logic                     opcode_sbb_imm_to_reg_mem;
    logic                     opcode_sbb_imm_to_acc;
    logic                     opcode_scas;
    logic                     opcode_setcc;
    logic                     opcode_sgdt;
    logic                     opcode_shl_1;
    logic                     opcode_shl_cl;
    logic                     opcode_shl_imm;
    logic                     opcode_shld_imm;
    logic                     opcode_shld_cl;
    logic                     opcode_shr_1;
    logic                     opcode_shr_cl;
    logic                     opcode_shr_imm;
    logic                     opcode_shrd_imm;
    logic                     opcode_shrd_cl;
    logic                     opcode_sidt;
    logic                     opcode_sldt;
    logic                     opcode_smsw;
    logic                     opcode_stc;
    logic                     opcode_std;
    logic                     opcode_sti;
    logic                     opcode_stos;
    logic                     opcode_str;
    logic                     opcode_sub_reg_to_reg_mem;
    logic                     opcode_sub_reg_mem_to_reg;
    logic                     opcode_sub_imm_to_reg_mem;
    logic                     opcode_sub_imm_to_acc;
    logic                     opcode_test_reg_mem;
    logic                     opcode_test_imm_reg_mem;
    logic                     opcode_test_imm_acc;
    logic                     opcode_ud0;
    logic                     opcode_ud1;
    logic                     opcode_ud2;
    logic                     opcode_verr;
    logic                     opcode_verw;
    logic                     opcode_wait;
    logic                     opcode_wbinvd;
    logic                     opcode_wrmsr;
    logic                     opcode_xadd;
    logic                     opcode_xchg_reg_mem;
    logic                     opcode_xchg_acc;
    logic                     opcode_xlat;
    logic                     opcode_xor_reg_to_reg_mem;
    logic                     opcode_xor_reg_mem_to_reg;
    logic                     opcode_xor_imm_to_reg_mem;
    logic                     opcode_xor_imm_to_acc;
    logic                     opcode_x87_esc;

    // ============================================================
    // Operand module outputs
    // ============================================================
    logic [ 3: 0]             operand_tttn;
    logic [ 2: 0]             operand_eee;
    logic                     operand_base_reg_valid;
    logic [ 2: 0]             operand_base_reg_index;
    logic                     operand_index_reg_valid;
    logic [ 2: 0]             operand_index_reg_index;
    logic [ 2: 0]             operand_seg_reg_index_addr;
    logic [ 1: 0]             operand_scale;
    logic [ 1: 0]             operand_mod;
    logic [31: 0]             operand_disp_value;
    logic [31: 0]             operand_imm_value;
    logic [ 3: 0]             operand_consume_byte_count;
    logic                     operand_decode_error;

    // ============================================================
    // Internal control signals
    // ============================================================
    logic [ 3: 0]             prefix_byte_count;
    logic [ 3: 0]             opcode_byte_count;
    logic [ 3: 0]             total_byte_count;
    logic                     can_start_decode;
    logic                     pipeline_stall;
    logic                     can_fire_to_uop;

    // ============================================================
    // Prefix byte count calculation
    // ============================================================
    always_comb begin
        unique case (1'b1)
            prefix_consume_bytes_prefix_1: prefix_byte_count = 4'd1;
            prefix_consume_bytes_prefix_2: prefix_byte_count = 4'd2;
            prefix_consume_bytes_prefix_3: prefix_byte_count = 4'd3;
            prefix_consume_bytes_prefix_4: prefix_byte_count = 4'd4;
            default:                     prefix_byte_count = 4'd0;
        endcase
    end

    // ============================================================
    // Opcode byte count (fixed to 1 for now)
    // ============================================================
    assign opcode_byte_count = 4'd1;

    // ============================================================
    // Total byte count calculation
    // ============================================================
    assign total_byte_count = stage1_prefix_bytes_r + opcode_byte_count + operand_consume_byte_count;

    // ============================================================
    // Control signals
    // ============================================================
    assign can_start_decode   = i_ifu_instruction_valid & ~stage1_valid_r & ~stage2_valid_r & ~stage3_valid_r;
    assign pipeline_stall      = ~i_uop_stage2_ready;
    assign can_fire_to_uop     = stage3_valid_r & i_uop_stage2_ready & ~i_uop_flush;

    // ============================================================
    // FSM next state logic
    // ============================================================
    always_comb begin
        state_n = state_r;
        stage1_valid_n = stage1_valid_r;
        stage2_valid_n = stage2_valid_r;
        stage3_valid_n = stage3_valid_r;
        stage1_error_n = stage1_error_r;
        stage2_error_n = stage2_error_r;
        stage3_error_n = stage3_error_r;
        stage1_prefix_bytes_n = stage1_prefix_bytes_r;
        stage2_prefix_bytes_n = stage2_prefix_bytes_r;
        stage2_opcode_bytes_n = stage2_opcode_bytes_r;
        stage2_group_3_operand_size_n = stage2_group_3_operand_size_r;
        stage2_group_4_address_size_n = stage2_group_4_address_size_r;
        stage3_total_bytes_n = stage3_total_bytes_r;

        if (i_uop_flush) begin
            state_n = LP_STATE_IDLE;
            stage1_valid_n = 1'b0;
            stage2_valid_n = 1'b0;
            stage3_valid_n = 1'b0;
            stage1_error_n = 1'b0;
            stage2_error_n = 1'b0;
            stage3_error_n = 1'b0;
        end else if (~pipeline_stall) begin
            unique case (state_r)
                LP_STATE_IDLE: begin
                    if (can_start_decode) begin
                        state_n = LP_STATE_DECODE_PREFIX;
                        stage1_valid_n = 1'b1;
                        stage1_prefix_bytes_n = prefix_byte_count;
                        stage1_error_n = prefix_error;
                    end
                end

                LP_STATE_DECODE_PREFIX: begin
                    state_n = LP_STATE_DECODE_OPCODE;
                    stage2_valid_n = 1'b1;
                    stage2_prefix_bytes_n = stage1_prefix_bytes_r;
                    stage2_opcode_bytes_n = opcode_byte_count;
                    stage2_group_3_operand_size_n = stage1_group_3_operand_size_r;
                    stage2_group_4_address_size_n = stage1_group_4_address_size_r;
                    stage2_error_n = stage1_error_r;
                    stage1_valid_n = 1'b0;
                end

                LP_STATE_DECODE_OPCODE: begin
                    state_n = LP_STATE_DECODE_OPERAND;
                    stage3_valid_n = 1'b1;
                    stage3_total_bytes_n = total_byte_count;
                    stage3_error_n = stage2_error_r | operand_decode_error;
                    stage2_valid_n = 1'b0;
                end

                LP_STATE_DECODE_OPERAND: begin
                    state_n = LP_STATE_READY;
                end

                LP_STATE_READY: begin
                    if (can_fire_to_uop) begin
                        state_n = LP_STATE_IDLE;
                        stage3_valid_n = 1'b0;
                    end
                end

                default: begin
                    state_n = LP_STATE_IDLE;
                end
            endcase
        end
    end

    // ============================================================
    // Pipeline register updates
    // ============================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state_r                       <= LP_STATE_IDLE;
            stage1_valid_r               <= 1'b0;
            stage2_valid_r               <= 1'b0;
            stage3_valid_r               <= 1'b0;
            stage1_error_r               <= 1'b0;
            stage2_error_r               <= 1'b0;
            stage3_error_r               <= 1'b0;
            stage1_prefix_bytes_r         <= 4'd0;
            stage2_prefix_bytes_r         <= 4'd0;
            stage2_opcode_bytes_r         <= 4'd0;
            stage2_group_3_operand_size_r <= 1'b0;
            stage2_group_4_address_size_r <= 1'b0;
            stage3_total_bytes_r          <= 4'd0;
            stage1_group_3_operand_size_r <= 1'b0;
            stage1_group_4_address_size_r <= 1'b0;
        end else begin
            state_r                       <= state_n;
            stage1_valid_r               <= stage1_valid_n;
            stage2_valid_r               <= stage2_valid_n;
            stage3_valid_r               <= stage3_valid_n;
            stage1_error_r               <= stage1_error_n;
            stage2_error_r               <= stage2_error_n;
            stage3_error_r               <= stage3_error_n;
            stage1_prefix_bytes_r         <= stage1_prefix_bytes_n;
            stage2_prefix_bytes_r         <= stage2_prefix_bytes_n;
            stage2_opcode_bytes_r         <= stage2_opcode_bytes_n;
            stage2_group_3_operand_size_r <= stage2_group_3_operand_size_n;
            stage2_group_4_address_size_r <= stage2_group_4_address_size_n;
            stage3_total_bytes_r          <= stage3_total_bytes_n;
            stage1_group_3_operand_size_r <= stage1_group_3_operand_size_n;
            stage1_group_4_address_size_r <= stage1_group_4_address_size_n;
        end
    end

    // ============================================================
    // Prefix module outputs to stage 1 registers
    // ============================================================
    always_comb begin
        stage1_group_3_operand_size_n = prefix_group_3_operand_size;
        stage1_group_4_address_size_n = prefix_group_4_address_size;
    end

    // ============================================================
    // IFU handshake outputs
    // ============================================================
    assign o_ifu_dec_ready             = (state_r == LP_STATE_IDLE);
    assign o_ifu_dec_fire              = can_fire_to_uop;
    assign o_ifu_dec_consume_bytes     = stage3_total_bytes_r;
    assign o_ifu_dec_error             = stage3_error_r;

    // ============================================================
    // UOP handshake outputs
    // ============================================================
    assign o_uop_stage2_valid          = (state_r == LP_STATE_READY);

    // ============================================================
    // Opcode outputs to UOP stage
    // ============================================================
    assign o_opcode_aaa                = opcode_aaa;
    assign o_opcode_aad                = opcode_aad;
    assign o_opcode_aam                = opcode_aam;
    assign o_opcode_aas                = opcode_aas;
    assign o_opcode_adc_reg_to_reg_mem = opcode_adc_reg_to_reg_mem;
    assign o_opcode_adc_reg_mem_to_reg = opcode_adc_reg_mem_to_reg;
    assign o_opcode_adc_imm_to_reg_mem = opcode_adc_imm_to_reg_mem;
    assign o_opcode_adc_imm_to_acc     = opcode_adc_imm_to_acc;
    assign o_opcode_add_reg_to_reg_mem = opcode_add_reg_to_reg_mem;
    assign o_opcode_add_reg_mem_to_reg = opcode_add_reg_mem_to_reg;
    assign o_opcode_add_imm_to_reg_mem = opcode_add_imm_to_reg_mem;
    assign o_opcode_add_imm_to_acc     = opcode_add_imm_to_acc;
    assign o_opcode_and_reg_to_reg_mem = opcode_and_reg_to_reg_mem;
    assign o_opcode_and_reg_mem_to_reg = opcode_and_reg_mem_to_reg;
    assign o_opcode_and_imm_to_reg_mem = opcode_and_imm_to_reg_mem;
    assign o_opcode_and_imm_to_acc     = opcode_and_imm_to_acc;
    assign o_opcode_arpl               = opcode_arpl;
    assign o_opcode_bound              = opcode_bound;
    assign o_opcode_bsf                = opcode_bsf;
    assign o_opcode_bsr                = opcode_bsr;
    assign o_opcode_bswap              = opcode_bswap;
    assign o_opcode_bt_imm             = opcode_bt_imm;
    assign o_opcode_bt_reg             = opcode_bt_reg;
    assign o_opcode_btc_imm            = opcode_btc_imm;
    assign o_opcode_btc_reg            = opcode_btc_reg;
    assign o_opcode_btr_imm            = opcode_btr_imm;
    assign o_opcode_btr_reg            = opcode_btr_reg;
    assign o_opcode_bts_imm            = opcode_bts_imm;
    assign o_opcode_bts_reg            = opcode_bts_reg;
    assign o_opcode_call_near_direct   = opcode_call_near_direct;
    assign o_opcode_call_near_indirect  = opcode_call_near_indirect;
    assign o_opcode_call_far_direct    = opcode_call_far_direct;
    assign o_opcode_call_far_indirect   = opcode_call_far_indirect;
    assign o_opcode_cbw                = opcode_cbw;
    assign o_opcode_cdq                = opcode_cdq;
    assign o_opcode_clc                = opcode_clc;
    assign o_opcode_cld                = opcode_cld;
    assign o_opcode_cli                = opcode_cli;
    assign o_opcode_clts               = opcode_clts;
    assign o_opcode_cmc                = opcode_cmc;
    assign o_opcode_cmp_mem_reg        = opcode_cmp_mem_reg;
    assign o_opcode_cmp_reg_mem        = opcode_cmp_reg_mem;
    assign o_opcode_cmp_imm_reg_mem    = opcode_cmp_imm_reg_mem;
    assign o_opcode_cmp_imm_acc        = opcode_cmp_imm_acc;
    assign o_opcode_cmps               = opcode_cmps;
    assign o_opcode_cmpxchg            = opcode_cmpxchg;
    assign o_opcode_cpuid              = opcode_cpuid;
    assign o_opcode_cwd                = opcode_cwd;
    assign o_opcode_cwde               = opcode_cwde;
    assign o_opcode_daa                = opcode_daa;
    assign o_opcode_das                = opcode_das;
    assign o_opcode_dec_reg_mem        = opcode_dec_reg_mem;
    assign o_opcode_dec_reg            = opcode_dec_reg;
    assign o_opcode_div                = opcode_div;
    assign o_opcode_hlt                = opcode_hlt;
    assign o_opcode_idiv               = opcode_idiv;
    assign o_opcode_imul_acc           = opcode_imul_acc;
    assign o_opcode_imul_reg           = opcode_imul_reg;
    assign o_opcode_imul_imm           = opcode_imul_imm;
    assign o_opcode_in_fixed           = opcode_in_fixed;
    assign o_opcode_in_var             = opcode_in_var;
    assign o_opcode_inc_reg_mem        = opcode_inc_reg_mem;
    assign o_opcode_inc_reg            = opcode_inc_reg;
    assign o_opcode_ins                = opcode_ins;
    assign o_opcode_int_n              = opcode_int_n;
    assign o_opcode_int_3              = opcode_int_3;
    assign o_opcode_int_4              = opcode_int_4;
    assign o_opcode_invd               = opcode_invd;
    assign o_opcode_invlpg             = opcode_invlpg;
    assign o_opcode_invpcid            = opcode_invpcid;
    assign o_opcode_iret               = opcode_iret;
    assign o_opcode_jcc_short          = opcode_jcc_short;
    assign o_opcode_jcc_near           = opcode_jcc_near;
    assign o_opcode_jcxz               = opcode_jcxz;
    assign o_opcode_jmp_short          = opcode_jmp_short;
    assign o_opcode_jmp_near_direct    = opcode_jmp_near_direct;
    assign o_opcode_jmp_near_indirect   = opcode_jmp_near_indirect;
    assign o_opcode_jmp_far_direct     = opcode_jmp_far_direct;
    assign o_opcode_jmp_far_indirect    = opcode_jmp_far_indirect;
    assign o_opcode_lahf               = opcode_lahf;
    assign o_opcode_lar                = opcode_lar;
    assign o_opcode_lds                = opcode_lds;
    assign o_opcode_lea                = opcode_lea;
    assign o_opcode_leave              = opcode_leave;
    assign o_opcode_les                = opcode_les;
    assign o_opcode_lfs                = opcode_lfs;
    assign o_opcode_lgdt               = opcode_lgdt;
    assign o_opcode_lgs                = opcode_lgs;
    assign o_opcode_lidt               = opcode_lidt;
    assign o_opcode_lldt               = opcode_lldt;
    assign o_opcode_lmsw               = opcode_lmsw;
    assign o_opcode_lods               = opcode_lods;
    assign o_opcode_loop               = opcode_loop;
    assign o_opcode_loopz              = opcode_loopz;
    assign o_opcode_loopnz             = opcode_loopnz;
    assign o_opcode_lsl                = opcode_lsl;
    assign o_opcode_lss                = opcode_lss;
    assign o_opcode_ltr                = opcode_ltr;
    assign o_opcode_mov_reg_to_reg_mem = opcode_mov_reg_to_reg_mem;
    assign o_opcode_mov_reg_mem_to_reg = opcode_mov_reg_mem_to_reg;
    assign o_opcode_mov_imm_to_reg_mem = opcode_mov_imm_to_reg_mem;
    assign o_opcode_mov_imm_to_reg     = opcode_mov_imm_to_reg;
    assign o_opcode_mov_mem_to_acc     = opcode_mov_mem_to_acc;
    assign o_opcode_mov_acc_to_mem     = opcode_mov_acc_to_mem;
    assign o_opcode_mov_cr_from_reg    = opcode_mov_cr_from_reg;
    assign o_opcode_mov_reg_from_cr    = opcode_mov_reg_from_cr;
    assign o_opcode_mov_dr_from_reg    = opcode_mov_dr_from_reg;
    assign o_opcode_mov_reg_from_dr    = opcode_mov_reg_from_dr;
    assign o_opcode_mov_tr_from_reg    = opcode_mov_tr_from_reg;
    assign o_opcode_mov_reg_from_tr    = opcode_mov_reg_from_tr;
    assign o_opcode_mov_reg_mem_to_sreg = opcode_mov_reg_mem_to_sreg;
    assign o_opcode_mov_sreg_to_reg_mem = opcode_mov_sreg_to_reg_mem;
    assign o_opcode_movbe_mem_reg      = opcode_movbe_mem_reg;
    assign o_opcode_movbe_reg_mem      = opcode_movbe_reg_mem;
    assign o_opcode_movs               = opcode_movs;
    assign o_opcode_movsx              = opcode_movsx;
    assign o_opcode_movzx              = opcode_movzx;
    assign o_opcode_mul                = opcode_mul;
    assign o_opcode_neg                = opcode_neg;
    assign o_opcode_nop                = opcode_nop;
    assign o_opcode_nop_multibyte      = opcode_nop_multibyte;
    assign o_opcode_not                = opcode_not;
    assign o_opcode_or_reg_to_reg_mem  = opcode_or_reg_to_reg_mem;
    assign o_opcode_or_reg_mem_to_reg  = opcode_or_reg_mem_to_reg;
    assign o_opcode_or_imm_to_reg_mem  = opcode_or_imm_to_reg_mem;
    assign o_opcode_or_imm_to_acc      = opcode_or_imm_to_acc;
    assign o_opcode_out_fixed          = opcode_out_fixed;
    assign o_opcode_out_var            = opcode_out_var;
    assign o_opcode_outs               = opcode_outs;
    assign o_opcode_pop_reg_mem        = opcode_pop_reg_mem;
    assign o_opcode_pop_reg            = opcode_pop_reg;
    assign o_opcode_pop_sreg_2         = opcode_pop_sreg_2;
    assign o_opcode_pop_sreg_3         = opcode_pop_sreg_3;
    assign o_opcode_popa               = opcode_popa;
    assign o_opcode_popf               = opcode_popf;
    assign o_opcode_push_reg_mem       = opcode_push_reg_mem;
    assign o_opcode_push_reg           = opcode_push_reg;
    assign o_opcode_push_sreg_2        = opcode_push_sreg_2;
    assign o_opcode_push_sreg_3        = opcode_push_sreg_3;
    assign o_opcode_push_imm           = opcode_push_imm;
    assign o_opcode_pusha              = opcode_pusha;
    assign o_opcode_pushf              = opcode_pushf;
    assign o_opcode_rcl_1              = opcode_rcl_1;
    assign o_opcode_rcl_cl             = opcode_rcl_cl;
    assign o_opcode_rcl_imm            = opcode_rcl_imm;
    assign o_opcode_rcr_1              = opcode_rcr_1;
    assign o_opcode_rcr_cl             = opcode_rcr_cl;
    assign o_opcode_rcr_imm            = opcode_rcr_imm;
    assign o_opcode_rdmsr             = opcode_rdmsr;
    assign o_opcode_rdpmc             = opcode_rdpmc;
    assign o_opcode_rdtsc             = opcode_rdtsc;
    assign o_opcode_rdtscp            = opcode_rdtscp;
    assign o_opcode_ret_near           = opcode_ret_near;
    assign o_opcode_ret_near_imm      = opcode_ret_near_imm;
    assign o_opcode_ret_far            = opcode_ret_far;
    assign o_opcode_ret_far_imm       = opcode_ret_far_imm;
    assign o_opcode_rol_1              = opcode_rol_1;
    assign o_opcode_rol_cl             = opcode_rol_cl;
    assign o_opcode_rol_imm            = opcode_rol_imm;
    assign o_opcode_ror_1              = opcode_ror_1;
    assign o_opcode_ror_cl             = opcode_ror_cl;
    assign o_opcode_ror_imm            = opcode_ror_imm;
    assign o_opcode_rsm                = opcode_rsm;
    assign o_opcode_sahf               = opcode_sahf;
    assign o_opcode_sar_1              = opcode_sar_1;
    assign o_opcode_sar_cl             = opcode_sar_cl;
    assign o_opcode_sar_imm            = opcode_sar_imm;
    assign o_opcode_sbb_reg_to_reg_mem = opcode_sbb_reg_to_reg_mem;
    assign o_opcode_sbb_reg_mem_to_reg = opcode_sbb_reg_mem_to_reg;
    assign o_opcode_sbb_imm_to_reg_mem = opcode_sbb_imm_to_reg_mem;
    assign o_opcode_sbb_imm_to_acc     = opcode_sbb_imm_to_acc;
    assign o_opcode_scas               = opcode_scas;
    assign o_opcode_setcc              = opcode_setcc;
    assign o_opcode_sgdt               = opcode_sgdt;
    assign o_opcode_shl_1              = opcode_shl_1;
    assign o_opcode_shl_cl             = opcode_shl_cl;
    assign o_opcode_shl_imm            = opcode_shl_imm;
    assign o_opcode_shld_imm           = opcode_shld_imm;
    assign o_opcode_shld_cl            = opcode_shld_cl;
    assign o_opcode_shr_1              = opcode_shr_1;
    assign o_opcode_shr_cl             = opcode_shr_cl;
    assign o_opcode_shr_imm            = opcode_shr_imm;
    assign o_opcode_shrd_imm           = opcode_shrd_imm;
    assign o_opcode_shrd_cl            = opcode_shrd_cl;
    assign o_opcode_sidt               = opcode_sidt;
    assign o_opcode_sldt               = opcode_sldt;
    assign o_opcode_smsw               = opcode_smsw;
    assign o_opcode_stc                = opcode_stc;
    assign o_opcode_std                = opcode_std;
    assign o_opcode_sti                = opcode_sti;
    assign o_opcode_stos               = opcode_stos;
    assign o_opcode_str                = opcode_str;
    assign o_opcode_sub_reg_to_reg_mem = opcode_sub_reg_to_reg_mem;
    assign o_opcode_sub_reg_mem_to_reg = opcode_sub_reg_mem_to_reg;
    assign o_opcode_sub_imm_to_reg_mem = opcode_sub_imm_to_reg_mem;
    assign o_opcode_sub_imm_to_acc     = opcode_sub_imm_to_acc;
    assign o_opcode_test_reg_mem       = opcode_test_reg_mem;
    assign o_opcode_test_imm_reg_mem   = opcode_test_imm_reg_mem;
    assign o_opcode_test_imm_acc       = opcode_test_imm_acc;
    assign o_opcode_ud0                = opcode_ud0;
    assign o_opcode_ud1                = opcode_ud1;
    assign o_opcode_ud2                = opcode_ud2;
    assign o_opcode_verr               = opcode_verr;
    assign o_opcode_verw               = opcode_verw;
    assign o_opcode_wait               = opcode_wait;
    assign o_opcode_wbinvd             = opcode_wbinvd;
    assign o_opcode_wrmsr              = opcode_wrmsr;
    assign o_opcode_xadd               = opcode_xadd;
    assign o_opcode_xchg_reg_mem       = opcode_xchg_reg_mem;
    assign o_opcode_xchg_acc           = opcode_xchg_acc;
    assign o_opcode_xlat               = opcode_xlat;
    assign o_opcode_xor_reg_to_reg_mem = opcode_xor_reg_to_reg_mem;
    assign o_opcode_xor_reg_mem_to_reg = opcode_xor_reg_mem_to_reg;
    assign o_opcode_xor_imm_to_reg_mem = opcode_xor_imm_to_reg_mem;
    assign o_opcode_xor_imm_to_acc     = opcode_xor_imm_to_acc;
    assign o_opcode_x87_esc            = opcode_x87_esc;
    assign o_tttn                      = operand_tttn;
    assign o_eee                       = operand_eee;

    // ============================================================
    // Operand outputs to UOP stage
    // ============================================================
    assign o_dec_displacement          = operand_disp_value;
    assign o_dec_immediate             = operand_imm_value;
    assign o_dec_base_reg_is_present   = operand_base_reg_valid;
    assign o_dec_base_reg_index        = operand_base_reg_index;
    assign o_dec_index_reg_is_present  = operand_index_reg_valid;
    assign o_dec_index_reg_index       = operand_index_reg_index;
    assign o_dec_segment_reg_index     = operand_seg_reg_index_addr;
    assign o_dec_sib_scale_factor      = operand_scale;
    assign o_dec_modrm_mod             = operand_mod;

    // ============================================================
    // Prefix module instantiation (bytes[0:3])
    // ============================================================
    stage_2_dec_x86_prefix u_prefix (
        .i_instruction                (i_ifu_instruction[0]),
        .o_group_1_lock_bus           (prefix_group_1_lock_bus),
        .o_group_1_repeat_not_equal   (prefix_group_1_repeat_not_equal),
        .o_group_1_repeat_equal       (prefix_group_1_repeat_equal),
        .o_group_1_bound              (prefix_group_1_bound),
        .o_group_2_segment_override   (prefix_group_2_segment_override),
        .o_group_2_hint_branch_not_taken (prefix_group_2_hint_branch_not_taken),
        .o_group_2_hint_branch_taken  (prefix_group_2_hint_branch_taken),
        .o_group_3_operand_size       (prefix_group_3_operand_size),
        .o_group_4_address_size       (prefix_group_4_address_size),
        .o_group_1_is_present         (prefix_group_1_is_present),
        .o_group_2_is_present         (prefix_group_2_is_present),
        .o_group_3_is_present         (prefix_group_3_is_present),
        .o_group_4_is_present         (prefix_group_4_is_present),
        .o_segment_override_index     (prefix_segment_override_index),
        .o_consume_bytes_prefix_1     (prefix_consume_bytes_prefix_1),
        .o_consume_bytes_prefix_2     (prefix_consume_bytes_prefix_2),
        .o_consume_bytes_prefix_3     (prefix_consume_bytes_prefix_3),
        .o_consume_bytes_prefix_4     (prefix_consume_bytes_prefix_4),
        .o_error                      (prefix_error)
    );

    // ============================================================
    // Opcode module instantiation (bytes[prefix_count:prefix_count+3])
    // ============================================================
    logic [ 3: 0][ 7: 0] opcode_instruction_bytes;
    always_comb begin
        unique case (stage1_prefix_bytes_r)
            4'd0: opcode_instruction_bytes = i_ifu_instruction[0];
            4'd1: opcode_instruction_bytes = i_ifu_instruction[1];
            4'd2: opcode_instruction_bytes = i_ifu_instruction[2];
            4'd3: opcode_instruction_bytes = i_ifu_instruction[3];
            4'd4: opcode_instruction_bytes = i_ifu_instruction[4];
            default: opcode_instruction_bytes = i_ifu_instruction[0];
        endcase
    end

    /* verilator lint_off PINMISSING */
    stage_2_dec_x86_opcode u_opcode (
        .o_opcode_x86_AAA_ASCII_adjust_after_add       (opcode_aaa),
        .o_opcode_x86_AAD_ASCII_AX_before_div         (opcode_aad),
        .o_opcode_x86_AAM_ASCII_AX_after_mul          (opcode_aam),
        .o_opcode_x86_AAS_ASCII_adjust_after_sub      (opcode_aas),
        .o_opcode_x86_ADC_reg_to_reg_mem              (opcode_adc_reg_to_reg_mem),
        .o_opcode_x86_ADC_reg_mem_to_reg              (opcode_adc_reg_mem_to_reg),
        .o_opcode_x86_ADC_imm_to_reg_mem              (opcode_adc_imm_to_reg_mem),
        .o_opcode_x86_ADC_imm_to_acc                  (opcode_adc_imm_to_acc),
        .o_opcode_x86_ADD_reg_to_reg_mem              (opcode_add_reg_to_reg_mem),
        .o_opcode_x86_ADD_reg_mem_to_reg              (opcode_add_reg_mem_to_reg),
        .o_opcode_x86_ADD_imm_to_reg_mem              (opcode_add_imm_to_reg_mem),
        .o_opcode_x86_ADD_imm_to_acc                  (opcode_add_imm_to_acc),
        .o_opcode_x86_AND_reg_to_reg_mem              (opcode_and_reg_to_reg_mem),
        .o_opcode_x86_AND_reg_mem_to_reg              (opcode_and_reg_mem_to_reg),
        .o_opcode_x86_AND_imm_to_reg_mem              (opcode_and_imm_to_reg_mem),
        .o_opcode_x86_AND_imm_to_acc                  (opcode_and_imm_to_acc),
        .o_opcode_x86_ARPL_adjust_RPL_field_of_selector (opcode_arpl),
        .o_opcode_x86_BOUND_check_array_against_bounds (opcode_bound),
        .o_opcode_x86_BSF_bit_scan_forward            (opcode_bsf),
        .o_opcode_x86_BSR_bit_scan_reverse            (opcode_bsr),
        .o_opcode_x86_BSWAP_byte_swap                 (opcode_bswap),
        .o_opcode_x86_BT_reg_mem_with_imm             (opcode_bt_imm),
        .o_opcode_x86_BT_reg_mem_with_reg             (opcode_bt_reg),
        .o_opcode_x86_BTC_reg_mem_with_imm            (opcode_btc_imm),
        .o_opcode_x86_BTC_reg_mem_with_reg            (opcode_btc_reg),
        .o_opcode_x86_BTR_reg_mem_with_imm            (opcode_btr_imm),
        .o_opcode_x86_BTR_reg_mem_with_reg            (opcode_btr_reg),
        .o_opcode_x86_BTS_reg_mem_with_imm            (opcode_bts_imm),
        .o_opcode_x86_BTS_reg_mem_with_reg            (opcode_bts_reg),
        .o_opcode_x86_CALL_in_same_segment_direct     (opcode_call_near_direct),
        .o_opcode_x86_CALL_in_same_segment_indirect    (opcode_call_near_indirect),
        .o_opcode_x86_CALL_in_other_segment_direct     (opcode_call_far_direct),
        .o_opcode_x86_CALL_in_other_segment_indirect    (opcode_call_far_indirect),
        .o_opcode_x86_CBW_convert_byte_to_word         (opcode_cbw),
        .o_opcode_x86_CDQ_convert_double_word_to_quad_word (opcode_cdq),
        .o_opcode_x86_CLC_carry             (opcode_clc),
        .o_opcode_x86_CLD_dir         (opcode_cld),
        .o_opcode_x86_CLI_int_en  (opcode_cli),
        .o_opcode_x86_CLTS_clear_task_switched_flag     (opcode_clts),
        .o_opcode_x86_CMC_carry         (opcode_cmc),
        .o_opcode_x86_CMP_mem_with_reg                  (opcode_cmp_mem_reg),
        .o_opcode_x86_CMP_reg_with_mem                  (opcode_cmp_reg_mem),
        .o_opcode_x86_CMP_imm_with_reg_mem             (opcode_cmp_imm_reg_mem),
        .o_opcode_x86_CMP_imm_with_acc                  (opcode_cmp_imm_acc),
        .o_opcode_x86_CMPS_compare_string_operands      (opcode_cmps),
        .o_opcode_x86_CMPXCHG_compare_and_exchange      (opcode_cmpxchg),
        .o_opcode_x86_CPUID_CPU_identification          (opcode_cpuid),
        .o_opcode_x86_CWD_convert_word_to_double        (opcode_cwd),
        .o_opcode_x86_CWDE_convert_word_to_double        (opcode_cwde),
        .o_opcode_x86_DAA_decimal_adjust_AL_after_add   (opcode_daa),
        .o_opcode_x86_DAS_decimal_adjust_AL_after_sub   (opcode_das),
        .o_opcode_x86_DEC_reg_mem                       (opcode_dec_reg_mem),
        .o_opcode_x86_DEC_reg                           (opcode_dec_reg),
        .o_opcode_x86_DIV_acc_by_reg_mem                (opcode_div),
        .o_opcode_x86_HLT_halt                          (opcode_hlt),
        .o_opcode_x86_IDIV_acc_by_reg_mem               (opcode_idiv),
        .o_opcode_x86_IMUL_acc_with_reg_mem             (opcode_imul_acc),
        .o_opcode_x86_IMUL_reg_with_reg_mem             (opcode_imul_reg),
        .o_opcode_x86_IMUL_reg_mem_with_imm_to_reg      (opcode_imul_imm),
        .o_opcode_x86_IN_port_fixed                     (opcode_in_fixed),
        .o_opcode_x86_IN_port_variable                  (opcode_in_var),
        .o_opcode_x86_INC_reg_mem                       (opcode_inc_reg_mem),
        .o_opcode_x86_INC_reg                           (opcode_inc_reg),
        .o_opcode_x86_INS_input_from_DX_port            (opcode_ins),
        .o_opcode_x86_INT_interrupt_type_n              (opcode_int_n),
        .o_opcode_x86_INT_interrupt_type_3              (opcode_int_3),
        .o_opcode_x86_INT_interrupt_type_4              (opcode_int_4),
        .o_opcode_x86_INVD_invalidate_cache              (opcode_invd),
        .o_opcode_x86_INVLPG_invalidate_TLB_entry         (opcode_invlpg),
        .o_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size (opcode_invpcid),
        .o_opcode_x86_IRET_interrupt_return             (opcode_iret),
        .o_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp (opcode_jcc_short),
        .o_opcode_x86_Jcc_jump_if_cond_is_met_full_disp (opcode_jcc_near),
        .o_opcode_x86_JCXZ_jump_on_CX_zero               (opcode_jcxz),
        .o_opcode_x86_JMP_to_same_segment_short          (opcode_jmp_short),
        .o_opcode_x86_JMP_to_same_segment_direct         (opcode_jmp_near_direct),
        .o_opcode_x86_JMP_to_same_segment_indirect        (opcode_jmp_near_indirect),
        .o_opcode_x86_JMP_to_other_segment_direct        (opcode_jmp_far_direct),
        .o_opcode_x86_JMP_to_other_segment_indirect       (opcode_jmp_far_indirect),
        .o_opcode_x86_LAHF_load_FLAG_into_AH             (opcode_lahf),
        .o_opcode_x86_LAR_load_access_rights_byte        (opcode_lar),
        .o_opcode_x86_LDS_load_pointer_to_DS              (opcode_lds),
        .o_opcode_x86_LEA_load_effective_adddress_to_reg (opcode_lea),
        .o_opcode_x86_LEAVE_high_level_procedure_exit    (opcode_leave),
        .o_opcode_x86_LES_load_pointer_to_ES              (opcode_les),
        .o_opcode_x86_LFS_load_pointer_to_FS              (opcode_lfs),
        .o_opcode_x86_LGDT_load_global_desciptor_table_reg (opcode_lgdt),
        .o_opcode_x86_LGS_load_pointer_to_GS              (opcode_lgs),
        .o_opcode_x86_LIDT_load_interrupt_desciptor_table_reg (opcode_lidt),
        .o_opcode_x86_LLDT_load_local_desciptor_table_reg (opcode_lldt),
        .o_opcode_x86_LMSW_load_status_word              (opcode_lmsw),
        .o_opcode_x86_LODS_load_string_operand           (opcode_lods),
        .o_opcode_x86_LOOP_count                         (opcode_loop),
        .o_opcode_x86_LOOPZ_count_while_zero              (opcode_loopz),
        .o_opcode_x86_LOOPNZ_count_while_not_zero         (opcode_loopnz),
        .o_opcode_x86_LSL_load_segment_limit             (opcode_lsl),
        .o_opcode_x86_LSS_load_pointer_to_SS              (opcode_lss),
        .o_opcode_x86_LTR_load_task_register             (opcode_ltr),
        .o_opcode_x86_MOV_reg_to_reg_mem                  (opcode_mov_reg_to_reg_mem),
        .o_opcode_x86_MOV_reg_mem_to_reg                  (opcode_mov_reg_mem_to_reg),
        .o_opcode_x86_MOV_imm_to_reg_mem                  (opcode_mov_imm_to_reg_mem),
        .o_opcode_x86_MOV_imm_to_reg                      (opcode_mov_imm_to_reg),
        .o_opcode_x86_MOV_mem_to_acc                      (opcode_mov_mem_to_acc),
        .o_opcode_x86_MOV_acc_to_mem                      (opcode_mov_acc_to_mem),
        .o_opcode_x86_MOV_CR_from_reg                     (opcode_mov_cr_from_reg),
        .o_opcode_x86_MOV_reg_from_CR                     (opcode_mov_reg_from_cr),
        .o_opcode_x86_MOV_DR_from_reg                     (opcode_mov_dr_from_reg),
        .o_opcode_x86_MOV_reg_from_DR                     (opcode_mov_reg_from_dr),
        .o_opcode_x86_MOV_TR_from_reg                     (opcode_mov_tr_from_reg),
        .o_opcode_x86_MOV_reg_from_TR                     (opcode_mov_reg_from_tr),
        .o_opcode_x86_MOV_reg_mem_to_sreg                 (opcode_mov_reg_mem_to_sreg),
        .o_opcode_x86_MOV_sreg_to_reg_mem                 (opcode_mov_sreg_to_reg_mem),
        .o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg (opcode_movbe_mem_reg),
        .o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem (opcode_movbe_reg_mem),
        .o_opcode_x86_MOVS_move_data_from_string_to_string (opcode_movs),
        .o_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg (opcode_movsx),
        .o_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg (opcode_movzx),
        .o_opcode_x86_MUL_acc_with_reg_mem                (opcode_mul),
        .o_opcode_x86_NEG_two_s_complement_negation        (opcode_neg),
        .o_opcode_x86_NOP_no_operation                    (opcode_nop),
        .o_opcode_x86_NOP_no_operation_multi_byte         (opcode_nop_multibyte),
        .o_opcode_x86_NOT_one_s_complement_negation        (opcode_not),
        .o_opcode_x86_OR_reg_to_reg_mem                   (opcode_or_reg_to_reg_mem),
        .o_opcode_x86_OR_reg_mem_to_reg                   (opcode_or_reg_mem_to_reg),
        .o_opcode_x86_OR_imm_to_reg_mem                   (opcode_or_imm_to_reg_mem),
        .o_opcode_x86_OR_imm_to_acc                       (opcode_or_imm_to_acc),
        .o_opcode_x86_OUT_port_fixed                      (opcode_out_fixed),
        .o_opcode_x86_OUT_port_variable                   (opcode_out_var),
        .o_opcode_x86_OUTS_output_to_DX_port               (opcode_outs),
        .o_opcode_x86_POP_reg_mem                         (opcode_pop_reg_mem),
        .o_opcode_x86_POP_reg                             (opcode_pop_reg),
        .o_opcode_x86_POP_sreg_2                          (opcode_pop_sreg_2),
        .o_opcode_x86_POP_sreg_3                          (opcode_pop_sreg_3),
        .o_opcode_x86_POPA_pop_all_registers               (opcode_popa),
        .o_opcode_x86_POPF_pop_flags                       (opcode_popf),
        .o_opcode_x86_PUSH_reg_mem                        (opcode_push_reg_mem),
        .o_opcode_x86_PUSH_reg                            (opcode_push_reg),
        .o_opcode_x86_PUSH_sreg_2                         (opcode_push_sreg_2),
        .o_opcode_x86_PUSH_sreg_3                         (opcode_push_sreg_3),
        .o_opcode_x86_PUSH_imm                            (opcode_push_imm),
        .o_opcode_x86_PUSHA_push_all_registers             (opcode_pusha),
        .o_opcode_x86_PUSHF_push_flags                    (opcode_pushf),
        .o_opcode_x86_RCL_rotate_through_carry_left_1      (opcode_rcl_1),
        .o_opcode_x86_RCL_rotate_through_carry_left_CL     (opcode_rcl_cl),
        .o_opcode_x86_RCL_rotate_through_carry_left_imm    (opcode_rcl_imm),
        .o_opcode_x86_RCR_rotate_through_carry_right_1     (opcode_rcr_1),
        .o_opcode_x86_RCR_rotate_through_carry_right_CL    (opcode_rcr_cl),
        .o_opcode_x86_RCR_rotate_through_carry_right_imm   (opcode_rcr_imm),
        .o_opcode_x86_RDMSR_read_model_specific_register    (opcode_rdmsr),
        .o_opcode_x86_RDPMC_read_performance_monitor_counter (opcode_rdpmc),
        .o_opcode_x86_RDTSC_read_time_stamp_counter          (opcode_rdtsc),
        .o_opcode_x86_RDTSCP_read_time_stamp_counter_processor_id (opcode_rdtscp),
        .o_opcode_x86_RET_near_return_from_procedure         (opcode_ret_near),
        .o_opcode_x86_RET_near_return_with_immediate        (opcode_ret_near_imm),
        .o_opcode_x86_RET_far_return_from_procedure          (opcode_ret_far),
        .o_opcode_x86_RET_far_return_with_immediate         (opcode_ret_far_imm),
        .o_opcode_x86_ROL_rotate_left_1                     (opcode_rol_1),
        .o_opcode_x86_ROL_rotate_left_CL                    (opcode_rol_cl),
        .o_opcode_x86_ROL_rotate_left_imm                   (opcode_rol_imm),
        .o_opcode_x86_ROR_rotate_right_1                    (opcode_ror_1),
        .o_opcode_x86_ROR_rotate_right_CL                   (opcode_ror_cl),
        .o_opcode_x86_ROR_rotate_right_imm                  (opcode_ror_imm),
        .o_opcode_x86_RSM_resume_from_system_management_mode (opcode_rsm),
        .o_opcode_x86_SAHF_store_AH_into_flags              (opcode_sahf),
        .o_opcode_x86_SAR_shift_arithmetic_right_1           (opcode_sar_1),
        .o_opcode_x86_SAR_shift_arithmetic_right_CL          (opcode_sar_cl),
        .o_opcode_x86_SAR_shift_arithmetic_right_imm         (opcode_sar_imm),
        .o_opcode_x86_SBB_reg_to_reg_mem                     (opcode_sbb_reg_to_reg_mem),
        .o_opcode_x86_SBB_reg_mem_to_reg                     (opcode_sbb_reg_mem_to_reg),
        .o_opcode_x86_SBB_imm_to_reg_mem                     (opcode_sbb_imm_to_reg_mem),
        .o_opcode_x86_SBB_imm_to_acc                         (opcode_sbb_imm_to_acc),
        .o_opcode_x86_SCAS_compare_string_operand            (opcode_scas),
        .o_opcode_x86_SETCC_set_byte_on_condition            (opcode_setcc),
        .o_opcode_x86_SGDT_store_global_descriptor_table     (opcode_sgdt),
        .o_opcode_x86_SHL_shift_logical_left_1               (opcode_shl_1),
        .o_opcode_x86_SHL_shift_logical_left_CL              (opcode_shl_cl),
        .o_opcode_x86_SHL_shift_logical_left_imm             (opcode_shl_imm),
        .o_opcode_x86_SHLD_double_precision_shift_left_imm   (opcode_shld_imm),
        .o_opcode_x86_SHLD_double_precision_shift_left_CL    (opcode_shld_cl),
        .o_opcode_x86_SHR_shift_logical_right_1               (opcode_shr_1),
        .o_opcode_x86_SHR_shift_logical_right_CL              (opcode_shr_cl),
        .o_opcode_x86_SHR_shift_logical_right_imm             (opcode_shr_imm),
        .o_opcode_x86_SHRD_double_precision_shift_right_imm  (opcode_shrd_imm),
        .o_opcode_x86_SHRD_double_precision_shift_right_CL   (opcode_shrd_cl),
        .o_opcode_x86_SIDT_store_interrupt_descriptor_table  (opcode_sidt),
        .o_opcode_x86_SLDT_store_local_descriptor_table      (opcode_sldt),
        .o_opcode_x86_SMSW_store_status_word                 (opcode_smsw),
        .o_opcode_x86_STC_set_carry_flag                     (opcode_stc),
        .o_opcode_x86_STD_set_direction_flag                 (opcode_std),
        .o_opcode_x86_STI_set_interrupt_enable_flag          (opcode_sti),
        .o_opcode_x86_STOS_store_string_operand              (opcode_stos),
        .o_opcode_x86_STR_store_task_register                (opcode_str),
        .o_opcode_x86_SUB_reg_to_reg_mem                     (opcode_sub_reg_to_reg_mem),
        .o_opcode_x86_SUB_reg_mem_to_reg                     (opcode_sub_reg_mem_to_reg),
        .o_opcode_x86_SUB_imm_to_reg_mem                     (opcode_sub_imm_to_reg_mem),
        .o_opcode_x86_SUB_imm_to_acc                         (opcode_sub_imm_to_acc),
        .o_opcode_x86_TEST_reg_mem                           (opcode_test_reg_mem),
        .o_opcode_x86_TEST_imm_reg_mem                       (opcode_test_imm_reg_mem),
        .o_opcode_x86_TEST_imm_acc                           (opcode_test_imm_acc),
        .o_opcode_x86_UD0_undefined_instruction_0              (opcode_ud0),
        .o_opcode_x86_UD1_undefined_instruction_1              (opcode_ud1),
        .o_opcode_x86_UD2_undefined_instruction_2              (opcode_ud2),
        .o_opcode_x86_VERR_verify_segment_for_reading         (opcode_verr),
        .o_opcode_x86_VERW_verify_segment_for_writing         (opcode_verw),
        .o_opcode_x86_WAIT_wait_for_interrupt                  (opcode_wait),
        .o_opcode_x86_WBINVD_write_back_invalidate_cache       (opcode_wbinvd),
        .o_opcode_x86_WRMSR_write_model_specific_register     (opcode_wrmsr),
        .o_opcode_x86_XADD_exchange_and_add                    (opcode_xadd),
        .o_opcode_x86_XCHG_exchange_reg_mem_with_reg           (opcode_xchg_reg_mem),
        .o_opcode_x86_XCHG_exchange_reg_with_acc              (opcode_xchg_acc),
        .o_opcode_x86_XLAT_table_lookup_at_BX_AL               (opcode_xlat),
        .o_opcode_x86_XOR_reg_to_reg_mem                      (opcode_xor_reg_to_reg_mem),
        .o_opcode_x86_XOR_reg_mem_to_reg                      (opcode_xor_reg_mem_to_reg),
        .o_opcode_x86_XOR_imm_to_reg_mem                      (opcode_xor_imm_to_reg_mem),
        .o_opcode_x86_XOR_imm_to_acc                          (opcode_xor_imm_to_acc),
        .o_opcode_x86_x87_esc                                 (opcode_x87_esc)
    );
    /* verilator lint_on PINMISSING */

    // ============================================================
    // Operand module instantiation (bytes[prefix_count+opcode_count:prefix_count+opcode_count+7])
    // ============================================================
    logic [ 7: 0][ 7: 0] operand_instruction_bytes;
    logic [ 3: 0]        operand_byte_offset;
    assign operand_byte_offset = stage2_prefix_bytes_r + stage2_opcode_bytes_r;

    always_comb begin
        unique case (operand_byte_offset)
            4'd0: operand_instruction_bytes = i_ifu_instruction[0];
            4'd1: operand_instruction_bytes = i_ifu_instruction[1];
            4'd2: operand_instruction_bytes = i_ifu_instruction[2];
            4'd3: operand_instruction_bytes = i_ifu_instruction[3];
            4'd4: operand_instruction_bytes = i_ifu_instruction[4];
            4'd5: operand_instruction_bytes = i_ifu_instruction[5];
            4'd6: operand_instruction_bytes = i_ifu_instruction[6];
            4'd7: operand_instruction_bytes = i_ifu_instruction[7];
            4'd8: operand_instruction_bytes = i_ifu_instruction[8];
            default: operand_instruction_bytes = i_ifu_instruction[0];
        endcase
    end

    /* verilator lint_off PINMISSING */
    /* verilator lint_off PINCONNECTEMPTY */
    stage_2_dec_x86_operand u_operand (
        .i_instruction_bytes         (operand_instruction_bytes),
        .i_default_op_size           (3'b011),
        .o_tttn                      (operand_tttn),
        .o_gpr_reg_index_valid       (),
        .o_gpr_reg_index             (),
        .o_seg_reg_index_valid       (),
        .o_seg_reg_index             (),
        .o_w_valid                   (),
        .o_w                         (),
        .o_s_valid                   (),
        .o_s                         (),
        .o_eee                       (operand_eee),
        .o_modrm_present             (),
        .o_mod                       (operand_mod),
        .o_rm                        (),
        .o_imm_size_full             (),
        .o_imm_size_16b             (),
        .o_imm_size_8b              (),
        .o_imm_present              (),
        .o_disp_size_full            (),
        .o_disp_size_8b             (),
        .o_disp_present             (),
        .o_opcode_byte_1            (),
        .o_opcode_byte_2            (),
        .o_opcode_byte_3            (),
        .o_seg_reg_index_addr        (operand_seg_reg_index_addr),
        .o_base_reg_valid            (operand_base_reg_valid),
        .o_base_reg_index           (operand_base_reg_index),
        .o_index_reg_valid           (operand_index_reg_valid),
        .o_index_reg_index          (operand_index_reg_index),
        .o_gpr_reg_valid            (),
        .o_gpr_reg_index_addr        (),
        .o_gpr_reg_bit_width        (),
        .o_disp_present_addr        (),
        .o_disp_size_8b_addr        (),
        .o_disp_size_16b            (),
        .o_disp_size_32b            (),
        .o_sib_present              (),
        .o_scale                     (operand_scale),
        .o_index_reg_valid_sib      (),
        .o_index_reg_index_sib      (),
        .o_base_reg_valid_sib       (),
        .o_base_reg_index_sib       (),
        .o_disp_size_1b_sib         (),
        .o_disp_size_4b_sib         (),
        .o_ea_undefined             (),
        .o_disp_value                (operand_disp_value),
        .o_imm_value                 (operand_imm_value),
        .o_consume_byte_count       (operand_consume_byte_count),
        .o_decode_error             (operand_decode_error),
        .i_opcode_x86_AAA_ASCII_adjust_after_add       (opcode_aaa),
        .i_opcode_x86_AAD_ASCII_AX_before_div         (opcode_aad),
        .i_opcode_x86_AAM_ASCII_AX_after_mul          (opcode_aam),
        .i_opcode_x86_AAS_ASCII_adjust_after_sub      (opcode_aas),
        .i_opcode_x86_ADC_reg_to_reg_mem              (opcode_adc_reg_to_reg_mem),
        .i_opcode_x86_ADC_reg_mem_to_reg              (opcode_adc_reg_mem_to_reg),
        .i_opcode_x86_ADC_imm_to_reg_mem              (opcode_adc_imm_to_reg_mem),
        .i_opcode_x86_ADC_imm_to_acc                  (opcode_adc_imm_to_acc),
        .i_opcode_x86_ADD_reg_to_reg_mem              (opcode_add_reg_to_reg_mem),
        .i_opcode_x86_ADD_reg_mem_to_reg              (opcode_add_reg_mem_to_reg),
        .i_opcode_x86_ADD_imm_to_reg_mem              (opcode_add_imm_to_reg_mem),
        .i_opcode_x86_ADD_imm_to_acc                  (opcode_add_imm_to_acc),
        .i_opcode_x86_AND_reg_to_reg_mem              (opcode_and_reg_to_reg_mem),
        .i_opcode_x86_AND_reg_mem_to_reg              (opcode_and_reg_mem_to_reg),
        .i_opcode_x86_AND_imm_to_reg_mem              (opcode_and_imm_to_reg_mem),
        .i_opcode_x86_AND_imm_to_acc                  (opcode_and_imm_to_acc),
        .i_opcode_x86_ARPL_adjust_RPL_field_of_selector (opcode_arpl),
        .i_opcode_x86_BOUND_check_array_against_bounds (opcode_bound),
        .i_opcode_x86_BSF_bit_scan_forward            (opcode_bsf),
        .i_opcode_x86_BSR_bit_scan_reverse            (opcode_bsr),
        .i_opcode_x86_BSWAP_byte_swap                 (opcode_bswap),
        .i_opcode_x86_BT_reg_mem_with_imm             (opcode_bt_imm),
        .i_opcode_x86_BT_reg_mem_with_reg             (opcode_bt_reg),
        .i_opcode_x86_BTC_reg_mem_with_imm            (opcode_btc_imm),
        .i_opcode_x86_BTC_reg_mem_with_reg            (opcode_btc_reg),
        .i_opcode_x86_BTR_reg_mem_with_imm            (opcode_btr_imm),
        .i_opcode_x86_BTR_reg_mem_with_reg            (opcode_btr_reg),
        .i_opcode_x86_BTS_reg_mem_with_imm            (opcode_bts_imm),
        .i_opcode_x86_BTS_reg_mem_with_reg            (opcode_bts_reg),
        .i_opcode_x86_CALL_in_same_segment_direct     (opcode_call_near_direct),
        .i_opcode_x86_CALL_in_same_segment_indirect    (opcode_call_near_indirect),
        .i_opcode_x86_CALL_in_other_segment_direct     (opcode_call_far_direct),
        .i_opcode_x86_CALL_in_other_segment_indirect    (opcode_call_far_indirect),
        .i_opcode_x86_CBW_convert_byte_to_word         (opcode_cbw),
        .i_opcode_x86_CDQ_convert_double_word_to_quad_word (opcode_cdq),
        .i_opcode_x86_CLC_carry             (opcode_clc),
        .i_opcode_x86_CLD_dir         (opcode_cld),
        .i_opcode_x86_CLI_int_en  (opcode_cli),
        .i_opcode_x86_CLTS_clear_task_switched_flag     (opcode_clts),
        .i_opcode_x86_CMC_carry         (opcode_cmc),
        .i_opcode_x86_CMP_mem_with_reg                  (opcode_cmp_mem_reg),
        .i_opcode_x86_CMP_reg_with_mem                  (opcode_cmp_reg_mem),
        .i_opcode_x86_CMP_imm_with_reg_mem             (opcode_cmp_imm_reg_mem),
        .i_opcode_x86_CMP_imm_with_acc                  (opcode_cmp_imm_acc),
        .i_opcode_x86_CMPS_compare_string_operands      (opcode_cmps),
        .i_opcode_x86_CMPXCHG_compare_and_exchange      (opcode_cmpxchg),
        .i_opcode_x86_CPUID_CPU_identification          (opcode_cpuid),
        .i_opcode_x86_CWD_convert_word_to_double        (opcode_cwd),
        .i_opcode_x86_CWDE_convert_word_to_double        (opcode_cwde),
        .i_opcode_x86_DAA_decimal_adjust_AL_after_add   (opcode_daa),
        .i_opcode_x86_DAS_decimal_adjust_AL_after_sub   (opcode_das),
        .i_opcode_x86_DEC_reg_mem                       (opcode_dec_reg_mem),
        .i_opcode_x86_DEC_reg                           (opcode_dec_reg),
        .i_opcode_x86_DIV_acc_by_reg_mem                (opcode_div),
        .i_opcode_x86_HLT_halt                          (opcode_hlt),
        .i_opcode_x86_IDIV_acc_by_reg_mem               (opcode_idiv),
        .i_opcode_x86_IMUL_acc_with_reg_mem             (opcode_imul_acc),
        .i_opcode_x86_IMUL_reg_with_reg_mem             (opcode_imul_reg),
        .i_opcode_x86_IMUL_reg_mem_with_imm_to_reg      (opcode_imul_imm),
        .i_opcode_x86_IN_port_fixed                     (opcode_in_fixed),
        .i_opcode_x86_IN_port_variable                  (opcode_in_var),
        .i_opcode_x86_INC_reg_mem                       (opcode_inc_reg_mem),
        .i_opcode_x86_INC_reg                           (opcode_inc_reg),
        .i_opcode_x86_INS_input_from_DX_port            (opcode_ins),
        .i_opcode_x86_INT_interrupt_type_n              (opcode_int_n),
        .i_opcode_x86_INT_interrupt_type_3              (opcode_int_3),
        .i_opcode_x86_INT_interrupt_type_4              (opcode_int_4),
        .i_opcode_x86_INVD_invalidate_cache              (opcode_invd),
        .i_opcode_x86_INVLPG_invalidate_TLB_entry         (opcode_invlpg),
        .i_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size (opcode_invpcid),
        .i_opcode_x86_IRET_interrupt_return             (opcode_iret),
        .i_opcode_x86_Jcc_jump_if_cond_is_met_8_bit_disp (opcode_jcc_short),
        .i_opcode_x86_Jcc_jump_if_cond_is_met_full_disp (opcode_jcc_near),
        .i_opcode_x86_JCXZ_jump_on_CX_zero               (opcode_jcxz),
        .i_opcode_x86_JMP_to_same_segment_short          (opcode_jmp_short),
        .i_opcode_x86_JMP_to_same_segment_direct         (opcode_jmp_near_direct),
        .i_opcode_x86_JMP_to_same_segment_indirect        (opcode_jmp_near_indirect),
        .i_opcode_x86_JMP_to_other_segment_direct        (opcode_jmp_far_direct),
        .i_opcode_x86_JMP_to_other_segment_indirect       (opcode_jmp_far_indirect),
        .i_opcode_x86_LAHF_load_FLAG_into_AH             (opcode_lahf),
        .i_opcode_x86_LAR_load_access_rights_byte        (opcode_lar),
        .i_opcode_x86_LDS_load_pointer_to_DS              (opcode_lds),
        .i_opcode_x86_LEA_load_effective_adddress_to_reg (opcode_lea),
        .i_opcode_x86_LEAVE_high_level_procedure_exit    (opcode_leave),
        .i_opcode_x86_LES_load_pointer_to_ES              (opcode_les),
        .i_opcode_x86_LFS_load_pointer_to_FS              (opcode_lfs),
        .i_opcode_x86_LGDT_load_global_desciptor_table_reg (opcode_lgdt),
        .i_opcode_x86_LGS_load_pointer_to_GS              (opcode_lgs),
        .i_opcode_x86_LIDT_load_interrupt_desciptor_table_reg (opcode_lidt),
        .i_opcode_x86_LLDT_load_local_desciptor_table_reg (opcode_lldt),
        .i_opcode_x86_LMSW_load_status_word              (opcode_lmsw),
        .i_opcode_x86_LODS_load_string_operand           (opcode_lods),
        .i_opcode_x86_LOOP_count                         (opcode_loop),
        .i_opcode_x86_LOOPZ_count_while_zero              (opcode_loopz),
        .i_opcode_x86_LOOPNZ_count_while_not_zero         (opcode_loopnz),
        .i_opcode_x86_LSL_load_segment_limit             (opcode_lsl),
        .i_opcode_x86_LSS_load_pointer_to_SS              (opcode_lss),
        .i_opcode_x86_LTR_load_task_register             (opcode_ltr),
        .i_opcode_x86_MOV_reg_to_reg_mem                  (opcode_mov_reg_to_reg_mem),
        .i_opcode_x86_MOV_reg_mem_to_reg                  (opcode_mov_reg_mem_to_reg),
        .i_opcode_x86_MOV_imm_to_reg_mem                  (opcode_mov_imm_to_reg_mem),
        .i_opcode_x86_MOV_imm_to_reg                      (opcode_mov_imm_to_reg),
        .i_opcode_x86_MOV_mem_to_acc                      (opcode_mov_mem_to_acc),
        .i_opcode_x86_MOV_acc_to_mem                      (opcode_mov_acc_to_mem),
        .i_opcode_x86_MOV_CR_from_reg                     (opcode_mov_cr_from_reg),
        .i_opcode_x86_MOV_reg_from_CR                     (opcode_mov_reg_from_cr),
        .i_opcode_x86_MOV_DR_from_reg                     (opcode_mov_dr_from_reg),
        .i_opcode_x86_MOV_reg_from_DR                     (opcode_mov_reg_from_dr),
        .i_opcode_x86_MOV_TR_from_reg                     (opcode_mov_tr_from_reg),
        .i_opcode_x86_MOV_reg_from_TR                     (opcode_mov_reg_from_tr),
        .i_opcode_x86_MOV_reg_mem_to_sreg                 (opcode_mov_reg_mem_to_sreg),
        .i_opcode_x86_MOV_sreg_to_reg_mem                 (opcode_mov_sreg_to_reg_mem),
        .i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg (opcode_movbe_mem_reg),
        .i_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem (opcode_movbe_reg_mem),
        .i_opcode_x86_MOVS_move_data_from_string_to_string (opcode_movs),
        .i_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg (opcode_movsx),
        .i_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg (opcode_movzx),
        .i_opcode_x86_MUL_acc_with_reg_mem                (opcode_mul),
        .i_opcode_x86_NEG_two_s_complement_negation        (opcode_neg),
        .i_opcode_x86_NOP_no_operation                    (opcode_nop),
        .i_opcode_x86_NOP_no_operation_multi_byte         (opcode_nop_multibyte),
        .i_opcode_x86_NOT_one_s_complement_negation        (opcode_not),
        .i_opcode_x86_OR_reg_to_reg_mem                   (opcode_or_reg_to_reg_mem),
        .i_opcode_x86_OR_reg_mem_to_reg                   (opcode_or_reg_mem_to_reg),
        .i_opcode_x86_OR_imm_to_reg_mem                   (opcode_or_imm_to_reg_mem),
        .i_opcode_x86_OR_imm_to_acc                       (opcode_or_imm_to_acc),
        .i_opcode_x86_OUT_port_fixed                      (opcode_out_fixed),
        .i_opcode_x86_OUT_port_variable                   (opcode_out_var),
        .i_opcode_x86_OUTS_output_to_DX_port               (opcode_outs),
        .i_opcode_x86_POP_reg_mem                         (opcode_pop_reg_mem),
        .i_opcode_x86_POP_reg                             (opcode_pop_reg),
        .i_opcode_x86_POP_sreg_2                          (opcode_pop_sreg_2),
        .i_opcode_x86_POP_sreg_3                          (opcode_pop_sreg_3),
        .i_opcode_x86_POPA_pop_all_registers               (opcode_popa),
        .i_opcode_x86_POPF_pop_flags                       (opcode_popf),
        .i_opcode_x86_PUSH_reg_mem                        (opcode_push_reg_mem),
        .i_opcode_x86_PUSH_reg                            (opcode_push_reg),
        .i_opcode_x86_PUSH_sreg_2                         (opcode_push_sreg_2),
        .i_opcode_x86_PUSH_sreg_3                         (opcode_push_sreg_3),
        .i_opcode_x86_PUSH_imm                            (opcode_push_imm),
        .i_opcode_x86_PUSHA_push_all_registers             (opcode_pusha),
        .i_opcode_x86_PUSHF_push_flags                    (opcode_pushf),
        .i_opcode_x86_RCL_rotate_through_carry_left_1      (opcode_rcl_1),
        .i_opcode_x86_RCL_rotate_through_carry_left_CL     (opcode_rcl_cl),
        .i_opcode_x86_RCL_rotate_through_carry_left_imm    (opcode_rcl_imm),
        .i_opcode_x86_RCR_rotate_through_carry_right_1     (opcode_rcr_1),
        .i_opcode_x86_RCR_rotate_through_carry_right_CL    (opcode_rcr_cl),
        .i_opcode_x86_RCR_rotate_through_carry_right_imm   (opcode_rcr_imm),
        .i_opcode_x86_RDMSR_read_model_specific_register    (opcode_rdmsr),
        .i_opcode_x86_RDPMC_read_performance_monitor_counter (opcode_rdpmc),
        .i_opcode_x86_RDTSC_read_time_stamp_counter          (opcode_rdtsc),
        .i_opcode_x86_RDTSCP_read_time_stamp_counter_processor_id (opcode_rdtscp),
        .i_opcode_x86_RET_near_return_from_procedure         (opcode_ret_near),
        .i_opcode_x86_RET_near_return_with_immediate        (opcode_ret_near_imm),
        .i_opcode_x86_RET_far_return_from_procedure          (opcode_ret_far),
        .i_opcode_x86_RET_far_return_with_immediate         (opcode_ret_far_imm),
        .i_opcode_x86_ROL_rotate_left_1                     (opcode_rol_1),
        .i_opcode_x86_ROL_rotate_left_CL                    (opcode_rol_cl),
        .i_opcode_x86_ROL_rotate_left_imm                   (opcode_rol_imm),
        .i_opcode_x86_ROR_rotate_right_1                    (opcode_ror_1),
        .i_opcode_x86_ROR_rotate_right_CL                   (opcode_ror_cl),
        .i_opcode_x86_ROR_rotate_right_imm                  (opcode_ror_imm),
        .i_opcode_x86_RSM_resume_from_system_management_mode (opcode_rsm),
        .i_opcode_x86_SAHF_store_AH_into_flags              (opcode_sahf),
        .i_opcode_x86_SAR_shift_arithmetic_right_1           (opcode_sar_1),
        .i_opcode_x86_SAR_shift_arithmetic_right_CL          (opcode_sar_cl),
        .i_opcode_x86_SAR_shift_arithmetic_right_imm         (opcode_sar_imm),
        .i_opcode_x86_SBB_reg_to_reg_mem                     (opcode_sbb_reg_to_reg_mem),
        .i_opcode_x86_SBB_reg_mem_to_reg                     (opcode_sbb_reg_mem_to_reg),
        .i_opcode_x86_SBB_imm_to_reg_mem                     (opcode_sbb_imm_to_reg_mem),
        .i_opcode_x86_SBB_imm_to_acc                         (opcode_sbb_imm_to_acc),
        .i_opcode_x86_SCAS_compare_string_operand            (opcode_scas),
        .i_opcode_x86_SETCC_set_byte_on_condition            (opcode_setcc),
        .i_opcode_x86_SGDT_store_global_descriptor_table     (opcode_sgdt),
        .i_opcode_x86_SHL_shift_logical_left_1               (opcode_shl_1),
        .i_opcode_x86_SHL_shift_logical_left_CL              (opcode_shl_cl),
        .i_opcode_x86_SHL_shift_logical_left_imm             (opcode_shl_imm),
        .i_opcode_x86_SHLD_double_precision_shift_left_imm   (opcode_shld_imm),
        .i_opcode_x86_SHLD_double_precision_shift_left_CL    (opcode_shld_cl),
        .i_opcode_x86_SHR_shift_logical_right_1               (opcode_shr_1),
        .i_opcode_x86_SHR_shift_logical_right_CL              (opcode_shr_cl),
        .i_opcode_x86_SHR_shift_logical_right_imm             (opcode_shr_imm),
        .i_opcode_x86_SHRD_double_precision_shift_right_imm  (opcode_shrd_imm),
        .i_opcode_x86_SHRD_double_precision_shift_right_CL   (opcode_shrd_cl),
        .i_opcode_x86_SIDT_store_interrupt_descriptor_table  (opcode_sidt),
        .i_opcode_x86_SLDT_store_local_descriptor_table      (opcode_sldt),
        .i_opcode_x86_SMSW_store_status_word                 (opcode_smsw),
        .i_opcode_x86_STC_set_carry_flag                     (opcode_stc),
        .i_opcode_x86_STD_set_direction_flag                 (opcode_std),
        .i_opcode_x86_STI_set_interrupt_enable_flag          (opcode_sti),
        .i_opcode_x86_STOS_store_string_operand              (opcode_stos),
        .i_opcode_x86_STR_store_task_register                (opcode_str),
        .i_opcode_x86_SUB_reg_to_reg_mem                     (opcode_sub_reg_to_reg_mem),
        .i_opcode_x86_SUB_reg_mem_to_reg                     (opcode_sub_reg_mem_to_reg),
        .i_opcode_x86_SUB_imm_to_reg_mem                     (opcode_sub_imm_to_reg_mem),
        .i_opcode_x86_SUB_imm_to_acc                         (opcode_sub_imm_to_acc),
        .i_opcode_x86_TEST_reg_mem                           (opcode_test_reg_mem),
        .i_opcode_x86_TEST_imm_reg_mem                       (opcode_test_imm_reg_mem),
        .i_opcode_x86_TEST_imm_acc                           (opcode_test_imm_acc),
        .i_opcode_x86_UD0_undefined_instruction_0              (opcode_ud0),
        .i_opcode_x86_UD1_undefined_instruction_1              (opcode_ud1),
        .i_opcode_x86_UD2_undefined_instruction_2              (opcode_ud2),
        .i_opcode_x86_VERR_verify_segment_for_reading         (opcode_verr),
        .i_opcode_x86_VERW_verify_segment_for_writing         (opcode_verw),
        .i_opcode_x86_WAIT_wait_for_interrupt                  (opcode_wait),
        .i_opcode_x86_WBINVD_write_back_invalidate_cache       (opcode_wbinvd),
        .i_opcode_x86_WRMSR_write_model_specific_register     (opcode_wrmsr),
        .i_opcode_x86_XADD_exchange_and_add                    (opcode_xadd),
        .i_opcode_x86_XCHG_exchange_reg_mem_with_reg           (opcode_xchg_reg_mem),
        .i_opcode_x86_XCHG_exchange_reg_with_acc              (opcode_xchg_acc),
        .i_opcode_x86_XLAT_table_lookup_at_BX_AL               (opcode_xlat),
        .i_opcode_x86_XOR_reg_to_reg_mem                      (opcode_xor_reg_to_reg_mem),
        .i_opcode_x86_XOR_reg_mem_to_reg                      (opcode_xor_reg_mem_to_reg),
        .i_opcode_x86_XOR_imm_to_reg_mem                      (opcode_xor_imm_to_reg_mem),
        .i_opcode_x86_XOR_imm_to_acc                          (opcode_xor_imm_to_acc),
        .o_opcode_x86_x87_esc                                 (opcode_x87_esc)
    );
    /* verilator lint_on PINCONNECTEMPTY */
    /* verilator lint_on PINMISSING */

endmodule
