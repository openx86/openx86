/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_5_wrb_wb_write_back_unit.
*/
// ============================================================================
// stage_5_wrb_wb_write_back_unit
// ----------------------------------------------------------------------------
// Execute stage write-back arbiter/pass-through.
//
// Current integration keeps behavior equivalent to legacy core by forwarding
// execute intents directly to architectural register files and memory bus.
// The dedicated unit provides a single place for future hazard checks,
// priority arbitration, and commit logging.
// ============================================================================

module stage_5_wrb_wb_write_back_unit (
    // --- GPR ---
    input  logic        i_gpr_write_enable,
    input  logic [ 2:0] i_gpr_write_index,
    input  logic [31:0] i_gpr_write_data,
    output logic        o_gpr_write_enable,
    output logic [ 2:0] o_gpr_write_index,
    output logic [31:0] o_gpr_write_data,

    // --- Segment registers ---
    input  logic        i_sreg_write_enable,
    input  logic [ 2:0] i_sreg_write_index,
    input  logic [15:0] i_sreg_write_selector,
    input  logic [63:0] i_sreg_write_descriptor,
    output logic        o_sreg_write_enable,
    output logic [ 2:0] o_sreg_write_index,
    output logic [15:0] o_sreg_write_selector,
    output logic [63:0] o_sreg_write_descriptor,

    // --- FLAGS/EIP ---
    input  logic        i_flags_write_enable,
    input  logic [31:0] i_flags_write_data,
    output logic        o_flags_write_enable,
    output logic [31:0] o_flags_write_data,

    input  logic        i_ip_write_enable,
    input  logic [31:0] i_ip_write_data,
    output logic        o_ip_write_enable,
    output logic [31:0] o_ip_write_data,

    // --- Control/Debug/Test registers ---
    input  logic        i_cr_write_enable,
    input  logic [ 2:0] i_cr_write_index,
    input  logic [31:0] i_cr_write_data,
    output logic        o_cr_write_enable,
    output logic [ 2:0] o_cr_write_index,
    output logic [31:0] o_cr_write_data,

    input  logic        i_dr_write_enable,
    input  logic [ 2:0] i_dr_write_index,
    input  logic [31:0] i_dr_write_data,
    output logic        o_dr_write_enable,
    output logic [ 2:0] o_dr_write_index,
    output logic [31:0] o_dr_write_data,

    input  logic        i_tr_write_enable,
    input  logic [ 2:0] i_tr_write_index,
    input  logic [31:0] i_tr_write_data,
    output logic        o_tr_write_enable,
    output logic [ 2:0] o_tr_write_index,
    output logic [31:0] o_tr_write_data,

    // --- Memory bus commit path ---
    input  logic        i_mem_valid,
    input  logic        i_mem_write_enable,
    input  logic [31:0] i_mem_address,
    input  logic [31:0] i_mem_write_data,
    output logic        o_mem_valid,
    output logic        o_mem_write_enable,
    output logic [31:0] o_mem_address,
    output logic [31:0] o_mem_write_data
);

    always_comb begin
        o_gpr_write_enable = i_gpr_write_enable;
        o_gpr_write_index  = i_gpr_write_index;
        o_gpr_write_data   = i_gpr_write_data;

        o_sreg_write_enable     = i_sreg_write_enable;
        o_sreg_write_index      = i_sreg_write_index;
        o_sreg_write_selector   = i_sreg_write_selector;
        o_sreg_write_descriptor = i_sreg_write_descriptor;

        o_flags_write_enable = i_flags_write_enable;
        o_flags_write_data   = i_flags_write_data;

        o_ip_write_enable = i_ip_write_enable;
        o_ip_write_data   = i_ip_write_data;

        o_cr_write_enable = i_cr_write_enable;
        o_cr_write_index  = i_cr_write_index;
        o_cr_write_data   = i_cr_write_data;

        o_dr_write_enable = i_dr_write_enable;
        o_dr_write_index  = i_dr_write_index;
        o_dr_write_data   = i_dr_write_data;

        o_tr_write_enable = i_tr_write_enable;
        o_tr_write_index  = i_tr_write_index;
        o_tr_write_data   = i_tr_write_data;

        o_mem_valid        = i_mem_valid;
        o_mem_write_enable = i_mem_write_enable;
        o_mem_address      = i_mem_address;
        o_mem_write_data   = i_mem_write_data;
    end

endmodule
