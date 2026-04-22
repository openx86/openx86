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
//
// i486 扩展单元包装器：
// - CPUID 指令实现（cpuid 模块）
// - 缓存失效指令实现（cache_invalidate 模块）
// ============================================================================

module i486_execute_unit #(
    // ========================================
    // CPUID 参数传递
    // ========================================
    parameter logic [31: 0] P_CPUID_VENDOR_EBX = 32'h756e6547,
    parameter logic [31: 0] P_CPUID_VENDOR_EDX = 32'h49656e69,
    parameter logic [31: 0] P_CPUID_VENDOR_ECX = 32'h6c65746e,
    parameter logic [ 3: 0] P_CPUID_STEPPING_ID = 4'h0,
    parameter logic [ 3: 0] P_CPUID_MODEL_ID    = 4'h0,
    parameter logic [ 3: 0] P_CPUID_FAMILY_ID   = 4'h6,
    parameter logic [ 1: 0] P_CPUID_PROCESSOR_TYPE = 2'b0,
    parameter logic [ 3: 0] P_CPUID_EXTENDED_MODEL = 4'h0,
    parameter logic [ 7: 0] P_CPUID_EXTENDED_FAMILY = 8'h0,
    parameter logic [31: 0] P_CPUID_MAX_LEAF = 32'd1,
    parameter logic [31: 0] P_CPUID_FEATURE_EDX = 32'h00000001
) (
    input  logic          insn_fire,              // 指令触发信号
    input  logic          op_cpuid,               // CPUID 操作使能
    input  logic [31: 0]  gpr_eax,                // 输入：EAX 寄存器
    input  logic [31: 0]  gpr_ecx,                // 输入：ECX 寄存器
    output logic         cpuid_busy,             // 输出：CPUID 忙标志
    output logic         gpr_wr_en,              // 输出：GPR 写使能
    output logic [ 2: 0] gpr_wr_idx,             // 输出：GPR 写索引
    output logic [31: 0] gpr_wr_data,            // 输出：GPR 写数据
    output logic         cpuid_done_pulse,       // 输出：CPUID 完成脉冲
    input  logic          op_invd,                // INVD 指令使能
    input  logic          op_wbinvd,              // WBINVD 指令使能
    input  logic          op_invlpg,              // INVLPG 指令使能
    input  logic [31: 0] invlpg_ea,              // INVLPG 有效地址
    output logic         cache_flush_pulse,      // 输出：缓存刷新脉冲
    output logic         invlpg_pulse,           // 输出：INVLPG 脉冲
    output logic [31: 0] invlpg_linear_addr,     // 输出：INVLPG 线性地址
    input  logic          clk,                    // 时钟信号
    input  logic          rst_n                   // 异步低有效复位
);

    // ========================================
    // CPUID 子模块实例化
    // ========================================
    i486_cpuid #(
        .P_VENDOR_EBX       ( P_CPUID_VENDOR_EBX ),
        .P_VENDOR_EDX       ( P_CPUID_VENDOR_EDX ),
        .P_VENDOR_ECX       ( P_CPUID_VENDOR_ECX ),
        .P_STEPPING_ID      ( P_CPUID_STEPPING_ID ),
        .P_MODEL_ID         ( P_CPUID_MODEL_ID ),
        .P_FAMILY_ID        ( P_CPUID_FAMILY_ID ),
        .P_PROCESSOR_TYPE   ( P_CPUID_PROCESSOR_TYPE ),
        .P_EXTENDED_MODEL   ( P_CPUID_EXTENDED_MODEL ),
        .P_EXTENDED_FAMILY  ( P_CPUID_EXTENDED_FAMILY ),
        .P_MAX_LEAF         ( P_CPUID_MAX_LEAF ),
        .P_FEATURE_EDX      ( P_CPUID_FEATURE_EDX )
    ) u_cpuid (
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

    // ========================================
    // 缓存失效子模块实例化
    // ========================================
    i486_cache_invalidate u_cache (
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
