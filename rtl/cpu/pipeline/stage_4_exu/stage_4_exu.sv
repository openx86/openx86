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
//  File        : stage_4_exu.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_4_exu module
// ============================================================================

module stage_4_exu (
    // Stage handshake/control
    input  logic                i_stage2_valid,
    input  logic                i_xadd_wait_reg_wr,
    input  logic                i_am_lsu_busy,
    input  logic                i_muldiv_pair_wait,
    output logic                o_exec_stall,
    output logic                o_stage_ready,
    output logic                o_stage_valid,

    // i486 extension controls
    input  logic                i_insn_fire,
    input  logic                i_op_cpuid,
    input  logic [31: 0]        i_gpr_eax,
    input  logic [31: 0]        i_gpr_ecx,
    input  logic                i_op_invd,
    input  logic                i_op_wbinvd,
    input  logic                i_op_invlpg,
    input  logic [31: 0]        i_invlpg_ea,
    output logic                o_cpuid_busy,
    output logic                o_cpuid_gpr_wr,
    output logic [ 2: 0]        o_cpuid_gpr_idx,
    output logic [31: 0]        o_cpuid_gpr_wdata,
    output logic                o_cpuid_done_pulse,
    output logic                o_cache_flush_pulse,
    output logic                o_invlpg_pulse,
    output logic [31: 0]        o_invlpg_linear_addr,

    // Main execute-unit inputs
    input  logic [31: 0]        i_agu_base,
    input  logic [31: 0]        i_agu_index,
    input  logic [ 1: 0]        i_agu_scale,
    input  logic [31: 0]        i_agu_disp,
    input  logic                i_br_is_jcc,
    input  logic [ 3: 0]        i_br_jcc_nibble,
    input  logic                i_br_CF,
    input  logic                i_br_PF,
    input  logic                i_br_ZF,
    input  logic                i_br_SF,
    input  logic                i_br_OF,
    input  logic [31: 0]        i_br_eip,
    input  logic [31: 0]        i_br_rel32,
    input  logic signed [ 7: 0] i_br_rel8,
    input  logic                i_br_use_rel8,
    input  logic [ 2: 0]        i_md_op,
    input  logic [31: 0]        i_md_lo,
    input  logic [31: 0]        i_md_hi,
    input  logic [31: 0]        i_md_src,
    input  logic                i_int_valid,
    input  logic [ 5: 0]        i_int_op,
    input  logic [31: 0]        i_int_a,
    input  logic [31: 0]        i_int_b,
    input  logic                i_int_cf,
    input  logic                i_int_af,
    input  logic [31: 0]        i_int_count,
    input  logic                i_x87_valid,
    input  logic [ 4: 0]        i_x87_op,
    input  logic [63: 0]        i_x87_push_data,
    input  logic [ 2: 0]        i_x87_st_src,

    // Main execute-unit outputs
    output logic [31: 0]        o_agu_effective_addr,
    output logic                o_br_taken,
    output logic [31: 0]        o_br_target_eip,
    output logic [31: 0]        o_md_lo,
    output logic [31: 0]        o_md_hi,
    output logic                o_md_div0,
    output logic [31: 0]        o_int_result,
    output logic                o_int_cf,
    output logic                o_int_af,
    output logic                o_int_zf,
    output logic [63: 0]        o_x87_st0,
    output logic [63: 0]        o_x87_st1,
    output logic                o_x87_zf,
    output logic                o_x87_pf,
    output logic                o_x87_cf,

    input  logic                clk, // 时钟信号
    input  logic                rst_n // 复位信号
);


endmodule
