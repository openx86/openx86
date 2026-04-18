/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements vga_text_color_tb.
*/
// project: openx86
// description: test vga_text_color module

`timescale 1ns/1ns

module vga_text_color_tb;

    logic                    clock;
    logic                    reset;
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
    always_ff @(posedge clock) begin
        if (!reset) begin
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
    always_ff @(posedge clock) begin
        if (!reset) begin
            // 简化：返回字符码的低8位作为字体数据（仅用于测试）
            font_data <= font_char_code;
        end else begin
            font_data <= 8'h00;
        end
    end

    // 模拟时序生成器
    logic [ 9: 0] h_cnt;
    logic [ 9: 0] v_cnt;
    
    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
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
        .clock        ( clock          ),
        .reset_n        ( reset          )
    );

    // 时钟生成（25.175MHz，VGA标准像素时钟）
    always #19.86 clock = ~clock;

    initial begin
        clock = 0;
        reset = 1;

        // 复位
        #100;
        reset = 0;
        #100;

        $display("=== VGA Text Color 测试开始 ===");
        $display("时间: %t", $time);

        // 测试1: 检查字符位置计算
        $display("\n测试1: 检查字符位置计算");
        // 设置到第一行第一列
        h_cnt = 0;
        v_cnt = 0;
        #100;
        $display("  位置 (0,0): char_col=%0d, char_row=%0d, vram_addr=0x%04h", 
                 h_cnt[ 9:  3], v_cnt[ 8:  4], vram_rd_addr);
        
        // 设置到第一行第二列
        h_cnt = 8;
        v_cnt = 0;
        #100;
        $display("  位置 (1,0): char_col=%0d, char_row=%0d, vram_addr=0x%04h", 
                 h_cnt[ 9:  3], v_cnt[ 8:  4], vram_rd_addr);

        // 测试2: 检查属性解码
        $display("\n测试2: 检查属性解码");
        h_cnt = 0;
        v_cnt = 0;
        video_active = 1;
        #200;  // 等待流水线
        $display("  字符码: 0x%02h, 属性: 0x%02h", vram_char_data, vram_attr_data);
        $display("  前景色: %0d, 背景色: %0d", 
                 vram_attr_data[ 3: 0], vram_attr_data[ 6:  4]);

        // 测试3: 检查颜色输出
        $display("\n测试3: 检查颜色输出");
        h_cnt = 0;
        v_cnt = 0;
        video_active = 1;
        #300;  // 等待流水线完成
        $display("  像素颜色: RGB=(%1d,%1d,%1d)", vga_r, vga_g, vga_b);

        // 测试4: 测试不同前景色
        $display("\n测试4: 测试不同前景色");
        for (int i = 0; i < 16; i++) begin
            h_cnt = i * 8;
            v_cnt = 0;
            #200;
            $display("  前景色 %0d: RGB=(%1d,%1d,%1d)", i, vga_r, vga_g, vga_b);
        end

        // 测试5: 测试不同背景色
        $display("\n测试5: 测试不同背景色");
        h_cnt = 0;
        v_cnt = 16;  // 第二行
        #200;
        $display("  背景色测试: RGB=(%1d,%1d,%1d)", vga_r, vga_g, vga_b);

        // 测试6: 测试像素开关（字符前景/背景）
        $display("\n测试6: 测试像素开关");
        h_cnt = 0;
        v_cnt = 0;
        #300;
        $display("  字符像素: RGB=(%1d,%1d,%1d)", vga_r, vga_g, vga_b);
        
        // 测试7: 复位测试
        $display("\n测试7: 复位测试");
        reset = 1;
        #100;
        $display("  复位时: RGB=(%1d,%1d,%1d) (期望: 0,0,0)", vga_r, vga_g, vga_b);
        if (vga_r != 0 || vga_g != 0 || vga_b != 0) 
            $error("  错误: 复位时颜色应该为0!");

        reset = 0;
        #100;

        // 测试8: 测试非可见区域
        $display("\n测试8: 测试非可见区域");
        h_cnt = 700;  // 超出可见区域
        v_cnt = 0;
        video_active = 0;
        #100;
        $display("  非可见区域: RGB=(%1d,%1d,%1d) (期望: 0,0,0)", vga_r, vga_g, vga_b);
        if (vga_r != 0 || vga_g != 0 || vga_b != 0) 
            $error("  错误: 非可见区域颜色应该为0!");

        $display("\n=== VGA Text Color 测试完成 ===");
        #1000;
        $finish();
    end

endmodule
