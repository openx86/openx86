/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: stage_3_exu wrapper for execute units and EXU backpressure.
*/
// ============================================================================
// stage_3_exu
// ----------------------------------------------------------------------------
// Stage 3 EXU:
// - i486 extension helpers (CPUID/INVD/WBINVD/INVLPG)
// - integer/branch/muldiv/x87 execute unit
// - execute stall and stage ready/valid generation
// ============================================================================

module stage_3_exu (
    // Stage handshake/control
    input  logic                i_stage2_valid, // 输入信号
    input  logic                i_xadd_wait_reg_wr, // 输入信号
    input  logic                i_am_lsu_busy, // 输入信号
    input  logic                i_muldiv_pair_wait, // 输入信号
    output logic                o_exec_stall, // 输出信号
    output logic                o_stage_ready, // 输出信号
    output logic                o_stage_valid, // 输出信号

    // i486 extension controls
    input  logic                i_insn_fire, // 输入信号
    input  logic                i_op_cpuid, // 输入信号
    input  logic [31: 0]        i_gpr_eax, // 输入信号
    input  logic [31: 0]        i_gpr_ecx, // 输入信号
    input  logic                i_op_invd, // 输入信号
    input  logic                i_op_wbinvd, // 输入信号
    input  logic                i_op_invlpg, // 输入信号
    input  logic [31: 0]        i_invlpg_ea, // 输入信号
    output logic                o_cpuid_busy, // 输出信号
    output logic                o_cpuid_gpr_wr, // 输出信号
    output logic [ 2: 0]        o_cpuid_gpr_idx, // 输出信号
    output logic [31: 0]        o_cpuid_gpr_wdata, // 输出信号
    output logic                o_cpuid_done_pulse, // 输出信号
    output logic                o_cache_flush_pulse, // 输出信号
    output logic                o_invlpg_pulse, // 输出信号
    output logic [31: 0]        o_invlpg_linear_addr, // 输出信号

    // Main execute-unit inputs
    input  logic [31: 0]        i_agu_base, // 输入信号
    input  logic [31: 0]        i_agu_index, // 输入信号
    input  logic [ 1: 0]        i_agu_scale, // 输入信号
    input  logic [31: 0]        i_agu_disp, // 输入信号
    input  logic                i_br_is_jcc, // 输入信号
    input  logic [ 3: 0]        i_br_jcc_nibble, // 输入信号
    input  logic                i_br_CF, // 输入信号
    input  logic                i_br_PF, // 输入信号
    input  logic                i_br_ZF, // 输入信号
    input  logic                i_br_SF, // 输入信号
    input  logic                i_br_OF, // 输入信号
    input  logic [31: 0]        i_br_eip, // 输入信号
    input  logic [31: 0]        i_br_rel32, // 输入信号
    input  logic signed [ 7: 0] i_br_rel8, // 输入信号
    input  logic                i_br_use_rel8, // 输入信号
    input  logic [ 2: 0]        i_md_op, // 输入信号
    input  logic [31: 0]        i_md_lo, // 输入信号
    input  logic [31: 0]        i_md_hi, // 输入信号
    input  logic [31: 0]        i_md_src, // 输入信号
    input  logic                i_int_valid, // 输入信号
    input  logic [ 5: 0]        i_int_op, // 输入信号
    input  logic [31: 0]        i_int_a, // 输入信号
    input  logic [31: 0]        i_int_b, // 输入信号
    input  logic                i_int_cf, // 输入信号
    input  logic                i_int_af, // 输入信号
    input  logic [31: 0]        i_int_count, // 输入信号
    input  logic                i_x87_valid, // 输入信号
    input  logic [ 4: 0]        i_x87_op, // 输入信号
    input  logic [63: 0]        i_x87_push_data, // 输入信号
    input  logic [ 2: 0]        i_x87_st_src, // 输入信号

    // Main execute-unit outputs
    output logic [31: 0]        o_agu_effective_addr, // 输出信号
    output logic                o_br_taken, // 输出信号
    output logic [31: 0]        o_br_target_eip, // 输出信号
    output logic [31: 0]        o_md_lo, // 输出信号
    output logic [31: 0]        o_md_hi, // 输出信号
    output logic                o_md_div0, // 输出信号
    output logic [31: 0]        o_int_result, // 输出信号
    output logic                o_int_cf, // 输出信号
    output logic                o_int_af, // 输出信号
    output logic                o_int_zf, // 输出信号
    output logic [63: 0]        o_x87_st0, // 输出信号
    output logic [63: 0]        o_x87_st1, // 输出信号
    output logic                o_x87_zf, // 输出信号
    output logic                o_x87_pf, // 输出信号
    output logic                o_x87_cf, // 输出信号

    input  logic                clk, // 时钟信号
    input  logic                rst_n // 复位信号
);


endmodule
