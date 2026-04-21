/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Shell integrating i486 CPUID and cache-invalidate extension units.
*/
// ============================================================================
// execute_unit — wires cpuid.sv + cache_invalidate.sv
// ============================================================================

module execute_unit (
    input  logic          insn_fire,
    input  logic          op_cpuid, // 输入信号
    input  logic [31: 0]  gpr_eax, // 输入信号
    input  logic [31: 0]  gpr_ecx, // 输入信号
    output logic         cpuid_busy, // 输出信号
    output logic         gpr_wr_en, // 输出信号
    output logic [ 2: 0] gpr_wr_idx, // 输出信号
    output logic [31: 0] gpr_wr_data, // 输出信号
    output logic         cpuid_done_pulse, // 输出信号
    input  logic          op_invd, // 输入信号
    input  logic          op_wbinvd, // 输入信号
    input  logic          op_invlpg, // 输入信号
    input  logic [31: 0] invlpg_ea, // 输入信号
    output logic         cache_flush_pulse, // 输出信号
    output logic         invlpg_pulse, // 输出信号
    output logic [31: 0] invlpg_linear_addr, // 输出信号
    input  logic          clk, // 时钟信号
    input  logic          rst_n // 复位信号
);

    cpuid u_cpuid (
        .insn_fire          ( insn_fire ),
        .op_cpuid           ( op_cpuid ),
        .gpr_eax            ( gpr_eax ),
        .o_cpuid_busy       ( cpuid_busy ),
        .o_gpr_wr_en        ( gpr_wr_en ),
        .o_gpr_wr_idx       ( gpr_wr_idx ),
        .o_gpr_wr_data      ( gpr_wr_data ),
        .o_cpuid_done_pulse ( cpuid_done_pulse ),
        .clk                ( clk ),
        .rst_n              ( rst_n )
    );

    cache_invalidate u_cache (
        .insn_fire             ( insn_fire ),
        .op_invd               ( op_invd ),
        .op_wbinvd             ( op_wbinvd ),
        .op_invlpg             ( op_invlpg ),
        .invlpg_ea             ( invlpg_ea ),
        .o_cache_flush_pulse   ( cache_flush_pulse ),
        .o_invlpg_pulse        ( invlpg_pulse ),
        .o_invlpg_linear_addr  ( invlpg_linear_addr ),
        .clk                   ( clk ),
        .rst_n                 ( rst_n )
    );

endmodule
