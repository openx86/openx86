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
//  File        : single_port_ram_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : single_port_ram_tb module
// ============================================================================

﻿

`timescale 1ns/1ns

module single_port_ram_tb;

    // ============================================================
    // parameters
    // ============================================================
    parameter int DATA_WIDTH = 8;
    parameter int ADDR_WIDTH = 10;
    parameter int DEPTH      = 1 << ADDR_WIDTH;

    // ============================================================
    // test signals
    // ============================================================
    logic                    clk;
    logic rst_n;
    logic                    we;
    logic [ADDR_WIDTH-1: 0]  addr;
    logic [DATA_WIDTH-1: 0]  wdata;
    logic [DATA_WIDTH-1: 0]  rdata;

    // ============================================================
    // DUT instantiation
    // ============================================================
    single_port_ram #(
        .DATA_WIDTH ( DATA_WIDTH ),
        .ADDR_WIDTH ( ADDR_WIDTH ),
        .DEPTH      ( DEPTH      )
    ) dut (
        .clk   ( clk   ),
        .rst_n ( rst_n ),
        .we    ( we    ),
        .addr  ( addr  ),
        .wdata ( wdata ),
        .rdata ( rdata )
    );

    // ============================================================
    // clock generation
    // ============================================================
    always #5 clk = ~clk;

    // ============================================================
    // test procedure
    // ============================================================
    initial begin : main_test
        clk = 0;
        rst_n = 1;
        we    = 0;
        addr  = '0;
        wdata = '0;

        // 复位
        #20;
        rst_n = 0;
        #10;

        $display("=== Single-port RAM test start ===");
        $display("Time: %t", $time);

        // Test 1: 写入数据
        $display("\nTest 1: write data to addresses 0x000, 0x001, 0x002");
        we    = 1;
        addr  = 10'h000;
        wdata = 8'hAA;
        #10;
        $display("  Write: addr=0x%03h, data=0x%02h", addr, wdata);

        addr  = 10'h001;
        wdata = 8'hBB;
        #10;
        $display("  Write: addr=0x%03h, data=0x%02h", addr, wdata);

        addr  = 10'h002;
        wdata = 8'hCC;
        #10;
        $display("  Write: addr=0x%03h, data=0x%02h", addr, wdata);

        // Test 2: 读取数据
        $display("\nTest 2: read data");
        we    = 0;
        addr  = 10'h000;
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0xAA)", addr, rdata);
        if (rdata != 8'hAA) $error("  error: read data mismatch!");

        addr  = 10'h001;
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0xBB)", addr, rdata);
        if (rdata != 8'hBB) $error("  error: read data mismatch!");

        addr  = 10'h002;
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0xCC)", addr, rdata);
        if (rdata != 8'hCC) $error("  error: read data mismatch!");

        // Test 3: 写入后立即读取（同一地址）
        $display("\nTest 3: read same addr immediately after write");
        we    = 1;
        addr  = 10'h100;
        wdata = 8'h55;
        #10;
        $display("  Write: addr=0x%03h, data=0x%02h", addr, wdata);

        we    = 0;
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0x55)", addr, rdata);
        if (rdata != 8'h55) $error("  error: read data mismatch!");

        // Test 4: boundary address test
        $display("\nTest 4: boundary address test");
        we    = 1;
        addr  = 10'h000;  // 最小地址
        wdata = 8'h11;
        #10;
        $display("  Write: addr=0x%03h (min addr), data=0x%02h", addr, wdata);

        addr  = DEPTH - 1;  // 最大地址
        wdata = 8'hFF;
        #10;
        $display("  Write: addr=0x%03h (max addr), data=0x%02h", addr, wdata);

        we    = 0;
        addr  = 10'h000;
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0x11)", addr, rdata);
        if (rdata != 8'h11) $error("  error: read data mismatch!");

        addr  = DEPTH - 1;
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0xFF)", addr, rdata);
        if (rdata != 8'hFF) $error("  error: read data mismatch!");

        $display("\n=== Single-port RAM test done ===");
        #100;
        $finish;
    end

endmodule

