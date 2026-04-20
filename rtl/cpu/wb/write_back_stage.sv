/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements write_back_stage.
*/
// ============================================================================
// write_back_stage
// ----------------------------------------------------------------------------
// Stage 5 (WRB / write-back): wraps commit forwarding to architectural state.
// ============================================================================

module write_back_stage (    input  logic          i_stage4_valid,    // MEM 段有效（WRB 与之对齐）
    output logic         o_stage_valid,     // WRB 段有效（当前等同直通 stage4）

    // --- GPR 写回 ---
    input  logic          i_gpr_write_enable,
    input  logic [ 2: 0] i_gpr_write_index,
    input  logic [31: 0] i_gpr_write_data,
    output logic         o_gpr_write_enable,
    output logic [ 2: 0] o_gpr_write_index,
    output logic [31: 0] o_gpr_write_data,

    // --- 段寄存器写回（选择子 + 隐藏描述符）---
    input  logic          i_sreg_write_enable,
    input  logic [ 2: 0] i_sreg_write_index,
    input  logic [15: 0] i_sreg_write_selector,
    input  logic [63: 0] i_sreg_write_descriptor,
    output logic         o_sreg_write_enable,
    output logic [ 2: 0] o_sreg_write_index,
    output logic [15: 0] o_sreg_write_selector,
    output logic [63: 0] o_sreg_write_descriptor,

    // --- EFLAGS ---
    input  logic          i_flags_write_enable,
    input  logic [31: 0] i_flags_write_data,
    output logic         o_flags_write_enable,
    output logic [31: 0] o_flags_write_data,

    // --- EIP ---
    input  logic          i_ip_write_enable,
    input  logic [31: 0] i_ip_write_data,
    output logic         o_ip_write_enable,
    output logic [31: 0] o_ip_write_data,

    // --- 控制寄存器 CR ---
    input  logic          i_cr_write_enable,
    input  logic [ 2: 0] i_cr_write_index,
    input  logic [31: 0] i_cr_write_data,
    output logic         o_cr_write_enable,
    output logic [ 2: 0] o_cr_write_index,
    output logic [31: 0] o_cr_write_data,

    // --- 调试寄存器 DR ---
    input  logic          i_dr_write_enable,
    input  logic [ 2: 0] i_dr_write_index,
    input  logic [31: 0] i_dr_write_data,
    output logic         o_dr_write_enable,
    output logic [ 2: 0] o_dr_write_index,
    output logic [31: 0] o_dr_write_data,

    // --- 测试寄存器 TR ---
    input  logic          i_tr_write_enable,
    input  logic [ 2: 0] i_tr_write_index,
    input  logic [31: 0] i_tr_write_data,
    output logic         o_tr_write_enable,
    output logic [ 2: 0] o_tr_write_index,
    output logic [31: 0] o_tr_write_data,

    // --- 提交到总线/存储的路径（与寄存器写回并行）---
    input  logic          i_mem_valid,
    input  logic          i_mem_write_enable,
    input  logic [31: 0] i_mem_address,
    input  logic [31: 0] i_mem_write_data,
    output logic         o_mem_valid,
    output logic         o_mem_write_enable,
    output logic [31: 0] o_mem_address,
    output logic [31: 0] o_mem_write_data
);

    // 写回仲裁/直通占位：便于日后加冒险与提交顺序
    write_back_unit u_wb_write_back_unit (
        .i_gpr_write_enable    ( i_gpr_write_enable ),
        .i_gpr_write_index     ( i_gpr_write_index ),
        .i_gpr_write_data      ( i_gpr_write_data ),
        .o_gpr_write_enable    ( o_gpr_write_enable ),
        .o_gpr_write_index     ( o_gpr_write_index ),
        .o_gpr_write_data      ( o_gpr_write_data ),
        .i_sreg_write_enable   ( i_sreg_write_enable ),
        .i_sreg_write_index    ( i_sreg_write_index ),
        .i_sreg_write_selector ( i_sreg_write_selector ),
        .i_sreg_write_descriptor ( i_sreg_write_descriptor ),
        .o_sreg_write_enable   ( o_sreg_write_enable ),
        .o_sreg_write_index    ( o_sreg_write_index ),
        .o_sreg_write_selector ( o_sreg_write_selector ),
        .o_sreg_write_descriptor ( o_sreg_write_descriptor ),
        .i_flags_write_enable  ( i_flags_write_enable ),
        .i_flags_write_data    ( i_flags_write_data ),
        .o_flags_write_enable  ( o_flags_write_enable ),
        .o_flags_write_data    ( o_flags_write_data ),
        .i_ip_write_enable     ( i_ip_write_enable ),
        .i_ip_write_data       ( i_ip_write_data ),
        .o_ip_write_enable     ( o_ip_write_enable ),
        .o_ip_write_data       ( o_ip_write_data ),
        .i_cr_write_enable     ( i_cr_write_enable ),
        .i_cr_write_index      ( i_cr_write_index ),
        .i_cr_write_data       ( i_cr_write_data ),
        .o_cr_write_enable     ( o_cr_write_enable ),
        .o_cr_write_index      ( o_cr_write_index ),
        .o_cr_write_data       ( o_cr_write_data ),
        .i_dr_write_enable     ( i_dr_write_enable ),
        .i_dr_write_index      ( i_dr_write_index ),
        .i_dr_write_data       ( i_dr_write_data ),
        .o_dr_write_enable     ( o_dr_write_enable ),
        .o_dr_write_index      ( o_dr_write_index ),
        .o_dr_write_data       ( o_dr_write_data ),
        .i_tr_write_enable     ( i_tr_write_enable ),
        .i_tr_write_index      ( i_tr_write_index ),
        .i_tr_write_data       ( i_tr_write_data ),
        .o_tr_write_enable     ( o_tr_write_enable ),
        .o_tr_write_index      ( o_tr_write_index ),
        .o_tr_write_data       ( o_tr_write_data ),
        .i_mem_valid           ( i_mem_valid ),
        .i_mem_write_enable    ( i_mem_write_enable ),
        .i_mem_address         ( i_mem_address ),
        .i_mem_write_data      ( i_mem_write_data ),
        .o_mem_valid           ( o_mem_valid ),
        .o_mem_write_enable    ( o_mem_write_enable ),
        .o_mem_address         ( o_mem_address ),
        .o_mem_write_data      ( o_mem_write_data )
    );

    assign o_stage_valid = i_stage4_valid;

endmodule
