/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements single_port_ram_tb.
*/
// project: openx86
// description: test single_port_ram module

`timescale 1ns/1ns

module single_port_ram_tb;

    parameter int DATA_WIDTH = 8;
    parameter int ADDR_WIDTH = 10;
    parameter int DEPTH      = 1 << ADDR_WIDTH;

    logic                    clock;
    logic                    reset;
    logic                    we;
    logic [ADDR_WIDTH-1:0]   addr;
    logic [DATA_WIDTH-1:0]   wdata;
    logic [DATA_WIDTH-1:0]   rdata;

    single_port_ram #(
        .DATA_WIDTH ( DATA_WIDTH ),
        .ADDR_WIDTH ( ADDR_WIDTH ),
        .DEPTH      ( DEPTH      )
    ) dut (
        .clock  ( clock  ),
        .reset_n  ( reset  ),
        .we     ( we     ),
        .addr   ( addr   ),
        .wdata  ( wdata  ),
        .rdata  ( rdata  )
    );

    // 时钟生成
    always #5 clock = ~clock;

    initial begin
        clock = 0;
        reset = 1;
        we    = 0;
        addr  = '0;
        wdata = '0;

        // 复位
        #20;
        reset = 0;
        #10;

        $display("=== 单口RAM测试开始 ===");
        $display("时间: %t", $time);

        // 测试1: 写入数据
        $display("\n测试1: 写入数据到地址 0x000, 0x001, 0x002");
        we    = 1;
        addr  = 10'h000;
        wdata = 8'hAA;
        #10;
        $display("  写入: addr=0x%03h, data=0x%02h", addr, wdata);

        addr  = 10'h001;
        wdata = 8'hBB;
        #10;
        $display("  写入: addr=0x%03h, data=0x%02h", addr, wdata);

        addr  = 10'h002;
        wdata = 8'hCC;
        #10;
        $display("  写入: addr=0x%03h, data=0x%02h", addr, wdata);

        // 测试2: 读取数据
        $display("\n测试2: 读取数据");
        we    = 0;
        addr  = 10'h000;
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0xAA)", addr, rdata);
        if (rdata != 8'hAA) $error("  错误: 读取值不匹配!");

        addr  = 10'h001;
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0xBB)", addr, rdata);
        if (rdata != 8'hBB) $error("  错误: 读取值不匹配!");

        addr  = 10'h002;
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0xCC)", addr, rdata);
        if (rdata != 8'hCC) $error("  错误: 读取值不匹配!");

        // 测试3: 写入后立即读取（同一地址）
        $display("\n测试3: 写入后立即读取同一地址");
        we    = 1;
        addr  = 10'h100;
        wdata = 8'h55;
        #10;
        $display("  写入: addr=0x%03h, data=0x%02h", addr, wdata);

        we    = 0;
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0x55)", addr, rdata);
        if (rdata != 8'h55) $error("  错误: 读取值不匹配!");

        // 测试4: 边界地址测试
        $display("\n测试4: 边界地址测试");
        we    = 1;
        addr  = 10'h000;  // 最小地址
        wdata = 8'h11;
        #10;
        $display("  写入: addr=0x%03h (最小地址), data=0x%02h", addr, wdata);

        addr  = DEPTH - 1;  // 最大地址
        wdata = 8'hFF;
        #10;
        $display("  写入: addr=0x%03h (最大地址), data=0x%02h", addr, wdata);

        we    = 0;
        addr  = 10'h000;
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0x11)", addr, rdata);
        if (rdata != 8'h11) $error("  错误: 读取值不匹配!");

        addr  = DEPTH - 1;
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0xFF)", addr, rdata);
        if (rdata != 8'hFF) $error("  错误: 读取值不匹配!");

        $display("\n=== 单口RAM测试完成 ===");
        #100;
        $finish;
    end

endmodule
