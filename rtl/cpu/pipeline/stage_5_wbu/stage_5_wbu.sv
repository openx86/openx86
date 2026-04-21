/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: stage_5_wbu wrapper for write_back_stage commit path.
*/
// ============================================================================
// stage_5_wbu
// ----------------------------------------------------------------------------
// Stage 5 WBU:
// - forwards writeback controls/data to architectural register file ports
// - forwards memory commit bundle to external core bus channel
// ============================================================================

module stage_5_wbu (
    input  logic          i_stage4_valid, // 输入信号
    output logic          o_stage_valid, // 输出信号
    input  logic          i_stage5_ready, // 输入信号
    output logic          o_stage4_ready, // 输出信号

    input  logic          i_gpr_write_enable, // 输入信号
    input  logic [ 2: 0]  i_gpr_write_index, // 输入信号
    input  logic [31: 0]  i_gpr_write_data, // 输入信号
    output logic          o_gpr_write_enable, // 输出信号
    output logic [ 2: 0]  o_gpr_write_index, // 输出信号
    output logic [31: 0]  o_gpr_write_data, // 输出信号

    input  logic          i_sreg_write_enable, // 输入信号
    input  logic [ 2: 0]  i_sreg_write_index, // 输入信号
    input  logic [15: 0]  i_sreg_write_selector, // 输入信号
    input  logic [63: 0]  i_sreg_write_descriptor, // 输入信号
    output logic          o_sreg_write_enable, // 输出信号
    output logic [ 2: 0]  o_sreg_write_index, // 输出信号
    output logic [15: 0]  o_sreg_write_selector, // 输出信号
    output logic [63: 0]  o_sreg_write_descriptor, // 输出信号

    input  logic          i_flags_write_enable, // 输入信号
    input  logic [31: 0]  i_flags_write_data, // 输入信号
    output logic          o_flags_write_enable, // 输出信号
    output logic [31: 0]  o_flags_write_data, // 输出信号

    input  logic          i_ip_write_enable, // 输入信号
    input  logic [31: 0]  i_ip_write_data, // 输入信号
    output logic          o_ip_write_enable, // 输出信号
    output logic [31: 0]  o_ip_write_data, // 输出信号

    input  logic          i_cr_write_enable, // 输入信号
    input  logic [ 2: 0]  i_cr_write_index, // 输入信号
    input  logic [31: 0]  i_cr_write_data, // 输入信号
    output logic          o_cr_write_enable, // 输出信号
    output logic [ 2: 0]  o_cr_write_index, // 输出信号
    output logic [31: 0]  o_cr_write_data, // 输出信号

    input  logic          i_dr_write_enable, // 输入信号
    input  logic [ 2: 0]  i_dr_write_index, // 输入信号
    input  logic [31: 0]  i_dr_write_data, // 输入信号
    output logic          o_dr_write_enable, // 输出信号
    output logic [ 2: 0]  o_dr_write_index, // 输出信号
    output logic [31: 0]  o_dr_write_data, // 输出信号

    input  logic          i_tr_write_enable, // 输入信号
    input  logic [ 2: 0]  i_tr_write_index, // 输入信号
    input  logic [31: 0]  i_tr_write_data, // 输入信号
    output logic          o_tr_write_enable, // 输出信号
    output logic [ 2: 0]  o_tr_write_index, // 输出信号
    output logic [31: 0]  o_tr_write_data, // 输出信号

    input  logic          i_mem_valid, // 输入信号
    input  logic          i_mem_write_enable, // 输入信号
    input  logic [31: 0]  i_mem_address, // 输入信号
    input  logic [31: 0]  i_mem_write_data, // 输入信号
    output logic          o_mem_valid, // 输出信号
    output logic          o_mem_write_enable, // 输出信号
    output logic [31: 0]  o_mem_address, // 输出信号
    output logic [31: 0]  o_mem_write_data, // 输出信号

    input  logic          clk, // 时钟信号
    input  logic          rst_n // 复位信号
);

    write_back_stage u_stage_5_wbu_main (
        .i_stage4_valid         ( i_stage4_valid ),
        .o_stage_valid          ( o_stage_valid ),
        .i_stage5_ready         ( i_stage5_ready ),
        .o_stage4_ready         ( o_stage4_ready ),
        .i_gpr_write_enable     ( i_gpr_write_enable ),
        .i_gpr_write_index      ( i_gpr_write_index ),
        .i_gpr_write_data       ( i_gpr_write_data ),
        .o_gpr_write_enable     ( o_gpr_write_enable ),
        .o_gpr_write_index      ( o_gpr_write_index ),
        .o_gpr_write_data       ( o_gpr_write_data ),
        .i_sreg_write_enable    ( i_sreg_write_enable ),
        .i_sreg_write_index     ( i_sreg_write_index ),
        .i_sreg_write_selector  ( i_sreg_write_selector ),
        .i_sreg_write_descriptor( i_sreg_write_descriptor ),
        .o_sreg_write_enable    ( o_sreg_write_enable ),
        .o_sreg_write_index     ( o_sreg_write_index ),
        .o_sreg_write_selector  ( o_sreg_write_selector ),
        .o_sreg_write_descriptor( o_sreg_write_descriptor ),
        .i_flags_write_enable   ( i_flags_write_enable ),
        .i_flags_write_data     ( i_flags_write_data ),
        .o_flags_write_enable   ( o_flags_write_enable ),
        .o_flags_write_data     ( o_flags_write_data ),
        .i_ip_write_enable      ( i_ip_write_enable ),
        .i_ip_write_data        ( i_ip_write_data ),
        .o_ip_write_enable      ( o_ip_write_enable ),
        .o_ip_write_data        ( o_ip_write_data ),
        .i_cr_write_enable      ( i_cr_write_enable ),
        .i_cr_write_index       ( i_cr_write_index ),
        .i_cr_write_data        ( i_cr_write_data ),
        .o_cr_write_enable      ( o_cr_write_enable ),
        .o_cr_write_index       ( o_cr_write_index ),
        .o_cr_write_data        ( o_cr_write_data ),
        .i_dr_write_enable      ( i_dr_write_enable ),
        .i_dr_write_index       ( i_dr_write_index ),
        .i_dr_write_data        ( i_dr_write_data ),
        .o_dr_write_enable      ( o_dr_write_enable ),
        .o_dr_write_index       ( o_dr_write_index ),
        .o_dr_write_data        ( o_dr_write_data ),
        .i_tr_write_enable      ( i_tr_write_enable ),
        .i_tr_write_index       ( i_tr_write_index ),
        .i_tr_write_data        ( i_tr_write_data ),
        .o_tr_write_enable      ( o_tr_write_enable ),
        .o_tr_write_index       ( o_tr_write_index ),
        .o_tr_write_data        ( o_tr_write_data ),
        .i_mem_valid            ( i_mem_valid ),
        .i_mem_write_enable     ( i_mem_write_enable ),
        .i_mem_address          ( i_mem_address ),
        .i_mem_write_data       ( i_mem_write_data ),
        .o_mem_valid            ( o_mem_valid ),
        .o_mem_write_enable     ( o_mem_write_enable ),
        .o_mem_address          ( o_mem_address ),
        .o_mem_write_data       ( o_mem_write_data )
    );

    // Keep lint clean while write_back_stage remains combinational/no-reset.
    /* verilator lint_off UNUSEDSIGNAL */
    logic unused_clk_rst;
    assign unused_clk_rst = clk ^ rst_n;
    /* verilator lint_on UNUSEDSIGNAL */

endmodule
