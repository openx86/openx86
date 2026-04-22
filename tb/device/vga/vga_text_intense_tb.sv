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
//  File        : vga_text_intense_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : vga_text_intense_tb module
// ============================================================================

`timescale 1ns/1ns

module vga_text_intense_tb;

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
    logic [ 7: 0] text_vram [ 0: 3999];
    
    initial begin
        // 初始化文本VRAM
        // 第一行：字符'A' (0x41) 带不同属性
        for (int i = 0; i < 80; i++) begin
            text_vram[i * 2] = 8'h41 + (i % 26);  // 字符码：'A' 到 'Z'
            text_vram[i * 2 + 1] = {1'b0, 3'h0, 4'hF - (i % 16)};  // 属性：不同前景色
        end
    end

    // VRAM读取模拟
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            if (vram_rd_addr < 4000) begin
                if (vram_rd_addr[0] == 1'b0) begin
                    vram_char_data <= text_vram[vram_rd_addr];
                end else begin
                    vram_attr_data <= text_vram[vram_rd_addr];
                end
            end
        end else begin
            vram_char_data <= 8'h00;
            vram_attr_data <= 8'h00;
        end
    end

    // 模拟字体ROM
    always_ff @(posedge clk) begin
        if (!rst_n) begin
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
    

    vga_text_intense dut (
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

        $display("=== VGA text intense test start ===");
        $display("Time: %t", $time);

        // Test 1: Check character position
        $display("\nTest 1: Check character position");
        h_cnt = 0;
        v_cnt = 0;
        #100;
        $display("  Pos (0,0): char_col=%0d, char_row=%0d, vram_addr=0x%04h", 
                 h_cnt[ 9:  3], v_cnt[ 8:  4], vram_rd_addr);

        // Test 2: Check high-intensity foreground
        $display("\nTest 2: Check high-intensity foreground");
        h_cnt = 0;
        v_cnt = 0;
        video_active = 1;
        #300;
        $display("  High-intensity FG: RGB=(%1d,%1d,%1d)", vga_r, vga_g, vga_b);

        // Test 3: Sweep high-intensity foreground
        $display("\nTest 3: Sweep high-intensity foreground");
        for (int i = 0; i < 16; i++) begin
            h_cnt = i * 8;
            v_cnt = 0;
            #200;
            $display("  High-intensity FG %0d: RGB=(%1d,%1d,%1d)", i, vga_r, vga_g, vga_b);
        end

        // Test 4: Background color（应该与标准模式相同）
        $display("\nTest 4: Background color");
        h_cnt = 0;
        v_cnt = 0;
        #200;
        $display("  Background: RGB=(%1d,%1d,%1d)", vga_r, vga_g, vga_b);

        // Test 5: Reset test
        $display("\nTest 5: Reset test");
        rst_n = 1'b0;
        #100;
        $display("  During reset: RGB=(%1d,%1d,%1d) (expected: 0,0,0)", vga_r, vga_g, vga_b);
        if (vga_r != 0 || vga_g != 0 || vga_b != 0) 
            $error("  error: RGB must be 0 during reset!");

        rst_n = 1'b1;
        #100;

        // Test 6: Blanking region
        $display("\nTest 6: Blanking region");
        h_cnt = 700;
        v_cnt = 0;
        video_active = 0;
        #100;
        $display("  Blanking: RGB=(%1d,%1d,%1d) (expected: 0,0,0)", vga_r, vga_g, vga_b);
        if (vga_r != 0 || vga_g != 0 || vga_b != 0) 
            $error("  error: RGB must be 0 in blanking!");

        $display("\n=== VGA text intense test done ===");
        #1000;
        $finish();
    end

endmodule
