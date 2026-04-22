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
//  File        : prefetch_unit.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : prefetch_unit module
// ============================================================================

module prefetch_unit (
    // =========================
    // instruction fetch bus interface
    // =========================
    output logic         o_code_valid,
    input  logic          i_code_ready,
    output logic [31: 0] o_code_address,
    input  logic [31: 0] i_code_data_read,

    // =========================
    // MMU backend bus interface (for page table walks)
    // =========================
    output logic         o_mmu_bus_valid,
    input  logic          i_mmu_bus_ready,
    output logic [31: 0] o_mmu_bus_addr,
    input  logic [31: 0] i_mmu_bus_rdata,

    // =========================
    // CPU execution context inputs
    // =========================
    input  logic          i_protected_mode,
    input  logic [ 5: 0][15: 0] i_segment_selector,
    input  logic [ 5: 0][63: 0] i_segment_descriptor,
    input  logic [ 1: 0]        i_current_privilege_level,
    input  logic                 i_paging_enable,
    input  logic [31: 0]        i_page_directory_base,
    input  logic                 i_IP_valid,

    // =========================
    // decoded instruction stream outputs
    // =========================
    output logic [15: 0][ 7: 0] o_instruction,
    output logic                 o_instruction_ready,
    output logic                 o_segment_fault,

    // =========================
    // clock and reset
    // =========================
    input  logic [31: 0]        i_eip,
    input  logic                 rst_n,
    input  logic                 clk
);

    // ============================================================
    // instruction fetch with segment/paging translation wrapper
    // ============================================================
    instruction_fetch u_if_instruction_fetch (
        .o_code_valid              (o_code_valid),
        .i_code_ready              (i_code_ready),
        .o_code_address            (o_code_address),
        .i_code_data_read          (i_code_data_read),
        .o_mmu_bus_valid           (o_mmu_bus_valid),
        .i_mmu_bus_ready           (i_mmu_bus_ready),
        .o_mmu_bus_addr            (o_mmu_bus_addr),
        .i_mmu_bus_rdata           (i_mmu_bus_rdata),
        .i_protected_mode          (i_protected_mode),
        .i_segment_selector        (i_segment_selector),
        .i_segment_descriptor      (i_segment_descriptor),
        .i_current_privilege_level (i_current_privilege_level),
        .i_paging_enable           (i_paging_enable),
        .i_page_directory_base     (i_page_directory_base),
        .i_IP_valid                (i_IP_valid),
        .o_instruction             (o_instruction),
        .o_instruction_ready       (o_instruction_ready),
        .o_segment_fault           (o_segment_fault),
        .i_eip                     (i_eip),
        .clk                       (clk),
        .rst_n                     (rst_n)
    );

endmodule
