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
//  File        : execute_unit.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : execute_unit module
// ============================================================================

// ============================================================================
// execute_unit — wires cpuid.sv + cache_invalidate.sv
// ============================================================================

module execute_unit (
    input  logic          insn_fire,
    input  logic          op_cpuid,
    input  logic [31: 0]  gpr_eax,
    input  logic [31: 0]  gpr_ecx,
    output logic         cpuid_busy,
    output logic         gpr_wr_en,
    output logic [ 2: 0] gpr_wr_idx,
    output logic [31: 0] gpr_wr_data,
    output logic         cpuid_done_pulse,
    input  logic          op_invd,
    input  logic          op_wbinvd,
    input  logic          op_invlpg,
    input  logic [31: 0] invlpg_ea,
    output logic         cache_flush_pulse,
    output logic         invlpg_pulse,
    output logic [31: 0] invlpg_linear_addr,
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
