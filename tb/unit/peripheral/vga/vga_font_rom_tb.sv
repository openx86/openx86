/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements vga_font_rom_tb.
*/
// project: openx86
// description: test vga_font_rom module

`timescale 1ns/1ns

module vga_font_rom_tb;

    logic        clock;
    logic        reset;
    logic [ 7: 0]  char_code;
    logic [ 3: 0]  row_index;
    logic [ 7: 0]  font_data;

    vga_font_rom dut (
        .char_code  ( char_code  ),
        .row_index  ( row_index  ),
        .font_data  ( font_data  ),
        .clock      ( clock      ),
        .reset_n      ( reset      )
    );

    // 时钟生成（25.175MHz，VGA标准像素时钟）
    always #19.86 clock = ~clock;

    initial begin
        $readmemh("rtl/periph/vga_font_8x16.hex", dut.font_rom_inst.rom);
        clock     = 0;
        reset     = 1;
        char_code = '0;
        row_index = '0;

        // 复位
        #40;
        reset = 0;
        #40;

        $display("=== VGA Font ROM 测试开始 ===");
        $display("时间: %t", $time);

        // 测试1: 读取字符'A' (ASCII 0x41) 的所有行
        $display("\n测试1: 读取字符'A' (ASCII 0x41) 的所有行");
        char_code = 8'h41;  // 'A'
        for (int i = 0; i < 16; i++) begin
            row_index = i[ 3: 0];
            #40;
            $display("  字符'A' 第%2d行: data=0x%02h (二进制: %08b)", i, font_data, font_data);
        end

        // 测试2: 读取字符'0' (ASCII 0x30) 的所有行
        $display("\n测试2: 读取字符'0' (ASCII 0x30) 的所有行");
        char_code = 8'h30;  // '0'
        for (int i = 0; i < 16; i++) begin
            row_index = i[ 3: 0];
            #40;
            $display("  字符'0' 第%2d行: data=0x%02h", i, font_data);
        end

        // 测试3: 读取字符'@' (ASCII 0x40) 的所有行
        $display("\n测试3: 读取字符'@' (ASCII 0x40) 的所有行");
        char_code = 8'h40;  // '@'
        for (int i = 0; i < 16; i++) begin
            row_index = i[ 3: 0];
            #40;
            $display("  字符'@' 第%2d行: data=0x%02h", i, font_data);
        end

        // 测试4: 读取不同字符的同一行
        $display("\n测试4: 读取不同字符的第0行");
        row_index = 4'h0;
        for (int i = 0; i < 10; i++) begin
            char_code = 8'h30 + i;  // '0' 到 '9'
            #40;
            $display("  字符'%c' (0x%02h) 第0行: data=0x%02h", 8'h30 + i, char_code, font_data);
        end

        // 测试5: 边界测试 - 字符码0和255
        $display("\n测试5: 边界测试");
        char_code = 8'h00;  // 字符码0
        row_index = 4'h0;
        #40;
        $display("  字符码0x00 第0行: data=0x%02h", font_data);

        char_code = 8'hFF;  // 字符码255
        row_index = 4'h0;
        #40;
        $display("  字符码0xFF 第0行: data=0x%02h", font_data);

        // 测试6: 行索引边界测试
        $display("\n测试6: 行索引边界测试");
        char_code = 8'h41;  // 'A'
        row_index = 4'h0;
        #40;
        $display("  字符'A' 第0行: data=0x%02h", font_data);

        row_index = 4'hF;  // 第15行
        #40;
        $display("  字符'A' 第15行: data=0x%02h", font_data);

        // 测试7: 复位测试
        $display("\n测试7: 复位测试");
        reset = 1;
        char_code = 8'h41;
        row_index = 4'h0;
        #40;
        $display("  复位时读取: data=0x%02h (期望: 0x00)", font_data);
        if (font_data != 8'h00) $error("  错误: 复位时读取值应该为0!");

        reset = 0;
        #40;
        $display("  复位释放后读取: data=0x%02h", font_data);

        // 测试8: 快速切换字符和行
        $display("\n测试8: 快速切换字符和行");
        for (int c = 0; c < 5; c++) begin
            char_code = 8'h41 + c;  // 'A' 到 'E'
            for (int r = 0; r < 3; r++) begin
                row_index = r[ 3: 0];
                #40;
                $display("  字符'%c' 第%2d行: data=0x%02h", 8'h41 + c, r, font_data);
            end
        end

        $display("\n=== VGA Font ROM 测试完成 ===");
        #200;
        $finish();
    end

endmodule
