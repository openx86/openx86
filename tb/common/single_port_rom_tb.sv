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
//  File        : single_port_rom_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : single_port_rom_tb module
// ============================================================================

`timescale 1ns/1ns

module single_port_rom_tb;

    parameter int DATA_WIDTH = 8;
    parameter int ADDR_WIDTH = 10;
    parameter int DEPTH      = 1 << ADDR_WIDTH;

    logic                    clk;
    logic                    rst_n;
    logic [ADDR_WIDTH-1: 0]  addr;
    logic [DATA_WIDTH-1: 0]  rdata;

    // 创建测试用的初始化数据数组
    logic [DATA_WIDTH-1: 0] test_data [0:DEPTH-1];

    // 初始化测试数据
    initial begin
        for (int i = 0; i < DEPTH; i++) begin
            test_data[i] = i[ 7: 0];  // 使用地址的低8位作为数据
        end
        // 设置一些特殊值用于测试
        test_data[0] = 8'hAA;
        test_data[1] = 8'hBB;
        test_data[2] = 8'hCC;
        test_data[DEPTH-1] = 8'hFF;
    end

    single_port_rom #(
        .DATA_WIDTH ( DATA_WIDTH ),
        .ADDR_WIDTH ( ADDR_WIDTH ),
        .DEPTH      ( DEPTH      )
    ) dut (
        .addr   ( addr   ),
        .rdata  ( rdata  ),
        .clk  ( clk  ),
        .rst_n  ( rst_n  )
    );

    // 手动初始化ROM数据（用于测试）
    // 注意：这需要在ROM模块的initial块中完成，这里只是说明
    // 实际测试时，可以通过修改ROM模块的initial块来初始化数据
    initial begin
        // 等待ROM初始化完成
        #1;
        // 手动设置ROM数据（用于测试）
        for (int i = 0; i < DEPTH; i++) begin
            dut.rom[i] = test_data[i];
        end
    end

    // 时钟生成
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 1;
        addr  = '0;

        // 复位
        #20;
        rst_n = 0;
        #10;

        $display("=== Single-port ROM test start ===");
        $display("Time: %t", $time);

        // Test 1: 读取不同地址的数据
        $display("\nTest 1: read data from different addresses");
        addr = 10'h000;
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0xAA)", addr, rdata);
        if (rdata != 8'hAA) $error("  error: read data mismatch!");

        addr = 10'h001;
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0xBB)", addr, rdata);
        if (rdata != 8'hBB) $error("  error: read data mismatch!");

        addr = 10'h002;
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0xCC)", addr, rdata);
        if (rdata != 8'hCC) $error("  error: read data mismatch!");

        // Test 2: sequential reads
        $display("\nTest 2: sequential reads");
        for (int i = 0; i < 10; i++) begin
            addr = i;
            #10;
            $display("  Read: addr=0x%03h, data=0x%02h", addr, rdata);
        end

        // Test 3: boundary address test
        $display("\nTest 3: boundary address test");
        addr = 10'h000;  // 最小地址
        #10;
        $display("  Read: addr=0x%03h (min addr), data=0x%02h (expected: 0xAA)", addr, rdata);
        if (rdata != 8'hAA) $error("  error: read data mismatch!");

        addr = DEPTH - 1;  // 最大地址
        #10;
        $display("  Read: addr=0x%03h (max addr), data=0x%02h (expected: 0xFF)", addr, rdata);
        if (rdata != 8'hFF) $error("  error: read data mismatch!");

        // Test 4: read latency after addr change
        $display("\nTest 4: read latency after addr change");
        addr = 10'h010;
        #5;  // 半个时钟周期
        $display("  Half cycle after addr change: addr=0x%03h, data=0x%02h (may be stale)", addr, rdata);
        #5;  // 再等半个时钟周期，完成一个时钟周期
        $display("  One cycle after addr change: addr=0x%03h, data=0x%02h (should be new value)", addr, rdata);

        // Test 5: Reset test
        $display("\nTest 5: Reset test");
        rst_n = 1;
        addr = 10'h000;
        #10;
        $display("  Read during reset: addr=0x%03h, data=0x%02h (expected: 0x00)", addr, rdata);
        if (rdata != 8'h00) $error("  error: read data must be 0 during reset!");

        rst_n = 0;
        #10;
        $display("  Read after reset release: addr=0x%03h, data=0x%02h (expected: 0xAA)", addr, rdata);
        if (rdata != 8'hAA) $error("  error: read mismatch after reset!");

        $display("\n=== Single-port ROM test done ===");
        #100;
        $finish;
    end

endmodule
