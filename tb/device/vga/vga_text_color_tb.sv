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
//  File        : vga_text_color_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : vga_text_color_tb module
// ============================================================================

`timescale 1ns/1ns

module vga_text_color_tb;

    logic                    clk;
    logic                    rst_n;
    logic [12: 0]            vram_rd_addr;
    logic [ 7: 0]            vram_char_data;
    logic [ 7: 0]            vram_attr_data;
    logic [ 7: 0]            font_char_code;
    logic [ 3: 0]            font_row_index;
    logic [ 7: 0]            font_data;
    logic [ 3: 0]            vga_r;
    logic [ 3: 0]            vga_g;
    logic [ 3: 0]            vga_b;
    logic [$clog2(800)-1: 0] h_count = h_cnt[$clog2(800)-1:0];
    logic [$clog2(525)-1: 0] v_count = v_cnt[$clog2(525)-1:0];
    logic                    video_active;

    // 模拟文本VRAM（80x25 = 2000字符 = 4000字节）
    // 偶数地址：字符码，奇数地址：属性字节
    logic [ 7: 0] text_vram [ 0: 3999];
    
    initial begin
        // 初始化文本VRAM
        // 第一行：字符'A' (0x41) 带不同属性
        for (int i = 0; i < 80; i++) begin
            text_vram[i * 2] = 8'h41 + (i % 26);  // 字符码：'A' 到 'Z'
            text_vram[i * 2 + 1] = {1'b0, 3'h0, 4'hF - (i % 16)};  // 属性：不同前景色
        end
        
        // 第二行：字符'0' (0x30) 带背景色
        for (int i = 0; i < 80; i++) begin
            text_vram[160 + i * 2] = 8'h30 + (i % 10);  // 字符码：'0' 到 '9'
            text_vram[160 + i * 2 + 1] = {1'b0, 3'h1 + (i % 7), 4'hF};  // 属性：不同背景色
        end
    end

    // VRAM读取模拟（需要根据地址返回字符或属性）
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            if (vram_rd_addr < 4000) begin
                if (vram_rd_addr[0] == 1'b0) begin
                    // 偶数地址：字符码
                    vram_char_data <= text_vram[vram_rd_addr];
                end else begin
                    // 奇数地址：属性字节
                    vram_attr_data <= text_vram[vram_rd_addr];
                end
            end
        end else begin
            vram_char_data <= 8'h00;
            vram_attr_data <= 8'h00;
        end
    end

    // 模拟字体ROM（简化：返回字符码作为测试数据）
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            // 简化：返回字符码的低8位作为字体数据（仅用于测试）
            font_data <= font_char_code;
        end else begin
            font_data <= 8'h00;
        end
    end

    // 模拟时序生成器
    logic [ 9: 0] h_cnt;
    logic [ 9: 0] v_cnt;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            h_cnt <= '0;
            v_cnt <= '0;
            video_active <= 0;
        end else begin
            if (h_cnt == 799) begin
                h_cnt <= '0;
                if (v_cnt == 524) begin
                    v_cnt <= '0;
                end else begin
                    v_cnt <= v_cnt + 1;
                end
            end else begin
                h_cnt <= h_cnt + 1;
            end
            
            video_active <= (h_cnt < 640) && (v_cnt < 480);
        end
    end
    

    vga_text_color dut (
        .vram_rd_addr  ( vram_rd_addr  ),
        .vram_char_data( vram_char_data),
        .vram_attr_data( vram_attr_data),
        .font_char_code( font_char_code),
        .font_row_index( font_row_index),
        .font_data    ( font_data      ),
        .vga_r        ( vga_r          ),
        .vga_g        ( vga_g          ),
        .vga_b        ( vga_b          ),
        .h_count      ( h_count        ),
        .v_count      ( v_count        ),
        .video_active ( video_active   ),
        .clk        ( clk          ),
        .rst_n        ( rst_n          )
    );

    // 时钟生成（25.175MHz，VGA标准像素时钟）
    always #19.86 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 1;

        // 复位
        #100;
        rst_n = 0;
        #100;

        $display("=== VGA text color test start ===");
        $display("Time: %t", $time);

        // Test 1: Check character position
        $display("\nTest 1: Check character position");
        // 设置到第一行第一列
        h_cnt = 0;
        v_cnt = 0;
        #100;
        $display("  Pos (0,0): char_col=%0d, char_row=%0d, vram_addr=0x%04h", 
                 h_cnt[ 9:  3], v_cnt[ 8:  4], vram_rd_addr);
        
        // 设置到第一行第二列
        h_cnt = 8;
        v_cnt = 0;
        #100;
        $display("  Pos (1,0): char_col=%0d, char_row=%0d, vram_addr=0x%04h", 
                 h_cnt[ 9:  3], v_cnt[ 8:  4], vram_rd_addr);

        // Test 2: Check attribute decode
        $display("\nTest 2: Check attribute decode");
        h_cnt = 0;
        v_cnt = 0;
        video_active = 1;
        #200;  // 等待流水线
        $display("  Char code: 0x%02h, attr: 0x%02h", vram_char_data, vram_attr_data);
        $display("  Foreground: %0d, Background: %0d", 
                 vram_attr_data[ 3: 0], vram_attr_data[ 6:  4]);

        // Test 3: Check color output
        $display("\nTest 3: Check color output");
        h_cnt = 0;
        v_cnt = 0;
        video_active = 1;
        #300;  // 等待流水线完成
        $display("  Pixel color: RGB=(%1d,%1d,%1d)", vga_r, vga_g, vga_b);

        // Test 4: Sweep foreground colors
        $display("\nTest 4: Sweep foreground colors");
        for (int i = 0; i < 16; i++) begin
            h_cnt = i * 8;
            v_cnt = 0;
            #200;
            $display("  Foreground %0d: RGB=(%1d,%1d,%1d)", i, vga_r, vga_g, vga_b);
        end

        // Test 5: Sweep background colors
        $display("\nTest 5: Sweep background colors");
        h_cnt = 0;
        v_cnt = 16;  // 第二行
        #200;
        $display("  Background sweep: RGB=(%1d,%1d,%1d)", vga_r, vga_g, vga_b);

        // Test 6: Character pixel on/off（字符前景/背景）
        $display("\nTest 6: Character pixel on/off");
        h_cnt = 0;
        v_cnt = 0;
        #300;
        $display("  Char pixel: RGB=(%1d,%1d,%1d)", vga_r, vga_g, vga_b);
        
        // Test 7: Reset test
        $display("\nTest 7: Reset test");
        rst_n = 1'b0;
        #100;
        $display("  During reset: RGB=(%1d,%1d,%1d) (expected: 0,0,0)", vga_r, vga_g, vga_b);
        if (vga_r != 0 || vga_g != 0 || vga_b != 0) 
            $error("  error: RGB must be 0 during reset!");

        rst_n = 1'b1;
        #100;

        // Test 8: Blanking region
        $display("\nTest 8: Blanking region");
        h_cnt = 700;  // 超出可见区域
        v_cnt = 0;
        video_active = 0;
        #100;
        $display("  Blanking: RGB=(%1d,%1d,%1d) (expected: 0,0,0)", vga_r, vga_g, vga_b);
        if (vga_r != 0 || vga_g != 0 || vga_b != 0) 
            $error("  error: RGB must be 0 in blanking!");

        $display("\n=== VGA text color test done ===");
        #1000;
        $finish();
    end

endmodule
