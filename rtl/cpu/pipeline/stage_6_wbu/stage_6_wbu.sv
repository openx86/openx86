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
//  File        : stage_6_wbu.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_6_wbu module
// ============================================================================

module stage_6_wbu (
    input  logic          i_stage4_valid,
    output logic          o_stage_valid,
    input  logic          i_stage5_ready,
    output logic          o_stage4_ready,

    input  logic          i_gpr_write_enable,
    input  logic [ 2: 0]  i_gpr_write_index,
    input  logic [31: 0]  i_gpr_write_data,
    output logic          o_gpr_write_enable,
    output logic [ 2: 0]  o_gpr_write_index,
    output logic [31: 0]  o_gpr_write_data,

    input  logic          i_sreg_write_enable,
    input  logic [ 2: 0]  i_sreg_write_index,
    input  logic [15: 0]  i_sreg_write_selector,
    input  logic [63: 0]  i_sreg_write_descriptor,
    output logic          o_sreg_write_enable,
    output logic [ 2: 0]  o_sreg_write_index,
    output logic [15: 0]  o_sreg_write_selector,
    output logic [63: 0]  o_sreg_write_descriptor,

    input  logic          i_flags_write_enable,
    input  logic [31: 0]  i_flags_write_data,
    output logic          o_flags_write_enable,
    output logic [31: 0]  o_flags_write_data,

    input  logic          i_ip_write_enable,
    input  logic [31: 0]  i_ip_write_data,
    output logic          o_ip_write_enable,
    output logic [31: 0]  o_ip_write_data,

    input  logic          i_cr_write_enable,
    input  logic [ 2: 0]  i_cr_write_index,
    input  logic [31: 0]  i_cr_write_data,
    output logic          o_cr_write_enable,
    output logic [ 2: 0]  o_cr_write_index,
    output logic [31: 0]  o_cr_write_data,

    input  logic          i_dr_write_enable,
    input  logic [ 2: 0]  i_dr_write_index,
    input  logic [31: 0]  i_dr_write_data,
    output logic          o_dr_write_enable,
    output logic [ 2: 0]  o_dr_write_index,
    output logic [31: 0]  o_dr_write_data,

    input  logic          i_tr_write_enable,
    input  logic [ 2: 0]  i_tr_write_index,
    input  logic [31: 0]  i_tr_write_data,
    output logic          o_tr_write_enable,
    output logic [ 2: 0]  o_tr_write_index,
    output logic [31: 0]  o_tr_write_data,

    input  logic          i_mem_valid,
    input  logic          i_mem_write_enable,
    input  logic [31: 0]  i_mem_address,
    input  logic [31: 0]  i_mem_write_data,
    output logic          o_mem_valid,
    output logic          o_mem_write_enable,
    output logic [31: 0]  o_mem_address,
    output logic [31: 0]  o_mem_write_data,

    input  logic          clk, // 时钟信号
    input  logic          rst_n // 复位信号
);

    // Simple pass-through logic
    assign o_stage_valid          = i_stage4_valid;
    assign o_stage4_ready         = i_stage5_ready;
    assign o_gpr_write_enable     = i_gpr_write_enable;
    assign o_gpr_write_index      = i_gpr_write_index;
    assign o_gpr_write_data       = i_gpr_write_data;
    assign o_sreg_write_enable    = i_sreg_write_enable;
    assign o_sreg_write_index     = i_sreg_write_index;
    assign o_sreg_write_selector  = i_sreg_write_selector;
    assign o_sreg_write_descriptor = i_sreg_write_descriptor;
    assign o_flags_write_enable   = i_flags_write_enable;
    assign o_flags_write_data     = i_flags_write_data;
    assign o_ip_write_enable      = i_ip_write_enable;
    assign o_ip_write_data        = i_ip_write_data;
    assign o_cr_write_enable      = i_cr_write_enable;
    assign o_cr_write_index       = i_cr_write_index;
    assign o_cr_write_data        = i_cr_write_data;
    assign o_dr_write_enable      = i_dr_write_enable;
    assign o_dr_write_index       = i_dr_write_index;
    assign o_dr_write_data        = i_dr_write_data;
    assign o_tr_write_enable      = i_tr_write_enable;
    assign o_tr_write_index       = i_tr_write_index;
    assign o_tr_write_data        = i_tr_write_data;
    assign o_mem_valid            = i_mem_valid;
    assign o_mem_write_enable     = i_mem_write_enable;
    assign o_mem_address          = i_mem_address;
    assign o_mem_write_data       = i_mem_write_data;

endmodule
