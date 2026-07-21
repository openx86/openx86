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
//  File        : lsu_mmu_translate.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Data-side MMU translation before memory_stage access
// ============================================================================

`include "openx86_defs.h.sv"

module lsu_mmu_translate (
    input  logic          i_start,
    input  logic          i_is_write,
    input  logic [31: 0] i_effective_address,
    input  logic [ 2: 0] i_segment_index,
    input  logic          i_protected_mode,
    input  logic [ 5: 0][15: 0] i_segment_selector,
    input  logic [ 5: 0][63: 0] i_segment_descriptor,
    input  logic [ 1: 0]        i_cpl,
    input  logic                 i_paging_enable,
    input  logic [31: 0]        i_page_directory_base,

    output logic          o_done,
    output logic          o_busy,
    output logic [31: 0] o_physical_address,
    output logic          o_segment_fault,
    output logic          o_page_fault,
    output logic          o_fault_present,
    output logic [31: 0] o_fault_linear_address,

    output logic          o_mmu_bus_valid,
    input  logic          i_mmu_bus_ready,
    output logic [31: 0] o_mmu_bus_addr,
    input  logic [31: 0] i_mmu_bus_rdata,

    input  logic          clk,
    input  logic          rst_n
);

    logic         mmu_valid;
    logic         mmu_ready;
    logic         mmu_bus_we;
    logic [31: 0] mmu_bus_wdata;
    logic         active_r;
    // Latch translate request: EXU may retire / change reg_uop while LSU is busy.
    logic         latched_is_write;
    logic [31: 0] latched_eff_addr;
    logic [ 2: 0] latched_seg_index;

    memory_management_unit #(
        .read_from_fetch (1'b0)
    ) u_lsu_mmu (
        .i_valid                 (mmu_valid),
        .o_ready                 (mmu_ready),
        .i_protected_mode        (i_protected_mode),
        .i_segment_selector      (i_segment_selector),
        .i_segment_descriptor    (i_segment_descriptor),
        .i_current_privilege_level (i_cpl),
        .i_segment_index         (latched_seg_index),
        .i_effective_address     (latched_eff_addr),
        .i_write_enable          (latched_is_write),
        .i_paging_enable         (i_paging_enable),
        .i_page_directory_base   (i_page_directory_base),
        .o_physical_address      (o_physical_address),
        .o_segment_fault         (o_segment_fault),
        .o_page_fault            (o_page_fault),
        .o_fault_present         (o_fault_present),
        .o_fault_linear_address  (o_fault_linear_address),
        .o_bus_valid             (o_mmu_bus_valid),
        .i_bus_ready             (i_mmu_bus_ready),
        .o_bus_write_enable      (mmu_bus_we),
        .o_bus_address           (o_mmu_bus_addr),
        .i_bus_data_read         (i_mmu_bus_rdata),
        .o_bus_data_write        (mmu_bus_wdata),
        .clk                     (clk),
        .rst_n                   (rst_n)
    );

    assign mmu_valid = active_r;
    assign o_busy    = active_r & ~o_done;
    assign o_done    = active_r & mmu_ready;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            active_r          <= 1'b0;
            latched_is_write  <= 1'b0;
            latched_eff_addr  <= 32'h0;
            latched_seg_index <= 3'b0;
        end else begin
            if (i_start && ~active_r) begin
                active_r          <= 1'b1;
                latched_is_write  <= i_is_write;
                latched_eff_addr  <= i_effective_address;
                latched_seg_index <= i_segment_index;
            end else if (o_done) begin
                active_r <= 1'b0;
            end
        end
    end

    logic unused_lsu_mmu;
    assign unused_lsu_mmu = mmu_bus_we ^ mmu_bus_wdata[0];

endmodule
