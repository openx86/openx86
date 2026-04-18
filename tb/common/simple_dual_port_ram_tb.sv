/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements simple_dual_port_ram_tb.
*/
// project: openx86
// description: test simple_dual_port_ram module

`timescale 1ns/1ns

module simple_dual_port_ram_tb;

    parameter int DATA_WIDTH = 8;
    parameter int ADDR_WIDTH = 10;
    parameter int DEPTH      = 1 << ADDR_WIDTH;

    logic                    clock;
    logic                    reset;
    
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
        .clock ( clock ),
        .reset_n ( reset_n )
    );

    // 时钟生成
    always #5 clock = ~clock;

    initial begin
        clock  = 0;
        reset  = 1;
        we     = 0;
        waddr  = '0;
        wdata  = '0;
        re     = 0;
        raddr  = '0;

        // 复位
        #20;
        reset = 0;
        #10;

        $display("=== 简单双口RAM测试开始 ===");
        $display("时间: %t", $time);

        // 测试1: 基本写入和读取
        $display("\n测试1: 基本写入和读取");
        we    = 1;
        waddr = 10'h010;
        wdata = 8'hAA;
        #10;
        $display("  写入: addr=0x%03h, data=0x%02h", waddr, wdata);

        we    = 0;
        re    = 1;
        raddr = 10'h010;
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0xAA)", raddr, rdata);
        if (rdata != 8'hAA) $error("  错误: 读取值不匹配!");

        // 测试2: 连续写入多个地址
        $display("\n测试2: 连续写入多个地址");
        we    = 1;
        re    = 0;
        waddr = 10'h020;
        wdata = 8'hBB;
        #10;
        $display("  写入: addr=0x%03h, data=0x%02h", waddr, wdata);

        waddr = 10'h021;
        wdata = 8'hCC;
        #10;
        $display("  写入: addr=0x%03h, data=0x%02h", waddr, wdata);

        waddr = 10'h022;
        wdata = 8'hDD;
        #10;
        $display("  写入: addr=0x%03h, data=0x%02h", waddr, wdata);

        // 测试3: 连续读取多个地址
        $display("\n测试3: 连续读取多个地址");
        we    = 0;
        re    = 1;
        raddr = 10'h020;
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0xBB)", raddr, rdata);
        if (rdata != 8'hBB) $error("  错误: 读取值不匹配!");

        raddr = 10'h021;
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0xCC)", raddr, rdata);
        if (rdata != 8'hCC) $error("  错误: 读取值不匹配!");

        raddr = 10'h022;
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0xDD)", raddr, rdata);
        if (rdata != 8'hDD) $error("  错误: 读取值不匹配!");

        // 测试4: 同时读写不同地址（关键测试）
        $display("\n测试4: 同时读写不同地址");
        we    = 1;
        waddr = 10'h030;
        wdata = 8'h11;
        re    = 1;
        raddr = 10'h020;  // 读取之前写入的地址
        #10;
        $display("  写入: addr=0x%03h, data=0x%02h", waddr, wdata);
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0xBB)", raddr, rdata);
        if (rdata != 8'hBB) $error("  错误: 读取值不匹配!");

        we    = 1;
        waddr = 10'h031;
        wdata = 8'h22;
        re    = 1;
        raddr = 10'h030;  // 读取刚才写入的地址
        #10;
        $display("  写入: addr=0x%03h, data=0x%02h", waddr, wdata);
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0x11)", raddr, rdata);
        if (rdata != 8'h11) $error("  错误: 读取值不匹配!");

        // 测试5: 同时读写相同地址（写后读旧值）
        $display("\n测试5: 同时读写相同地址");
        we    = 1;
        waddr = 10'h040;
        wdata = 8'h33;
        re    = 1;
        raddr = 10'h040;  // 读取和写入同一地址
        #10;
        $display("  写入: addr=0x%03h, data=0x%02h", waddr, wdata);
        $display("  读取: addr=0x%03h, data=0x%02h (可能为旧值或新值，取决于实现)", raddr, rdata);

        // 下一周期读取，应该读到新值
        we    = 0;
        re    = 1;
        raddr = 10'h040;
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0x33)", raddr, rdata);
        if (rdata != 8'h33) $error("  错误: 读取值不匹配!");

        // 测试6: 读使能控制
        $display("\n测试6: 读使能控制");
        we    = 1;
        waddr = 10'h050;
        wdata = 8'h44;
        #10;
        $display("  写入: addr=0x%03h, data=0x%02h", waddr, wdata);

        we    = 0;
        re    = 0;  // 读使能关闭
        raddr = 10'h050;
        #10;
        $display("  读使能关闭: addr=0x%03h, data=0x%02h (可能为0或保持)", raddr, rdata);

        re    = 1;  // 读使能打开
        raddr = 10'h050;
        #10;
        $display("  读使能打开: addr=0x%03h, data=0x%02h (期望: 0x44)", raddr, rdata);
        if (rdata != 8'h44) $error("  错误: 读取值不匹配!");

        // 测试7: 边界地址测试
        $display("\n测试7: 边界地址测试");
        we    = 1;
        waddr = 10'h000;  // 最小地址
        wdata = 8'h55;
        #10;
        $display("  写入: addr=0x%03h (最小地址), data=0x%02h", waddr, wdata);

        waddr = DEPTH - 1;  // 最大地址
        wdata = 8'h66;
        #10;
        $display("  写入: addr=0x%03h (最大地址), data=0x%02h", waddr, wdata);

        we    = 0;
        re    = 1;
        raddr = 10'h000;
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0x55)", raddr, rdata);
        if (rdata != 8'h55) $error("  错误: 读取值不匹配!");

        raddr = DEPTH - 1;
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0x66)", raddr, rdata);
        if (rdata != 8'h66) $error("  错误: 读取值不匹配!");

        // 测试8: 写入后立即读取（不同地址，验证独立性）
        $display("\n测试8: 写入后立即读取不同地址");
        we    = 1;
        waddr = 10'h060;
        wdata = 8'h77;
        re    = 1;
        raddr = 10'h050;  // 读取之前写入的地址
        #10;
        $display("  写入: addr=0x%03h, data=0x%02h", waddr, wdata);
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0x44)", raddr, rdata);
        if (rdata != 8'h44) $error("  错误: 读取值不匹配!");

        we    = 0;
        re    = 1;
        raddr = 10'h060;  // 读取刚才写入的地址
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0x77)", raddr, rdata);
        if (rdata != 8'h77) $error("  错误: 读取值不匹配!");

        $display("\n=== 简单双口RAM测试完成 ===");
        #100;
        $finish;
    end

endmodule
