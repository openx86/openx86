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
//  File        : memory_management_unit.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : memory_management_unit module
// ============================================================================

/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: memory_management_unit
create at: 2022-02-04 23:34:40
description: memory_management_unit
*/

module memory_management_unit #(
    parameter bit read_from_fetch = 1'b0
) (
    // =========================
    // handshake with upstream address request
    // =========================
    input  logic          i_valid,
    output logic          o_ready,

    // =========================
    // address translation context (segment + paging inputs)
    // =========================
    input  logic          i_protected_mode,
    input  logic [ 5: 0][15: 0] i_segment_selector,
    input  logic [ 5: 0][63: 0] i_segment_descriptor,
    input  logic [ 1: 0]        i_current_privilege_level,
    input  logic [ 2: 0]        i_segment_index,
    input  logic [31: 0]        i_effective_address,
    input  logic                 i_write_enable,
    input  logic                 i_paging_enable,
    input  logic [31: 0]        i_page_directory_base,
    output logic [31: 0]        o_physical_address,
    output logic                 o_segment_fault,

    // =========================
    // bus for paging walks (two-level page table reads)
    // =========================
    output logic                 o_bus_valid,
    input  logic                 i_bus_ready,
    output logic                 o_bus_write_enable,
    output logic [31: 0]        o_bus_address,
    input  logic [31: 0]        i_bus_data_read,
    output logic [31: 0]        o_bus_data_write,

    // =========================
    // clock and reset
    // =========================
    input  logic                 clk,
    input  logic                 rst_n
);

    // ============================================================
    // intermediate signals
    // ============================================================
    logic [31: 0] linear_address;
    logic [31: 0] physical_address;

    logic         paging_valid;
    logic         paging_ready;
    logic         seg_priv_err;

    // ============================================================
    // segmentation unit
    // ============================================================
    segmentation_unit #(
        .read_from_fetch (read_from_fetch)
    ) segmentation_unit (
    .i_protected_mode           (i_protected_mode),
    .i_segment_selector         (i_segment_selector),
    .i_segment_descriptor       (i_segment_descriptor),
    .i_current_privilege_level  (i_current_privilege_level),
    .i_segment_index            (i_segment_index),
    .i_effective_address        (i_effective_address),
    .i_write_enable             (i_write_enable),
    .o_linear_address           (linear_address),
    .o_segment_privilege_error  (seg_priv_err),
    .clk                        (clk),
    .rst_n                      (rst_n)
);

    // ============================================================
    // paging unit
    // ============================================================
    paging_unit paging_unit (
    .i_valid             (paging_valid),
    .o_ready             (paging_ready),
    .i_linear_address    (linear_address),
    .i_page_directory_base (i_page_directory_base),
    .o_physical_address  (physical_address),
    .o_bus_valid         (o_bus_valid),
    .i_bus_ready         (i_bus_ready),
    .o_bus_write_enable  (o_bus_write_enable),
    .o_bus_address       (o_bus_address),
    .i_bus_data_read     (i_bus_data_read),
    .o_bus_data_write    (o_bus_data_write),
    .clk                 (clk),
    .rst_n               (rst_n)
);


// MMU 组合状态：空闲 →（可选）等分页 → 输出物理或线性
enum logic [ 1: 0] {
    STATE_WAIT_FOR_PAGING_UNIT_READY = 2'h1, // 等待页表两级读完成
    STATE_OUTPUT_LINEAR_ADDRESS = 2'h2,      // 未分页：直接输出线性地址
    STATE_WAIT_FOR_VAILD = 2'h0              // 等待新请求
} state;

// 顺序控制：分页关闭时一拍完成；开启时委托 paging_unit
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= STATE_WAIT_FOR_VAILD;
        o_ready <= 0;
    end else begin
        unique case (state)
            STATE_WAIT_FOR_VAILD: begin
                if (i_valid) begin
                    o_ready       <= 0;
                    if (i_paging_enable) begin
                        state          <= STATE_WAIT_FOR_PAGING_UNIT_READY;
                        paging_valid   <= 1;
                    end else begin
                        state          <= STATE_OUTPUT_LINEAR_ADDRESS;
                        paging_valid   <= 0;
                    end
                end else begin
                    state          <= STATE_WAIT_FOR_VAILD;
                    paging_valid   <= 0;
                end
            end
            STATE_WAIT_FOR_PAGING_UNIT_READY: begin
                if (paging_ready) begin
                    state <= STATE_WAIT_FOR_VAILD;
                    o_ready <= 1;
                    o_physical_address <= physical_address;
                end else begin
                    state <= STATE_WAIT_FOR_PAGING_UNIT_READY;
                    o_ready <= 0;
                    o_physical_address <= o_physical_address;
                end
            end
            STATE_OUTPUT_LINEAR_ADDRESS: begin
                state <= STATE_WAIT_FOR_VAILD;
                o_ready <= 1;
                o_physical_address <= linear_address;
            end
            default: begin
                state <= STATE_WAIT_FOR_VAILD;
            end
        endcase
    end
end

assign o_segment_fault = seg_priv_err;

endmodule
