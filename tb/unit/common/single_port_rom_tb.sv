/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements single_port_rom_tb.
*/
// project: openx86
// module: single_port_rom_tb
// description: test single_port_rom module

`timescale 1ns/1ns

module single_port_rom_tb;

    parameter int DATA_WIDTH = 8;
    parameter int ADDR_WIDTH = 10;
    parameter int DEPTH      = 1 << ADDR_WIDTH;

    logic                    clock;
    logic                    reset;
    logic [ADDR_WIDTH-1:0]   addr;
    logic [DATA_WIDTH-1:0]   rdata;

    // 创建测试用的初始化数据数组
    logic [DATA_WIDTH-1:0] test_data [0:DEPTH-1];

    // 初始化测试数据
    initial begin
        for (int i = 0; i < DEPTH; i++) begin
            test_data[i] = i[7:0];  // 使用地址的低8位作为数据
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
        .clock  ( clock  ),
        .reset  ( reset  )
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
    always #5 clock = ~clock;

    initial begin
        clock = 0;
        reset = 1;
        addr  = '0;

        // 复位
        #20;
        reset = 0;
        #10;

        $display("=== 单口ROM测试开始 ===");
        $display("时间: %t", $time);

        // 测试1: 读取不同地址的数据
        $display("\n测试1: 读取不同地址的数据");
        addr = 10'h000;
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0xAA)", addr, rdata);
        if (rdata != 8'hAA) $error("  错误: 读取值不匹配!");

        addr = 10'h001;
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0xBB)", addr, rdata);
        if (rdata != 8'hBB) $error("  错误: 读取值不匹配!");

        addr = 10'h002;
        #10;
        $display("  读取: addr=0x%03h, data=0x%02h (期望: 0xCC)", addr, rdata);
        if (rdata != 8'hCC) $error("  错误: 读取值不匹配!");

        // 测试2: 连续读取多个地址
        $display("\n测试2: 连续读取多个地址");
        for (int i = 0; i < 10; i++) begin
            addr = i;
            #10;
            $display("  读取: addr=0x%03h, data=0x%02h", addr, rdata);
        end

        // 测试3: 边界地址测试
        $display("\n测试3: 边界地址测试");
        addr = 10'h000;  // 最小地址
        #10;
        $display("  读取: addr=0x%03h (最小地址), data=0x%02h (期望: 0xAA)", addr, rdata);
        if (rdata != 8'hAA) $error("  错误: 读取值不匹配!");

        addr = DEPTH - 1;  // 最大地址
        #10;
        $display("  读取: addr=0x%03h (最大地址), data=0x%02h (期望: 0xFF)", addr, rdata);
        if (rdata != 8'hFF) $error("  错误: 读取值不匹配!");

        // 测试4: 地址变化后数据延迟测试
        $display("\n测试4: 地址变化后数据延迟测试");
        addr = 10'h010;
        #5;  // 半个时钟周期
        $display("  地址变化后半个时钟周期: addr=0x%03h, data=0x%02h (可能为旧值)", addr, rdata);
        #5;  // 再等半个时钟周期，完成一个时钟周期
        $display("  地址变化后一个时钟周期: addr=0x%03h, data=0x%02h (应该为新值)", addr, rdata);

        // 测试5: 复位测试
        $display("\n测试5: 复位测试");
        reset = 1;
        addr = 10'h000;
        #10;
        $display("  复位时读取: addr=0x%03h, data=0x%02h (期望: 0x00)", addr, rdata);
        if (rdata != 8'h00) $error("  错误: 复位时读取值应该为0!");

        reset = 0;
        #10;
        $display("  复位释放后读取: addr=0x%03h, data=0x%02h (期望: 0xAA)", addr, rdata);
        if (rdata != 8'hAA) $error("  错误: 复位释放后读取值不匹配!");

        $display("\n=== 单口ROM测试完成 ===");
        #100;
        $finish;
    end

endmodule
