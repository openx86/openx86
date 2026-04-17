/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements dual_port_rom_tb.
*/
// project: openx86
// description: test dual_port_rom module

`timescale 1ns/1ns

module dual_port_rom_tb;

    parameter int DATA_WIDTH = 8;
    parameter int ADDR_WIDTH = 10;
    parameter int DEPTH      = 1 << ADDR_WIDTH;

    logic                    clock;
    logic                    reset;
    
    // 端口A
    logic [ADDR_WIDTH-1:0]   addra;
    logic [DATA_WIDTH-1:0]   rdataa;
    
    // 端口B
    logic [ADDR_WIDTH-1:0]   addrb;
    logic [DATA_WIDTH-1:0]   rdatab;

    // 创建测试用的初始化数据数组
    logic [DATA_WIDTH-1:0] test_data [0:DEPTH-1];

    // 初始化测试数据
    initial begin
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

    // 使用双口ROM
    dual_port_rom #(
        .DATA_WIDTH ( DATA_WIDTH ),
        .ADDR_WIDTH ( ADDR_WIDTH ),
        .DEPTH      ( DEPTH      )
    ) dut (
        .addra  ( addra  ),
        .rdataa ( rdataa ),
        .addrb  ( addrb  ),
        .rdatab ( rdatab ),
        .clock  ( clock  ),
        .reset_n  ( reset  )
    );

    // 手动初始化ROM数据（用于测试）
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
        clock  = 0;
        reset  = 1;
        addra  = '0;
        addrb  = '0;

        // 复位
        #20;
        reset = 0;
        #10;

        $display("=== 双口ROM测试开始 ===");
        $display("时间: %t", $time);

        // 测试1: 端口A和端口B读取不同地址
        $display("\n测试1: 端口A和端口B读取不同地址");
        addra = 10'h000;
        addrb = 10'h001;
        #10;
        $display("  端口A读取: addr=0x%03h, data=0x%02h (期望: 0xAA)", addra, rdataa);
        $display("  端口B读取: addr=0x%03h, data=0x%02h (期望: 0xBB)", addrb, rdatab);
        if (rdataa != 8'hAA) $error("  错误: 端口A读取值不匹配!");
        if (rdatab != 8'hBB) $error("  错误: 端口B读取值不匹配!");

        // 测试2: 端口A和端口B读取相同地址
        $display("\n测试2: 端口A和端口B读取相同地址");
        addra = 10'h002;
        addrb = 10'h002;
        #10;
        $display("  端口A读取: addr=0x%03h, data=0x%02h (期望: 0xCC)", addra, rdataa);
        $display("  端口B读取: addr=0x%03h, data=0x%02h (期望: 0xCC)", addrb, rdatab);
        if (rdataa != 8'hCC) $error("  错误: 端口A读取值不匹配!");
        if (rdatab != 8'hCC) $error("  错误: 端口B读取值不匹配!");

        // 测试3: 同时读取不同地址（关键测试）
        $display("\n测试3: 同时读取不同地址");
        addra = 10'h00A;  // 地址10
        addrb = 10'h014;  // 地址20
        #10;
        $display("  端口A读取: addr=0x%03h, data=0x%02h (期望: 0x11)", addra, rdataa);
        $display("  端口B读取: addr=0x%03h, data=0x%02h (期望: 0x22)", addrb, rdatab);
        if (rdataa != 8'h11) $error("  错误: 端口A读取值不匹配!");
        if (rdatab != 8'h22) $error("  错误: 端口B读取值不匹配!");

        // 测试4: 连续读取多个地址
        $display("\n测试4: 连续读取多个地址");
        for (int i = 0; i < 5; i++) begin
            addra = i;
            addrb = i + 10;
            #10;
            $display("  端口A读取: addr=0x%03h, data=0x%02h", addra, rdataa);
            $display("  端口B读取: addr=0x%03h, data=0x%02h", addrb, rdatab);
        end

        // 测试5: 边界地址测试
        $display("\n测试5: 边界地址测试");
        addra = 10'h000;  // 最小地址
        addrb = DEPTH - 1;  // 最大地址
        #10;
        $display("  端口A读取: addr=0x%03h (最小地址), data=0x%02h (期望: 0xAA)", addra, rdataa);
        $display("  端口B读取: addr=0x%03h (最大地址), data=0x%02h (期望: 0xFF)", addrb, rdatab);
        if (rdataa != 8'hAA) $error("  错误: 端口A读取值不匹配!");
        if (rdatab != 8'hFF) $error("  错误: 端口B读取值不匹配!");

        // 测试6: 地址快速变化测试
        $display("\n测试6: 地址快速变化测试");
        addra = 10'h010;
        addrb = 10'h020;
        #5;  // 半个时钟周期
        $display("  地址变化后半个时钟周期:");
        $display("    端口A: addr=0x%03h, data=0x%02h (可能为旧值)", addra, rdataa);
        $display("    端口B: addr=0x%03h, data=0x%02h (可能为旧值)", addrb, rdatab);
        #5;  // 再等半个时钟周期
        $display("  地址变化后一个时钟周期:");
        $display("    端口A: addr=0x%03h, data=0x%02h (应该为新值)", addra, rdataa);
        $display("    端口B: addr=0x%03h, data=0x%02h (应该为新值)", addrb, rdatab);

        // 测试7: 复位测试
        $display("\n测试7: 复位测试");
        reset = 1;
        addra = 10'h000;
        addrb = 10'h001;
        #10;
        $display("  复位时读取:");
        $display("    端口A: addr=0x%03h, data=0x%02h (期望: 0x00)", addra, rdataa);
        $display("    端口B: addr=0x%03h, data=0x%02h (期望: 0x00)", addrb, rdatab);
        if (rdataa != 8'h00) $error("  错误: 复位时端口A读取值应该为0!");
        if (rdatab != 8'h00) $error("  错误: 复位时端口B读取值应该为0!");

        reset = 0;
        #10;
        $display("  复位释放后读取:");
        $display("    端口A: addr=0x%03h, data=0x%02h (期望: 0xAA)", addra, rdataa);
        $display("    端口B: addr=0x%03h, data=0x%02h (期望: 0xBB)", addrb, rdatab);
        if (rdataa != 8'hAA) $error("  错误: 复位释放后端口A读取值不匹配!");
        if (rdatab != 8'hBB) $error("  错误: 复位释放后端口B读取值不匹配!");

        $display("\n=== 双口ROM测试完成 ===");
        #100;
        $finish;
    end

endmodule
