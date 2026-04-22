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
//  File        : true_dual_port_ram_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : true_dual_port_ram_tb module
// ============================================================================

﻿

`timescale 1ns/1ns

module true_dual_port_ram_tb;

    parameter int DATA_WIDTH = 8;
    parameter int ADDR_WIDTH = 10;
    parameter int DEPTH      = 1 << ADDR_WIDTH;

    logic                    clk;
    logic rst_n;
    
    // 端口A
    logic                    wea;
    logic [ADDR_WIDTH-1: 0]  addra;
    logic [DATA_WIDTH-1: 0]  wdataa;
    logic [DATA_WIDTH-1: 0]  rdataa;
    
    // 端口B
    logic                    web;
    logic [ADDR_WIDTH-1: 0]  addrb;
    logic [DATA_WIDTH-1: 0]  wdatab;
    logic [DATA_WIDTH-1: 0]  rdatab;

    true_dual_port_ram #(
        .DATA_WIDTH ( DATA_WIDTH ),
        .ADDR_WIDTH ( ADDR_WIDTH ),
        .DEPTH      ( DEPTH      )
    ) dut (
        .clk  ( clk  ),
        .rst_n  ( rst_n ),
        .wea    ( wea    ),
        .addra  ( addra  ),
        .wdataa ( wdataa ),
        .rdataa ( rdataa ),
        .web    ( web    ),
        .addrb  ( addrb  ),
        .wdatab ( wdatab ),
        .rdatab ( rdatab )
    );

    // 时钟生成
    always #5 clk = ~clk;

    initial begin
        clk  = 0;
        rst_n  = 1;
        wea    = 0;
        addra  = '0;
        wdataa = '0;
        web    = 0;
        addrb  = '0;
        wdatab = '0;

        // 复位
        #20;
        rst_n = 0;
        #10;

        $display("=== True dual-port RAM test start ===");
        $display("Time: %t", $time);

        // Test 1: port A write, port B read
        $display("\nTest 1: port A write, port B read");
        wea    = 1;
        addra  = 10'h010;
        wdataa = 8'hAA;
        #10;
        $display("  Port A write: addr=0x%03h, data=0x%02h", addra, wdataa);

        wea    = 0;
        addra  = 10'h010;
        web    = 0;
        addrb  = 10'h010;
        #10;
        $display("  Port A read: addr=0x%03h, data=0x%02h (expected: 0xAA)", addra, rdataa);
        $display("  Port B read: addr=0x%03h, data=0x%02h (expected: 0xAA)", addrb, rdatab);
        if (rdataa != 8'hAA) $error("  error: port A read mismatch!");
        if (rdatab != 8'hAA) $error("  error: port B read mismatch!");

        // Test 2: port B write, port A read
        $display("\nTest 2: port B write, port A read");
        web    = 1;
        addrb  = 10'h020;
        wdatab = 8'hBB;
        #10;
        $display("  Port B write: addr=0x%03h, data=0x%02h", addrb, wdatab);

        web    = 0;
        addra  = 10'h020;
        addrb  = 10'h020;
        #10;
        $display("  Port A read: addr=0x%03h, data=0x%02h (expected: 0xBB)", addra, rdataa);
        $display("  Port B read: addr=0x%03h, data=0x%02h (expected: 0xBB)", addrb, rdatab);
        if (rdataa != 8'hBB) $error("  error: port A read mismatch!");
        if (rdatab != 8'hBB) $error("  error: port B read mismatch!");

        // Test 3: concurrent read/write different addrs
        $display("\nTest 3: concurrent read/write different addrs");
        wea    = 1;
        addra  = 10'h030;
        wdataa = 8'hCC;
        web    = 0;
        addrb  = 10'h040;
        #10;
        $display("  Port A write: addr=0x%03h, data=0x%02h", addra, wdataa);
        $display("  Port B read: addr=0x%03h, data=0x%02h", addrb, rdatab);

        wea    = 0;
        addra  = 10'h030;
        web    = 1;
        addrb  = 10'h050;
        wdatab = 8'hDD;
        #10;
        $display("  Port A read: addr=0x%03h, data=0x%02h (expected: 0xCC)", addra, rdataa);
        $display("  Port B write: addr=0x%03h, data=0x%02h", addrb, wdatab);
        if (rdataa != 8'hCC) $error("  error: port A read mismatch!");

        // Test 4: concurrent read/write same addr（写优先，但这里我们测试读取旧值）
        $display("\nTest 4: concurrent read/write same addr");
        wea    = 1;
        addra  = 10'h060;
        wdataa = 8'hEE;
        web    = 0;
        addrb  = 10'h060;
        #10;
        $display("  Port A write: addr=0x%03h, data=0x%02h", addra, wdataa);
        $display("  Port B read: addr=0x%03h, data=0x%02h (may be stale)", addrb, rdatab);

        wea    = 0;
        addra  = 10'h060;
        #10;
        $display("  Port A read: addr=0x%03h, data=0x%02h (expected: 0xEE)", addra, rdataa);
        if (rdataa != 8'hEE) $error("  error: port A read mismatch!");

        // Test 5: boundary address test
        $display("\nTest 5: boundary address test");
        wea    = 1;
        addra  = 10'h000;  // 最小地址
        wdataa = 8'h11;
        #10;
        $display("  Port A write: addr=0x%03h (min addr), data=0x%02h", addra, wdataa);

        addra  = DEPTH - 1;  // 最大地址
        wdataa = 8'hFF;
        #10;
        $display("  Port A write: addr=0x%03h (max addr), data=0x%02h", addra, wdataa);

        wea    = 0;
        addra  = 10'h000;
        addrb  = DEPTH - 1;
        #10;
        $display("  Port A read: addr=0x%03h, data=0x%02h (expected: 0x11)", addra, rdataa);
        $display("  Port B read: addr=0x%03h, data=0x%02h (expected: 0xFF)", addrb, rdatab);
        if (rdataa != 8'h11) $error("  error: port A read mismatch!");
        if (rdatab != 8'hFF) $error("  error: port B read mismatch!");

        $display("\n=== True dual-port RAM test done ===");
        #100;
        $finish;
    end

endmodule

