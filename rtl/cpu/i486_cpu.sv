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
//  Description : 80486 pin-level CPU top with integrated cache and BIU
// ============================================================================

module i486_cpu (
    // =========================
    // 80486 external bus
    // =========================
    output logic         o_ads_n,
    output logic [31: 0] o_address,
    output logic [31: 0] o_data_out,
    output logic         o_data_oe,
    input  logic [31: 0] i_data_in,
    output logic [ 3: 0] o_be_n,
    output logic         o_wr_n,
    output logic         o_dc_n,
    output logic         o_mio_n,
    output logic         o_blast_n,
    input  logic         i_bready_n,
    input  logic         i_hold,
    output logic         o_hlda,
    input  logic         i_intr,
    input  logic         i_nmi,
    output logic         o_ferr_n,

    input  logic         clk,
    input  logic         rst_n
);

    logic        mmu_valid;
    logic        mmu_ready;
    logic [31: 0] mmu_address;
    logic [31: 0] mmu_data_read;

    logic        code_valid;
    logic        code_ready;
    logic [31: 0] code_address;
    logic [31: 0] code_data_read;

    logic        data_valid;
    logic        data_ready;
    logic        data_write_enable;
    logic        data_io_access;
    logic [31: 0] data_address;
    logic [31: 0] data_data_read;
    logic [31: 0] data_data_write;

    logic        cache_code_valid;
    logic        cache_code_ready;
    logic [31: 0] cache_code_address;
    logic [31: 0] cache_code_data;

    logic        cache_data_valid;
    logic        cache_data_ready;
    logic        cache_data_write_enable;
    logic        cache_data_io_access;
    logic [31: 0] cache_data_address;
    logic [31: 0] cache_data_wdata;
    logic [31: 0] cache_data_rdata;

    logic        cache_mem_valid;
    logic        cache_mem_ready;
    logic        cache_mem_write;
    logic        cache_mem_io;
    logic        cache_mem_code;
    logic [31: 0] cache_mem_address;
    logic [31: 0] cache_mem_wdata;
    logic [31: 0] cache_mem_rdata;

    logic        biu_bus_valid;
    logic        biu_bus_ready;
    logic        biu_bus_write_enable;
    logic        biu_bus_io_access;
    logic [31: 0] biu_bus_address;
    logic [31: 0] biu_bus_read_data;
    logic [31: 0] biu_bus_write_data;

    logic        burst_req_valid;
    logic        burst_req_ready;
    logic        burst_req_write;
    logic        burst_req_io;
    logic        burst_req_code;
    logic [31: 0] burst_req_address;
    logic [31: 0] burst_req_wdata;
    logic [31: 0] burst_req_rdata;

    logic        invalidate_cache;
    logic        wbinvd_cmd;

    i486_cpu_core cpu_core_0 (
        .o_mmu_valid        (mmu_valid),
        .i_mmu_ready        (mmu_ready),
        .o_mmu_address      (mmu_address),
        .i_mmu_data_read    (mmu_data_read),
        .o_code_valid       (cache_code_valid),
        .i_code_ready       (cache_code_ready),
        .o_code_address     (cache_code_address),
        .i_code_data_read   (cache_code_data),
        .o_data_valid       (cache_data_valid),
        .i_data_ready       (cache_data_ready),
        .o_data_write_enable(cache_data_write_enable),
        .o_data_io_access   (cache_data_io_access),
        .o_data_address     (cache_data_address),
        .i_data_data_read   (cache_data_rdata),
        .o_data_data_write  (cache_data_wdata),
        .i_intr             (i_intr),
        .i_nmi              (i_nmi),
        .o_ferr_n           (o_ferr_n),
        .clk                (clk),
        .rst_n              (rst_n)
    );

    i486_cache_unit u_cache (
        .i_code_valid        (cache_code_valid),
        .o_code_ready        (cache_code_ready),
        .i_code_address      (cache_code_address),
        .o_code_data         (cache_code_data),
        .i_data_valid        (cache_data_valid),
        .o_data_ready        (cache_data_ready),
        .i_data_write_enable (cache_data_write_enable),
        .i_data_io_access    (cache_data_io_access),
        .i_data_address      (cache_data_address),
        .i_data_wdata        (cache_data_wdata),
        .o_data_rdata        (cache_data_rdata),
        .o_mem_valid         (cache_mem_valid),
        .i_mem_ready         (cache_mem_ready),
        .o_mem_write         (cache_mem_write),
        .o_mem_io            (cache_mem_io),
        .o_mem_code          (cache_mem_code),
        .o_mem_address       (cache_mem_address),
        .o_mem_wdata         (cache_mem_wdata),
        .i_mem_rdata         (cache_mem_rdata),
        .i_invalidate_all    (invalidate_cache),
        .i_wbinvd            (wbinvd_cmd),
        .clk                 (clk),
        .rst_n               (rst_n)
    );

    assign code_valid        = cache_mem_valid & cache_mem_code;
    assign code_address      = cache_mem_address;
    assign data_valid        = cache_mem_valid & ~cache_mem_code;
    assign data_address      = cache_mem_address;
    assign data_write_enable = cache_mem_write;
    assign data_io_access    = cache_mem_io;
    assign data_data_write   = cache_mem_wdata;
    assign cache_mem_ready   = cache_mem_code ? code_ready : data_ready;
    assign cache_mem_rdata   = cache_mem_code ? code_data_read : data_data_read;

    bus_interface_unit biu_0 (
        .i_mmu_valid        (mmu_valid),
        .o_mmu_ready        (mmu_ready),
        .i_mmu_address      (mmu_address),
        .o_mmu_data_read    (mmu_data_read),
        .i_code_valid       (code_valid),
        .o_code_ready       (code_ready),
        .i_code_address     (code_address),
        .o_code_data_read   (code_data_read),
        .i_data_valid       (data_valid),
        .o_data_ready       (data_ready),
        .i_data_write_enable(data_write_enable),
        .i_data_io_access   (data_io_access),
        .i_data_address     (data_address),
        .o_data_data_read   (data_data_read),
        .i_data_data_write  (data_data_write),
        .o_bus_valid        (biu_bus_valid),
        .i_bus_ready        (burst_req_ready),
        .i_bus_busy         (1'b0),
        .o_bus_write_enable (biu_bus_write_enable),
        .o_bus_io_access    (biu_bus_io_access),
        .o_bus_address      (biu_bus_address),
        .i_bus_data_read    (biu_bus_read_data),
        .o_bus_data_write   (biu_bus_write_data),
        .clk                (clk),
        .rst_n              (rst_n)
    );

    assign burst_req_valid   = biu_bus_valid;
    assign biu_bus_read_data = burst_req_rdata;
    assign burst_req_write   = biu_bus_write_enable;
    assign burst_req_io      = biu_bus_io_access;
    assign burst_req_address = biu_bus_address;
    assign burst_req_wdata   = biu_bus_write_data;
    assign burst_req_code    = code_valid;

    i486_burst_controller u_burst (
        .i_req_valid   (burst_req_valid),
        .o_req_ready   (burst_req_ready),
        .i_req_write   (burst_req_write),
        .i_req_io      (burst_req_io),
        .i_req_code    (burst_req_code),
        .i_req_address (burst_req_address),
        .i_req_wdata   (burst_req_wdata),
        .o_req_rdata   (burst_req_rdata),
        .o_ads_n       (o_ads_n),
        .o_address     (o_address),
        .o_data_out    (o_data_out),
        .o_data_oe     (o_data_oe),
        .i_data_in     (i_data_in),
        .o_be_n        (o_be_n),
        .o_wr_n        (o_wr_n),
        .o_dc_n        (o_dc_n),
        .o_mio_n       (o_mio_n),
        .o_blast_n     (o_blast_n),
        .i_bready_n    (i_bready_n),
        .i_hold        (i_hold),
        .o_hlda        (o_hlda),
        .clk           (clk),
        .rst_n         (rst_n)
    );

endmodule
