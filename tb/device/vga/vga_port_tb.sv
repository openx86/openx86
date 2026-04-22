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
//  File        : vga_port_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : vga_port_tb module
// ============================================================================

﻿

`timescale 1ns/1ns

module vga_port_tb;

    logic                    clk;
    logic rst_n;
    localparam int P_VRAM_AW = 8;
    logic [P_VRAM_AW-1: 0]   vram_rd_addr;
    logic [ 7: 0]            vram_rd_data;
    logic                    vga_hsync;
    logic                    vga_vsync;
    logic [ 3: 0]            vga_r;
    logic [ 3: 0]            vga_g;
    logic [ 3: 0]            vga_b;
    logic [$clog2(800)-1: 0] h_count;
    logic [$clog2(525)-1: 0] v_count;
    logic                    video_active;
    integer                  frame_count;
    integer                  hsync_count;
    integer                  visible_pixels;
    integer                  non_visible_pixels;

    // 模拟VRAM数据
    logic [ 7: 0] vram_mem [ 0: 255];
    
    initial begin
        // 初始化VRAM数据
        for (int i = 0; i < 256; i++) begin
            vram_mem[i] = i[ 7: 0];
        end
    end

    // VRAM读取模拟
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            vram_rd_data <= vram_mem[vram_rd_addr];
        end else begin
            vram_rd_data <= 8'h00;
        end
    end

    vga_port #(
        .P_VRAM_ADDR_WIDTH ( P_VRAM_AW )
    ) dut (
        .vram_rd_addr ( vram_rd_addr ),
        .vram_rd_data ( vram_rd_data ),
        .vga_hsync    ( vga_hsync    ),
        .vga_vsync    ( vga_vsync    ),
        .vga_r        ( vga_r        ),
        .vga_g        ( vga_g        ),
        .vga_b        ( vga_b        ),
        .h_count      ( h_count      ),
        .v_count      ( v_count      ),
        .video_active ( video_active  ),
        .clk        ( clk        ),
        .rst_n        ( rst_n )
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

        $display("=== VGA port test start ===");
        $display("Time: %t", $time);

        // Test 1: Check timing parameters
        $display("\nTest 1: Check timing parameters");
        $display("  Total horizontal: 800 pixels");
        $display("  Total vertical: 525 lines");
        $display("  Visible: 640x480");

        // Test 2: Wait for one full frame
        $display("\nTest 2: Wait for one full frame");
        frame_count = 0;

        @(posedge vga_vsync);
        $display("  Frame start (VSYNC rising)");

        @(negedge vga_vsync);
        $display("  Vertical sync start (VSYNC falling)");

        @(posedge vga_vsync);
        $display("  Vertical sync end (VSYNC rising)");
        frame_count++;
        $display("  Frame done %d", frame_count);

        // Test 3: Check horizontal sync
        $display("\nTest 3: Check horizontal sync");
        hsync_count = 0;

        // 等待几个HSYNC周期
        for (int i = 0; i < 10; i++) begin
            @(negedge vga_hsync);
            hsync_count++;
            $display("  HSYNC pulse %d (h_count=%0d, v_count=%0d)", hsync_count, h_count, v_count);
        end

        // Test 4: Check visible region
        $display("\nTest 4: Check visible region");
        visible_pixels = 0;
        non_visible_pixels = 0;
        
        // 等待进入可见区域
        wait(video_active == 1);
        $display("  Enter visible (h_count=%0d, v_count=%0d)", h_count, v_count);
        
        // 统计可见像素
        for (int i = 0; i < 1000; i++) begin
            @(posedge clk);
            if (video_active) begin
                visible_pixels++;
            end else begin
                non_visible_pixels++;
            end
        end
        $display("  Visible pixels: %d, blanking pixels: %d", visible_pixels, non_visible_pixels);

        // Test 5: Check VRAM address generation
        $display("\nTest 5: Check VRAM address generation");
        wait(video_active == 1);
        $display("  VRAM addr at visible start: 0x%02h", vram_rd_addr);
        
        // 等待一些时钟周期
        #2000;
        $display("  VRAM addr after 2000ns: 0x%02h", vram_rd_addr);

        // Test 6: Check color output
        $display("\nTest 6: Check color output");
        wait(video_active == 1);
        for (int i = 0; i < 10; i++) begin
            @(posedge clk);
            if (video_active) begin
                $display("  Pixel %d: RGB=(%1d,%1d,%1d), VRAM data=0x%02h", 
                         i, vga_r, vga_g, vga_b, vram_rd_data);
            end
        end

        // Test 7: Reset test
        $display("\nTest 7: Reset test");
        rst_n = 1'b0;
        #100;
        $display("  During reset: h_count=%0d, v_count=%0d, video_active=%0d", 
                 h_count, v_count, video_active);
        if (h_count != 0 || v_count != 0) $error("  error: counters must be 0 during reset!");
        if (video_active != 0) $error("  error: video_active must be 0 during reset!");

        rst_n = 1'b1;
        #100;
        $display("  After reset release: h_count=%0d, v_count=%0d", h_count, v_count);

        // Test 8: Check full-frame timing
        $display("\nTest 8: Check full-frame timing");
        rst_n = 1;
        #100;
        rst_n = 0;
        
        // 等待一帧
        wait(v_count == 0 && h_count == 0);
        $display("  Frame start: h_count=0, v_count=0");
        
        // 等待到可见区域
        wait(video_active == 1);
        $display("  Enter visible: h_count=%0d, v_count=%0d", h_count, v_count);
        
        // 等待到可见区域结束
        wait(video_active == 0);
        $display("  Leave visible: h_count=%0d, v_count=%0d", h_count, v_count);
        
        // 等待帧结束
        wait(v_count == 524 && h_count == 799);
        $display("  Frame end: h_count=799, v_count=524");

        $display("\n=== VGA port test done ===");
        #1000;
        $finish();
    end

endmodule

