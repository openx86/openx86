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
//  Description : stage_2_dec module
// ============================================================================

module stage_2_dec (
    // =========================
    // instruction input
    // =========================
    input  logic [15: 0][ 7: 0] i_instruction,
    input  logic                i_instruction_valid,
    input  logic                i_default_operand_size,

    // =========================
    // pipeline handshake
    // =========================
    input  logic                i_exu_ready,
    input  logic                i_flush,
    output logic                o_ifu_ready,
    output logic                o_instruction_fire,
    output logic                o_stage_valid,

    // =========================
    // decode outputs
    // =========================
    output logic [ 3: 0]        o_consume_bytes,
    output logic                o_decode_error,

    // =========================
    // decoded opcode outputs (full instruction set)
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

    // Decoded operand fields (subset)
    output logic [31: 0]        o_dec_displacement,      // 输出信号
    output logic [31: 0]        o_dec_immediate,         // 输出信号
    output logic                o_dec_base_reg_is_present, // 输出信号
    output logic [ 2: 0]        o_dec_base_reg_index,    // 输出信号
    output logic                o_dec_index_reg_is_present, // 输出信号
    output logic [ 2: 0]        o_dec_index_reg_index,   // 输出信号
    output logic [ 2: 0]        o_dec_segment_reg_index, // 输出信号
    output logic [ 1: 0]        o_dec_sib_scale_factor,  // 输出信号
    output logic [ 1: 0]        o_dec_modrm_mod,         // 输出信号

    input  logic                clk,                      // 时钟信号
    input  logic                rst_n                     // 复位信号
);

    // Decode stage handshake logic (merged from decode_stage.sv)
    assign o_ifu_ready         = i_exu_ready;
    assign o_instruction_fire = i_instruction_valid & i_exu_ready & ~i_flush;
    assign o_stage_valid       = i_instruction_valid & ~o_decode_error;

    // TODO: Instantiate actual decoder modules when available
    // stage_2_dec_decode_unit u_stage_2_dec_unit (
    //     .i_instruction          (i_instruction),
    //     .i_default_operand_size (i_default_operand_size),
    //     ...
    // );

    // Temporary: assign all opcode outputs to 0
    assign o_opcode_aaa = 1'b0;
    assign o_opcode_aad = 1'b0;
    assign o_opcode_aam = 1'b0;
    assign o_opcode_aas = 1'b0;
    assign o_opcode_adc_reg_to_reg_mem = 1'b0;
    assign o_opcode_adc_reg_mem_to_reg = 1'b0;
    assign o_opcode_adc_imm_to_reg_mem = 1'b0;
    assign o_opcode_adc_imm_to_acc = 1'b0;
    assign o_opcode_add_reg_to_reg_mem = 1'b0;
    assign o_opcode_add_reg_mem_to_reg = 1'b0;
    assign o_opcode_add_imm_to_reg_mem = 1'b0;
    assign o_opcode_add_imm_to_acc = 1'b0;
    assign o_opcode_and_reg_to_reg_mem = 1'b0;
    assign o_opcode_and_reg_mem_to_reg = 1'b0;
    assign o_opcode_and_imm_to_reg_mem = 1'b0;
    assign o_opcode_and_imm_to_acc = 1'b0;
    assign o_opcode_arpl = 1'b0;
    assign o_opcode_bound = 1'b0;
    assign o_opcode_bsf = 1'b0;
    assign o_opcode_bsr = 1'b0;
    assign o_opcode_bswap = 1'b0;
    assign o_opcode_bt_imm = 1'b0;
    assign o_opcode_bt_reg = 1'b0;
    assign o_opcode_btc_imm = 1'b0;
    assign o_opcode_btc_reg = 1'b0;
    assign o_opcode_btr_imm = 1'b0;
    assign o_opcode_btr_reg = 1'b0;
    assign o_opcode_bts_imm = 1'b0;
    assign o_opcode_bts_reg = 1'b0;
    assign o_opcode_call_near_direct = 1'b0;
    assign o_opcode_call_near_indirect = 1'b0;
    assign o_opcode_call_far_direct = 1'b0;
    assign o_opcode_call_far_indirect = 1'b0;
    assign o_opcode_cbw = 1'b0;
    assign o_opcode_cdq = 1'b0;
    assign o_opcode_clc = 1'b0;
    assign o_opcode_cld = 1'b0;
    assign o_opcode_cli = 1'b0;
    assign o_opcode_clts = 1'b0;
    assign o_opcode_cmc = 1'b0;
    assign o_opcode_cmp_mem_reg = 1'b0;
    assign o_opcode_cmp_reg_mem = 1'b0;
    assign o_opcode_cmp_imm_reg_mem = 1'b0;
    assign o_opcode_cmp_imm_acc = 1'b0;
    assign o_opcode_cmps = 1'b0;
    assign o_opcode_cmpxchg = 1'b0;
    assign o_opcode_cpuid = 1'b0;
    assign o_opcode_cwd = 1'b0;
    assign o_opcode_cwde = 1'b0;
    assign o_opcode_daa = 1'b0;
    assign o_opcode_das = 1'b0;
    assign o_opcode_dec_reg_mem = 1'b0;
    assign o_opcode_dec_reg = 1'b0;
    assign o_opcode_div = 1'b0;
    assign o_opcode_hlt = 1'b0;
    assign o_opcode_idiv = 1'b0;
    assign o_opcode_imul_acc = 1'b0;
    assign o_opcode_imul_reg = 1'b0;
    assign o_opcode_imul_imm = 1'b0;
    assign o_opcode_in_fixed = 1'b0;
    assign o_opcode_in_var = 1'b0;
    assign o_opcode_inc_reg_mem = 1'b0;
    assign o_opcode_inc_reg = 1'b0;
    assign o_opcode_ins = 1'b0;
    assign o_opcode_int_n = 1'b0;
    assign o_opcode_int_3 = 1'b0;
    assign o_opcode_int_4 = 1'b0;
    assign o_opcode_invd = 1'b0;
    assign o_opcode_invlpg = 1'b0;
    assign o_opcode_invpcid = 1'b0;
    assign o_opcode_iret = 1'b0;
    assign o_opcode_jcc_short = 1'b0;
    assign o_opcode_jcc_near = 1'b0;
    assign o_opcode_jcxz = 1'b0;
    assign o_opcode_jmp_short = 1'b0;
    assign o_opcode_jmp_near_direct = 1'b0;
    assign o_opcode_jmp_near_indirect = 1'b0;
    assign o_opcode_jmp_far_direct = 1'b0;
    assign o_opcode_jmp_far_indirect = 1'b0;
    assign o_opcode_lahf = 1'b0;
    assign o_opcode_lar = 1'b0;
    assign o_opcode_lds = 1'b0;
    assign o_opcode_lea = 1'b0;
    assign o_opcode_leave = 1'b0;
    assign o_opcode_les = 1'b0;
    assign o_opcode_lfs = 1'b0;
    assign o_opcode_lgdt = 1'b0;
    assign o_opcode_lgs = 1'b0;
    assign o_opcode_lidt = 1'b0;
    assign o_opcode_lldt = 1'b0;
    assign o_opcode_lmsw = 1'b0;
    assign o_opcode_lods = 1'b0;
    assign o_opcode_loop = 1'b0;
    assign o_opcode_loopz = 1'b0;
    assign o_opcode_loopnz = 1'b0;
    assign o_opcode_lsl = 1'b0;
    assign o_opcode_lss = 1'b0;
    assign o_opcode_ltr = 1'b0;
    assign o_opcode_mov_reg_to_reg_mem = 1'b0;
    assign o_opcode_mov_reg_mem_to_reg = 1'b0;
    assign o_opcode_mov_imm_to_reg_mem = 1'b0;
    assign o_opcode_mov_imm_to_reg = 1'b0;
    assign o_opcode_mov_mem_to_acc = 1'b0;
    assign o_opcode_mov_acc_to_mem = 1'b0;
    assign o_opcode_mov_cr_from_reg = 1'b0;
    assign o_opcode_mov_reg_from_cr = 1'b0;
    assign o_opcode_mov_dr_from_reg = 1'b0;
    assign o_opcode_mov_reg_from_dr = 1'b0;
    assign o_opcode_mov_tr_from_reg = 1'b0;
    assign o_opcode_mov_reg_from_tr = 1'b0;
    assign o_opcode_mov_reg_mem_to_sreg = 1'b0;
    assign o_opcode_mov_sreg_to_reg_mem = 1'b0;
    assign o_opcode_movbe_mem_reg = 1'b0;
    assign o_opcode_movbe_reg_mem = 1'b0;
    assign o_opcode_movs = 1'b0;
    assign o_opcode_movsx = 1'b0;
    assign o_opcode_movzx = 1'b0;
    assign o_opcode_mul = 1'b0;
    assign o_opcode_neg = 1'b0;
    assign o_opcode_nop = 1'b0;
    assign o_opcode_nop_multibyte = 1'b0;
    assign o_opcode_not = 1'b0;
    assign o_opcode_or_reg_to_reg_mem = 1'b0;
    assign o_opcode_or_reg_mem_to_reg = 1'b0;
    assign o_opcode_or_imm_to_reg_mem = 1'b0;
    assign o_opcode_or_imm_to_acc = 1'b0;
    assign o_opcode_out_fixed = 1'b0;
    assign o_opcode_out_var = 1'b0;
    assign o_opcode_outs = 1'b0;
    assign o_opcode_pop_reg_mem = 1'b0;
    assign o_opcode_pop_reg = 1'b0;
    assign o_opcode_pop_sreg_2 = 1'b0;
    assign o_opcode_pop_sreg_3 = 1'b0;
    assign o_opcode_popa = 1'b0;
    assign o_opcode_popf = 1'b0;
    assign o_opcode_push_reg_mem = 1'b0;
    assign o_opcode_push_reg = 1'b0;
    assign o_opcode_push_sreg_2 = 1'b0;
    assign o_opcode_push_sreg_3 = 1'b0;
    assign o_opcode_push_imm = 1'b0;
    assign o_opcode_pusha = 1'b0;
    assign o_opcode_pushf = 1'b0;
    assign o_opcode_rcl_1 = 1'b0;
    assign o_opcode_rcl_cl = 1'b0;
    assign o_opcode_rcl_imm = 1'b0;
    assign o_opcode_rcr_1 = 1'b0;
    assign o_opcode_rcr_cl = 1'b0;
    assign o_opcode_rcr_imm = 1'b0;
    assign o_opcode_rdmsr = 1'b0;
    assign o_opcode_rdpmc = 1'b0;
    assign o_opcode_rdtsc = 1'b0;
    assign o_opcode_rdtscp = 1'b0;
    assign o_opcode_ret_near = 1'b0;
    assign o_opcode_ret_near_imm = 1'b0;
    assign o_opcode_ret_far = 1'b0;
    assign o_opcode_ret_far_imm = 1'b0;
    assign o_opcode_rol_1 = 1'b0;
    assign o_opcode_rol_cl = 1'b0;
    assign o_opcode_rol_imm = 1'b0;
    assign o_opcode_ror_1 = 1'b0;
    assign o_opcode_ror_cl = 1'b0;
    assign o_opcode_ror_imm = 1'b0;
    assign o_opcode_rsm = 1'b0;
    assign o_opcode_sahf = 1'b0;
    assign o_opcode_sar_1 = 1'b0;
    assign o_opcode_sar_cl = 1'b0;
    assign o_opcode_sar_imm = 1'b0;
    assign o_opcode_sbb_reg_to_reg_mem = 1'b0;
    assign o_opcode_sbb_reg_mem_to_reg = 1'b0;
    assign o_opcode_sbb_imm_to_reg_mem = 1'b0;
    assign o_opcode_sbb_imm_to_acc = 1'b0;
    assign o_opcode_scas = 1'b0;
    assign o_opcode_setcc = 1'b0;
    assign o_opcode_sgdt = 1'b0;
    assign o_opcode_shl_1 = 1'b0;
    assign o_opcode_shl_cl = 1'b0;
    assign o_opcode_shl_imm = 1'b0;
    assign o_opcode_shld_imm = 1'b0;
    assign o_opcode_shld_cl = 1'b0;
    assign o_opcode_shr_1 = 1'b0;
    assign o_opcode_shr_cl = 1'b0;
    assign o_opcode_shr_imm = 1'b0;
    assign o_opcode_shrd_imm = 1'b0;
    assign o_opcode_shrd_cl = 1'b0;
    assign o_opcode_sidt = 1'b0;
    assign o_opcode_sldt = 1'b0;
    assign o_opcode_smsw = 1'b0;
    assign o_opcode_stc = 1'b0;
    assign o_opcode_std = 1'b0;
    assign o_opcode_sti = 1'b0;
    assign o_opcode_stos = 1'b0;
    assign o_opcode_str = 1'b0;
    assign o_opcode_sub_reg_to_reg_mem = 1'b0;
    assign o_opcode_sub_reg_mem_to_reg = 1'b0;
    assign o_opcode_sub_imm_to_reg_mem = 1'b0;
    assign o_opcode_sub_imm_to_acc = 1'b0;
    assign o_opcode_test_reg_mem = 1'b0;
    assign o_opcode_test_imm_reg_mem = 1'b0;
    assign o_opcode_test_imm_acc = 1'b0;
    assign o_opcode_ud0 = 1'b0;
    assign o_opcode_ud1 = 1'b0;
    assign o_opcode_ud2 = 1'b0;
    assign o_opcode_verr = 1'b0;
    assign o_opcode_verw = 1'b0;
    assign o_opcode_wait = 1'b0;
    assign o_opcode_wbinvd = 1'b0;
    assign o_opcode_wrmsr = 1'b0;
    assign o_opcode_xadd = 1'b0;
    assign o_opcode_xchg_reg_mem = 1'b0;
    assign o_opcode_xchg_acc = 1'b0;
    assign o_opcode_xlat = 1'b0;
    assign o_opcode_xor_reg_to_reg_mem = 1'b0;
    assign o_opcode_xor_reg_mem_to_reg = 1'b0;
    assign o_opcode_xor_imm_to_reg_mem = 1'b0;
    assign o_opcode_xor_imm_to_acc = 1'b0;
    assign o_opcode_x87_esc = 1'b0;
    assign o_tttn = 4'b0;
    assign o_eee = 3'b0;
    assign o_dec_displacement = 32'b0;
    assign o_dec_immediate = 32'b0;
    assign o_dec_base_reg_is_present = 1'b0;
    assign o_dec_base_reg_index = 3'b0;
    assign o_dec_index_reg_is_present = 1'b0;
    assign o_dec_index_reg_index = 3'b0;
    assign o_dec_segment_reg_index = 3'b0;
    assign o_dec_sib_scale_factor = 2'b0;
    assign o_dec_modrm_mod = 2'b0;
    assign o_decode_error = 1'b0;
    assign o_consume_bytes = 4'b0;

endmodule
