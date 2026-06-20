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
//  File        : vga_font_rom_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : vga_font_rom_tb module
// ============================================================================

﻿

`timescale 1ns/1ns

module vga_font_rom_tb;

    logic        clk;
    logic rst_n;
    logic [ 7: 0]  char_code;
    logic [ 3: 0]  row_index;
    logic [ 7: 0]  font_data;

    vga_font_rom dut (
        .char_code  ( char_code  ),
        .row_index  ( row_index  ),
        .font_data  ( font_data  ),
        .clk      ( clk      ),
        .rst_n      ( rst_n )
    );

    // 时钟生成（25.175MHz，VGA标准像素时钟）
    always #19.86 clk = ~clk;

    initial begin
        $readmemh("rtl/device/vga/vga_font_8x16.hex", dut.font_rom_inst.rom);
        clk     = 0;
        rst_n     = 1;
        char_code = '0;
        row_index = '0;

        // 复位
        #40;
        rst_n = 0;
        #40;

        $display("=== VGA font ROM test start ===");
        $display("Time: %t", $time);

        // Test 1: Read char'A' (ASCII 0x41) all rows
        $display("\nTest 1: Read char'A' (ASCII 0x41) all rows");
        char_code = 8'h41;  // 'A'
        for (int i = 0; i < 16; i++) begin
            row_index = i[ 3: 0];
            #40;
            $display("  char 'A' row %2d: data=0x%02h (binary: %08b)", i, font_data, font_data);
        end

        // Test 2: Read char'0' (ASCII 0x30) all rows
        $display("\nTest 2: Read char'0' (ASCII 0x30) all rows");
        char_code = 8'h30;  // '0'
        for (int i = 0; i < 16; i++) begin
            row_index = i[ 3: 0];
            #40;
            $display("  char '0' row %2d: data=0x%02h", i, font_data);
        end

        // Test 3: Read char'@' (ASCII 0x40) all rows
        $display("\nTest 3: Read char'@' (ASCII 0x40) all rows");
        char_code = 8'h40;  // '@'
        for (int i = 0; i < 16; i++) begin
            row_index = i[ 3: 0];
            #40;
            $display("  char '@' row %2d: data=0x%02h", i, font_data);
        end

        // Test 4: 读取不同字符的同一行
        $display("\nTest 4: read row 0 for different characters");
        row_index = 4'h0;
        for (int i = 0; i < 10; i++) begin
            char_code = 8'h30 + i;  // '0' 到 '9'
            #40;
            $display("  char '%c' (0x%02h) row 0: data=0x%02h", 8'h30 + i, char_code, font_data);
        end

        // Test 5: Boundary test - 字符码0和255
        $display("\nTest 5: Boundary test");
        char_code = 8'h00;  // 字符码0
        row_index = 4'h0;
        #40;
        $display("  char code 0x00 row 0: data=0x%02h", font_data);

        char_code = 8'hFF;  // 字符码255
        row_index = 4'h0;
        #40;
        $display("  char code 0xFF row 0: data=0x%02h", font_data);

        // Test 6: 行索引Boundary test
        $display("\nTest 6: row index boundary");
        char_code = 8'h41;  // 'A'
        row_index = 4'h0;
        #40;
        $display("  char 'A' row 0: data=0x%02h", font_data);

        row_index = 4'hF;  // 第15行
        #40;
        $display("  char 'A' row 15: data=0x%02h", font_data);

        // Test 7: Reset test
        $display("\nTest 7: Reset test");
        rst_n = 1;
        char_code = 8'h41;
        row_index = 4'h0;
        #40;
        $display("  Read during reset: data=0x%02h (expected: 0x00)", font_data);
        if (font_data != 8'h00) $error("  error: font data must be 0 during reset!");

        rst_n = 0;
        #40;
        $display("  Read after reset release: data=0x%02h", font_data);

        // Test 8: Fast char/row switching
        $display("\nTest 8: Fast char/row switching");
        for (int c = 0; c < 5; c++) begin
            char_code = 8'h41 + c;  // 'A' 到 'E'
            for (int r = 0; r < 3; r++) begin
                row_index = r[ 3: 0];
                #40;
                $display("  char '%c' row %2d: data=0x%02h", 8'h41 + c, r, font_data);
            end
        end

        $display("\n=== VGA font ROM test done ===");
        #200;
        $finish();
    end

endmodule
