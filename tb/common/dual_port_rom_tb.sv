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
//  File        : dual_port_rom_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : dual_port_rom_tb module
// ============================================================================

﻿

`timescale 1ns/1ns

module dual_port_rom_tb;

    // ============================================================
    // parameters
    // ============================================================
    parameter int DATA_WIDTH = 8;
    parameter int ADDR_WIDTH = 10;
    parameter int DEPTH      = 1 << ADDR_WIDTH;

    // ============================================================
    // test signals
    // ============================================================
    logic                   clk;
    logic rst_n;

    // port A
    logic [ADDR_WIDTH-1: 0] addra;
    logic [DATA_WIDTH-1: 0] rdataa;

    // port B
    logic [ADDR_WIDTH-1: 0] addrb;
    logic [DATA_WIDTH-1: 0] rdatab;

    // test data array
    logic [DATA_WIDTH-1: 0] test_data [0:DEPTH-1];

    // ============================================================
    // test data initialization
    // ============================================================
    initial begin : init_test_data
        for (int i = 0; i < DEPTH; i++) begin
            test_data[i] = i[ 7: 0];  // 使用地址的低8位作为数据
        end
        // 设置一些特殊值用于测试
        test_data[0] = 8'hAA;
        test_data[1] = 8'hBB;
        test_data[2] = 8'hCC;
        test_data[10] = 8'h11;
        test_data[20] = 8'h22;
        test_data[DEPTH-1] = 8'hFF;
    end

    // ============================================================
    // DUT instantiation
    // ============================================================
    dual_port_rom #(
        .DATA_WIDTH ( DATA_WIDTH ),
        .ADDR_WIDTH ( ADDR_WIDTH ),
        .DEPTH      ( DEPTH      )
    ) dut (
        .addra  ( addra  ),
        .rdataa ( rdataa ),
        .addrb  ( addrb  ),
        .rdatab ( rdatab ),
        .clk  ( clk  ),
        .rst_n  ( rst_n )
    );

    // ============================================================
    // ROM data initialization
    // ============================================================
    initial begin : init_rom_data
        // 等待ROM初始化完成
        #1;
        // 手动设置ROM数据（用于测试）
        for (int i = 0; i < DEPTH; i++) begin
            dut.rom[i] = test_data[i];
        end
    end

    // ============================================================
    // clock generation
    // ============================================================
    always #5 clk = ~clk;

    // ============================================================
    // test procedure
    // ============================================================
    initial begin : main_test
        clk  = 0;
        rst_n  = 1;
        addra  = '0;
        addrb  = '0;

        // 复位
        #20;
        rst_n = 0;
        #10;

        $display("=== Dual-port ROM test start ===");
        $display("Time: %t", $time);

        // Test 1: ports A/B read different addrs
        $display("\nTest 1: ports A/B read different addrs");
        addra = 10'h000;
        addrb = 10'h001;
        #10;
        $display("  Port A read: addr=0x%03h, data=0x%02h (expected: 0xAA)", addra, rdataa);
        $display("  Port B read: addr=0x%03h, data=0x%02h (expected: 0xBB)", addrb, rdatab);
        if (rdataa != 8'hAA) $error("  error: port A read mismatch!");
        if (rdatab != 8'hBB) $error("  error: port B read mismatch!");

        // Test 2: ports A/B read same addr
        $display("\nTest 2: ports A/B read same addr");
        addra = 10'h002;
        addrb = 10'h002;
        #10;
        $display("  Port A read: addr=0x%03h, data=0x%02h (expected: 0xCC)", addra, rdataa);
        $display("  Port B read: addr=0x%03h, data=0x%02h (expected: 0xCC)", addrb, rdatab);
        if (rdataa != 8'hCC) $error("  error: port A read mismatch!");
        if (rdatab != 8'hCC) $error("  error: port B read mismatch!");

        // Test 3: concurrent read different addrs（关键测试）
        $display("\nTest 3: concurrent read different addrs");
        addra = 10'h00A;  // 地址10
        addrb = 10'h014;  // 地址20
        #10;
        $display("  Port A read: addr=0x%03h, data=0x%02h (expected: 0x11)", addra, rdataa);
        $display("  Port B read: addr=0x%03h, data=0x%02h (expected: 0x22)", addrb, rdatab);
        if (rdataa != 8'h11) $error("  error: port A read mismatch!");
        if (rdatab != 8'h22) $error("  error: port B read mismatch!");

        // Test 4: sequential reads
        $display("\nTest 4: sequential reads");
        for (int i = 0; i < 5; i++) begin
            addra = i;
            addrb = i + 10;
            #10;
            $display("  Port A read: addr=0x%03h, data=0x%02h", addra, rdataa);
            $display("  Port B read: addr=0x%03h, data=0x%02h", addrb, rdatab);
        end

        // Test 5: boundary address test
        $display("\nTest 5: boundary address test");
        addra = 10'h000;  // 最小地址
        addrb = DEPTH - 1;  // 最大地址
        #10;
        $display("  Port A read: addr=0x%03h (min addr), data=0x%02h (expected: 0xAA)", addra, rdataa);
        $display("  Port B read: addr=0x%03h (max addr), data=0x%02h (expected: 0xFF)", addrb, rdatab);
        if (rdataa != 8'hAA) $error("  error: port A read mismatch!");
        if (rdatab != 8'hFF) $error("  error: port B read mismatch!");

        // Test 6: fast address change
        $display("\nTest 6: fast address change");
        addra = 10'h010;
        addrb = 10'h020;
        #5;  // 半个时钟周期
        $display("  Half cycle after addr change:");
        $display("    Port A: addr=0x%03h, data=0x%02h (may be stale)", addra, rdataa);
        $display("    Port B: addr=0x%03h, data=0x%02h (may be stale)", addrb, rdatab);
        #5;  // 再等半个时钟周期
        $display("  One cycle after addr change:");
        $display("    Port A: addr=0x%03h, data=0x%02h (should be new value)", addra, rdataa);
        $display("    Port B: addr=0x%03h, data=0x%02h (should be new value)", addrb, rdatab);

        // Test 7: Reset test
        $display("\nTest 7: Reset test");
        rst_n = 1;
        addra = 10'h000;
        addrb = 10'h001;
        #10;
        $display("  Read during reset:");
        $display("    Port A: addr=0x%03h, data=0x%02h (expected: 0x00)", addra, rdataa);
        $display("    Port B: addr=0x%03h, data=0x%02h (expected: 0x00)", addrb, rdatab);
        if (rdataa != 8'h00) $error("  error: port A read must be 0 during reset!");
        if (rdatab != 8'h00) $error("  error: port B read must be 0 during reset!");

        rst_n = 0;
        #10;
        $display("  Read after reset release:");
        $display("    Port A: addr=0x%03h, data=0x%02h (expected: 0xAA)", addra, rdataa);
        $display("    Port B: addr=0x%03h, data=0x%02h (expected: 0xBB)", addrb, rdatab);
        if (rdataa != 8'hAA) $error("  error: port A read mismatch after reset!");
        if (rdatab != 8'hBB) $error("  error: port B read mismatch after reset!");

        $display("\n=== Dual-port ROM test done ===");
        #100;
        $finish;
    end

endmodule
