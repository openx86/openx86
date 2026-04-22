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
//  File        : simple_dual_port_ram_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : simple_dual_port_ram_tb module
// ============================================================================

﻿

`timescale 1ns/1ns

module simple_dual_port_ram_tb;

    parameter int DATA_WIDTH = 8;
    parameter int ADDR_WIDTH = 10;
    parameter int DEPTH      = 1 << ADDR_WIDTH;

    logic                    clk;
    logic rst_n;
    
    // 写端口
    logic                    we;
    logic [ADDR_WIDTH-1: 0]  waddr;
    logic [DATA_WIDTH-1: 0]  wdata;
    
    // 读端口
    logic                    re;
    logic [ADDR_WIDTH-1: 0]  raddr;
    logic [DATA_WIDTH-1: 0]  rdata;

    simple_dual_port_ram #(
        .DATA_WIDTH ( DATA_WIDTH ),
        .ADDR_WIDTH ( ADDR_WIDTH ),
        .DEPTH      ( DEPTH      )
    ) dut (
        .we    ( we    ),
        .waddr ( waddr ),
        .wdata ( wdata ),
        .re    ( re    ),
        .raddr ( raddr ),
        .rdata ( rdata ),
        .clk ( clk ),
        .rst_n ( rst_n )
    );

    // 时钟生成
    always #5 clk = ~clk;

    initial begin
        clk  = 0;
        rst_n  = 1;
        we     = 0;
        waddr  = '0;
        wdata  = '0;
        re     = 0;
        raddr  = '0;

        // 复位
        #20;
        rst_n = 0;
        #10;

        $display("=== Simple dual-port RAM test start ===");
        $display("Time: %t", $time);

        // Test 1: basic write then read
        $display("\nTest 1: basic write then read");
        we    = 1;
        waddr = 10'h010;
        wdata = 8'hAA;
        #10;
        $display("  Write: addr=0x%03h, data=0x%02h", waddr, wdata);

        we    = 0;
        re    = 1;
        raddr = 10'h010;
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0xAA)", raddr, rdata);
        if (rdata != 8'hAA) $error("  error: read data mismatch!");

        // Test 2: sequential writes
        $display("\nTest 2: sequential writes");
        we    = 1;
        re    = 0;
        waddr = 10'h020;
        wdata = 8'hBB;
        #10;
        $display("  Write: addr=0x%03h, data=0x%02h", waddr, wdata);

        waddr = 10'h021;
        wdata = 8'hCC;
        #10;
        $display("  Write: addr=0x%03h, data=0x%02h", waddr, wdata);

        waddr = 10'h022;
        wdata = 8'hDD;
        #10;
        $display("  Write: addr=0x%03h, data=0x%02h", waddr, wdata);

        // Test 3: sequential reads
        $display("\nTest 3: sequential reads");
        we    = 0;
        re    = 1;
        raddr = 10'h020;
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0xBB)", raddr, rdata);
        if (rdata != 8'hBB) $error("  error: read data mismatch!");

        raddr = 10'h021;
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0xCC)", raddr, rdata);
        if (rdata != 8'hCC) $error("  error: read data mismatch!");

        raddr = 10'h022;
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0xDD)", raddr, rdata);
        if (rdata != 8'hDD) $error("  error: read data mismatch!");

        // Test 4: concurrent read/write different addrs（关键测试）
        $display("\nTest 4: concurrent read/write different addrs");
        we    = 1;
        waddr = 10'h030;
        wdata = 8'h11;
        re    = 1;
        raddr = 10'h020;  // 读取之前写入的地址
        #10;
        $display("  Write: addr=0x%03h, data=0x%02h", waddr, wdata);
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0xBB)", raddr, rdata);
        if (rdata != 8'hBB) $error("  error: read data mismatch!");

        we    = 1;
        waddr = 10'h031;
        wdata = 8'h22;
        re    = 1;
        raddr = 10'h030;  // 读取刚才写入的地址
        #10;
        $display("  Write: addr=0x%03h, data=0x%02h", waddr, wdata);
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0x11)", raddr, rdata);
        if (rdata != 8'h11) $error("  error: read data mismatch!");

        // Test 5: concurrent read/write same addr（写后读旧值）
        $display("\nTest 5: concurrent read/write same addr");
        we    = 1;
        waddr = 10'h040;
        wdata = 8'h33;
        re    = 1;
        raddr = 10'h040;  // 读取和写入同一地址
        #10;
        $display("  Write: addr=0x%03h, data=0x%02h", waddr, wdata);
        $display("  Read: addr=0x%03h, data=0x%02h (may be old or new depending on implementation)", raddr, rdata);

        // 下一周期读取，应该读到新值
        we    = 0;
        re    = 1;
        raddr = 10'h040;
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0x33)", raddr, rdata);
        if (rdata != 8'h33) $error("  error: read data mismatch!");

        // Test 6: read-enable control
        $display("\nTest 6: read-enable control");
        we    = 1;
        waddr = 10'h050;
        wdata = 8'h44;
        #10;
        $display("  Write: addr=0x%03h, data=0x%02h", waddr, wdata);

        we    = 0;
        re    = 0;  // 读使能关闭
        raddr = 10'h050;
        #10;
        $display("  Read disabled: addr=0x%03h, data=0x%02h (may be 0 or held)", raddr, rdata);

        re    = 1;  // 读使能打开
        raddr = 10'h050;
        #10;
        $display("  Read enabled: addr=0x%03h, data=0x%02h (expected: 0x44)", raddr, rdata);
        if (rdata != 8'h44) $error("  error: read data mismatch!");

        // Test 7: boundary address test
        $display("\nTest 7: boundary address test");
        we    = 1;
        waddr = 10'h000;  // 最小地址
        wdata = 8'h55;
        #10;
        $display("  Write: addr=0x%03h (min addr), data=0x%02h", waddr, wdata);

        waddr = DEPTH - 1;  // 最大地址
        wdata = 8'h66;
        #10;
        $display("  Write: addr=0x%03h (max addr), data=0x%02h", waddr, wdata);

        we    = 0;
        re    = 1;
        raddr = 10'h000;
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0x55)", raddr, rdata);
        if (rdata != 8'h55) $error("  error: read data mismatch!");

        raddr = DEPTH - 1;
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0x66)", raddr, rdata);
        if (rdata != 8'h66) $error("  error: read data mismatch!");

        // Test 8: 写入后立即读取（不同地址，验证独立性）
        $display("\nTest 8: write then read a different address");
        we    = 1;
        waddr = 10'h060;
        wdata = 8'h77;
        re    = 1;
        raddr = 10'h050;  // 读取之前写入的地址
        #10;
        $display("  Write: addr=0x%03h, data=0x%02h", waddr, wdata);
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0x44)", raddr, rdata);
        if (rdata != 8'h44) $error("  error: read data mismatch!");

        we    = 0;
        re    = 1;
        raddr = 10'h060;  // 读取刚才写入的地址
        #10;
        $display("  Read: addr=0x%03h, data=0x%02h (expected: 0x77)", raddr, rdata);
        if (rdata != 8'h77) $error("  error: read data mismatch!");

        $display("\n=== Simple dual-port RAM test done ===");
        #100;
        $finish;
    end

endmodule

