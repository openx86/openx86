/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements vga_graphics_adapter_tb.
*/
// project: openx86
// description: test vga_graphics_adapter (VGA Graphics Adapter)

`timescale 1ns/1ns

module vga_graphics_adapter_tb;

    logic        clock;
    logic        reset;
    logic        io_en_w;
    logic        io_en_r;
    logic [15: 0] io_addr;
    logic [ 7: 0] io_data_w;
    logic [ 7: 0] io_data_r;
    logic        mem_en_w;
    logic [19: 0] mem_addr;
    logic [ 7: 0]  mem_data_w;
    logic        vga_hsync;
    logic        vga_vsync;
    logic [ 3: 0]  vga_r;
    logic [ 3: 0]  vga_g;
    logic [ 3: 0]  vga_b;
    int          vsync_count;

    vga_graphics_adapter dut (
        .io_en_w   ( io_en_w   ),
        .io_en_r   ( io_en_r   ),
        .io_addr   ( io_addr   ),
        .io_data_w ( io_data_w ),
        .io_data_r ( io_data_r ),
        .mem_en_w  ( mem_en_w  ),
        .mem_addr  ( mem_addr  ),
        .mem_data_w( mem_data_w),
        .vga_hsync ( vga_hsync ),
        .vga_vsync ( vga_vsync ),
        .vga_r     ( vga_r     ),
        .vga_g     ( vga_g     ),
        .vga_b     ( vga_b     ),
        .clock     ( clock     ),
        .reset_n     ( reset     )
    );

    // 时钟生成（25.175MHz，VGA标准像素时钟）
    always #19.86 clock = ~clock;

    initial begin
        $readmemh("rtl/device/vga/vga_font_8x16.hex", dut.font_rom_inst.font_rom_inst.rom);
        clock     = 0;
        reset     = 1;
        io_en_w   = 0;
        io_en_r   = 0;
        io_addr   = '0;
        io_data_w = '0;
        mem_en_w  = 0;
        mem_addr  = '0;
        mem_data_w= '0;

        // 复位
        #100;
        reset = 0;
        #100;

        $display("=== VGA graphics adapter test start ===");
        $display("Time: %t", $time);

        // Test 1: I/O write - MISC output register
        $display("\nTest 1: I/O write - MISC output register");
        io_en_w = 1;
        io_addr = 16'h03C2;
        io_data_w = 8'h01;
        #40;
        io_en_w = 0;
        $display("  Write MISC: 0x%02h", io_data_w);

        // Test 2: I/O read - MISC output register
        $display("\nTest 2: I/O read - MISC output register");
        io_en_r = 1;
        io_addr = 16'h03C2;
        #40;
        $display("  Read MISC: 0x%02h (expected: 0x01)", io_data_r);
        if (io_data_r != 8'h01) $error("  error: MISC register read mismatch!");
        io_en_r = 0;

        // Test 3: I/O read - status register 1
        $display("\nTest 3: I/O read - status register 1");
        io_en_r = 1;
        io_addr = 16'h03DA;
        #40;
        $display("  Read status: 0x%02h (VSYNC=%0d, HSYNC=%0d)", 
                 io_data_r, io_data_r[4], io_data_r[3]);
        io_en_r = 0;

        // Test 4: Mode select - graphics
        $display("\nTest 4: Mode select - graphics");
        io_en_w = 1;
        io_addr = 16'h03C0;
        io_data_w = 2'b00;  // 图形模式
        #40;
        io_en_w = 0;
        $display("  Set mode: graphics");

        // Test 5: VRAM写入和读取（图形模式）
        $display("\nTest 5: VRAM write (graphics mode)");
        mem_en_w = 1;
        for (int i = 0; i < 10; i++) begin
            mem_addr = i;
            mem_data_w = 8'hAA + i;
            #40;
            $display("  Write VRAM: addr=0x%05h, data=0x%02h", mem_addr, mem_data_w);
        end
        mem_en_w = 0;

        // Test 6: Mode select - color text
        $display("\nTest 6: Mode select - color text");
        io_en_w = 1;
        io_addr = 16'h03C0;
        io_data_w = 2'b01;  // 彩色文本模式
        #40;
        io_en_w = 0;
        $display("  Set mode: color text");

        // Test 7: VRAM写入（文本模式：字符码和属性）
        $display("\nTest 7: VRAM write (text mode)");
        mem_en_w = 1;
        // 写入第一行第一列的字符和属性
        mem_addr = 0;  // 字符码地址（偶数）
        mem_data_w = 8'h41;  // 'A'
        #40;
        mem_addr = 1;  // 属性地址（奇数）
        mem_data_w = 8'h0F;  // 白色前景，黑色背景
        #40;
        $display("  text write: char=0x%02h, attr=0x%02h", 8'h41, 8'h0F);
        mem_en_w = 0;

        // Test 8: Mode select - high-intensity text
        $display("\nTest 8: Mode select - high-intensity text");
        io_en_w = 1;
        io_addr = 16'h03C0;
        io_data_w = 2'b10;  // 淡色文本模式
        #40;
        io_en_w = 0;
        $display("  Set mode: high-intensity text");

        // Test 9: Check VGA sync
        $display("\nTest 9: Check VGA sync");
        vsync_count = 0;

        // 等待VSYNC上升沿
        @(posedge vga_vsync);
        vsync_count++;
        $display("  VSYNC rising edge detected %d", vsync_count);

        // 等待VSYNC下降沿
        @(negedge vga_vsync);
        $display("  VSYNC falling edge detected");

        // 等待HSYNC
        @(negedge vga_hsync);
        $display("  HSYNC falling edge detected");

        // Test 10: Check color output
        $display("\nTest 10: Check color output");
        #1000;  // 等待进入可见区域
        $display("  VGA color: RGB=(%1d,%1d,%1d)", vga_r, vga_g, vga_b);

        // Test 11: Reset test
        $display("\nTest 11: Reset test");
        reset = 1;
        #100;
        $display("  During reset: RGB=(%1d,%1d,%1d) (expected: 0,0,0)", vga_r, vga_g, vga_b);
        if (vga_r != 0 || vga_g != 0 || vga_b != 0) 
            $error("  error: RGB must be 0 during reset!");

        // Test 12: Read registers after reset
        $display("\nTest 12: Read registers after reset");
        reset = 0;
        #100;
        io_en_r = 1;
        io_addr = 16'h03C2;
        #40;
        $display("  MISC register after reset: 0x%02h", io_data_r);
        io_en_r = 0;

        // Test 13: 测试多个模式切换
        $display("\nTest 13: multiple mode switches");
        for (int mode = 0; mode < 3; mode++) begin
            io_en_w = 1;
            io_addr = 16'h03C0;
            io_data_w = mode[ 1: 0];
            #40;
            io_en_w = 0;
            $display("  Switch to mode: %0d", mode);
            #200;
        end

        $display("\n=== VGA graphics adapter test done ===");
        #2000;
        $finish();
    end

endmodule
