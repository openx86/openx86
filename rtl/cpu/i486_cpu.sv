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
//  File        : i486_cpu.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : i486_cpu module
// ============================================================================

module i486_cpu (
    // =========================
    // SoC bus interface
    // =========================
    output logic         bus_vaild,
    input  logic          bus_ready,
    input  logic          bus_busy,
    output logic         bus_write_enable,
    output logic         bus_io_access,
    output logic [31: 0] bus_address,
    input  logic [31: 0] bus_read_data,
    output logic [31: 0] bus_write_data,

    // =========================
    // clock and reset
    // =========================
    input  logic          clk,
    input  logic          rst_n
);

    // ============================================================
    // core to BIU: MMU (page table walk) port
    // ============================================================
    logic        mmu_vaild;
    logic        mmu_ready;
    logic [31: 0] mmu_address;
    logic [31: 0] mmu_data_read;

    // ============================================================
    // core to BIU: instruction fetch port
    // ============================================================
    logic        code_vaild;
    logic        code_ready;
    logic [31: 0] code_address;
    logic [31: 0] code_data_read;

    // ============================================================
    // core to BIU: data load/store port
    // ============================================================
    logic        data_vaild;
    logic        data_ready;
    logic        data_write_enable;
    logic        data_io_access;
    logic [31: 0] data_address;
    logic [31: 0] data_data_read;
    logic [31: 0] data_data_write;

    // ============================================================
    // CPU microarchitecture implementation (MMU/fetch/data three main ports)
    // ============================================================
    i486_cpu_core cpu_core_0 (
        .o_mmu_vaild        (mmu_vaild),
        .i_mmu_ready        (mmu_ready),
        .o_mmu_address      (mmu_address),
        .i_mmu_data_read    (mmu_data_read),
        .o_code_vaild       (code_vaild),
        .i_code_ready       (code_ready),
        .o_code_address     (code_address),
        .i_code_data_read   (code_data_read),
        .o_data_vaild       (data_vaild),
        .i_data_ready       (data_ready),
        .o_data_write_enable(data_write_enable),
        .o_data_io_access   (data_io_access),
        .o_data_address     (data_address),
        .i_data_data_read   (data_data_read),
        .o_data_data_write  (data_data_write),
        .clk              (clk),
        .rst_n            (rst_n)
    );

    // ============================================================
    // bus interface unit: arbitrate and collapse to single valid/ready SoC bus
    // ============================================================
    bus_interface_unit biu_0 (
        .i_mmu_valid        (mmu_vaild),
        .o_mmu_ready        (mmu_ready),
        .i_mmu_address      (mmu_address),
        .o_mmu_data_read    (mmu_data_read),
        .i_code_valid       (code_vaild),
        .o_code_ready       (code_ready),
        .i_code_address     (code_address),
        .o_code_data_read   (code_data_read),
        .i_data_valid       (data_vaild),
        .o_data_ready       (data_ready),
        .i_data_write_enable(data_write_enable),
        .i_data_io_access   (data_io_access),
        .i_data_address     (data_address),
        .o_data_data_read   (data_data_read),
        .i_data_data_write  (data_data_write),
        .o_bus_valid        (bus_vaild),
        .i_bus_ready        (bus_ready & ~bus_busy),  // 忙时不视为完成
        .i_bus_busy         (bus_busy),
        .o_bus_write_enable (bus_write_enable),
        .o_bus_io_access    (bus_io_access),
        .o_bus_address      (bus_address),
        .i_bus_data_read    (bus_read_data),
        .o_bus_data_write   (bus_write_data),
        .clk            (clk),
        .rst_n          (rst_n)
    );

// TODO: shared cache
// TODO: system agent
// TODO: SDRAM controller

endmodule
