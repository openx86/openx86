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
//  File        : vga_text_color.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : vga_text_color module
// ============================================================================

// VGA 彩色文本模式
// 支持 80x25 字符，16 色前景 + 8 色背景
// 属性字节格式：[7:闪烁][6:4背景色][3:0前景色]

module vga_text_color (
    // =========================
    // VRAM read interface (text mode: 80x25 = 2000 chars = 4000 bytes)
    // =========================
    output logic [12: 0]          vram_rd_addr,
    input  logic [ 7: 0]           vram_char_data,
    input  logic [ 7: 0]           vram_attr_data,

    // =========================
    // font generator interface
    // =========================
    output logic [ 7: 0]          font_char_code,
    output logic [ 3: 0]          font_row_index,
    input  logic [ 7: 0]           font_data,

    // =========================
    // VGA output
    // =========================
    output logic [ 3: 0]          vga_r,
    output logic [ 3: 0]          vga_g,
    output logic [ 3: 0]          vga_b,

    // =========================
    // timing input
    // =========================
    input  logic [$clog2(800)-1: 0] h_count,
    input  logic [$clog2(525)-1: 0] v_count,
    input  logic                   video_active,

    // =========================
    // clock and reset
    // =========================
    input  logic                   rst_n,
    input  logic                   clk
);

    // ============================================================
    // text mode parameters
    // ============================================================
    localparam int TEXT_COLS = 80;
    localparam int TEXT_ROWS = 25;
    localparam int CHAR_WIDTH = 8;
    localparam int CHAR_HEIGHT = 16;
    localparam int PIXELS_PER_CHAR = CHAR_WIDTH * CHAR_HEIGHT;

    // ============================================================
    // current character position
    // ============================================================
    logic [ 6: 0] char_col;
    logic [ 4: 0] char_row;
    logic [ 3: 0] char_pixel_x;
    logic [ 3: 0] char_pixel_y;

    assign char_col = h_count[ 9:  3];
    assign char_row = v_count[ 8:  4];
    assign char_pixel_x = {1'b0, h_count[ 2: 0]};
    assign char_pixel_y = v_count[ 3: 0];

    // ============================================================
    // character and attribute registers
    // ============================================================
    logic [ 7: 0] char_code_reg;
    logic [ 7: 0] attr_reg;
    logic [ 7: 0] font_data_reg;

    // ============================================================
    // attribute decode
    // ============================================================
    logic [ 2: 0] bg_color;
    logic [ 3: 0] fg_color;
    logic         pixel_on;

    assign bg_color = attr_reg[ 6:  4];
    assign fg_color = attr_reg[ 3: 0];
    assign pixel_on = font_data_reg[7 - char_pixel_x[ 2: 0]];

    // ============================================================
    // VRAM address calculation: address = (char_row * 80 + char_col) * 2
    // ============================================================
    assign vram_rd_addr = {char_row, 7'h00} + {5'h00, char_col, 1'b0};

    // ============================================================
    // font generator interface
    // ============================================================
    assign font_char_code = char_code_reg;
    assign font_row_index = char_pixel_y;

    // ============================================================
    // first stage pipeline: latch character code and attribute
    // ============================================================
    always_ff @(posedge clk or negedge rst_n) begin : ff_char_attr_latch
        if (~rst_n) begin
            char_code_reg <= '0;
            attr_reg <= '0;
        end else begin
            if (video_active) begin
                if (vram_rd_addr[0] == 1'b0) begin
                    char_code_reg <= vram_char_data;
                end else begin
                    attr_reg <= vram_attr_data;
                end
            end
        end
    end

    // 第二级流水：锁存点阵行
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            font_data_reg <= '0;
        end else begin
            if (video_active) begin
                font_data_reg <= font_data;
            end
        end
    end

    // 16 色前景 + 8 色背景查表输出
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            vga_r <= 4'h0;
            vga_g <= 4'h0;
            vga_b <= 4'h0;
        end else begin
            if (video_active) begin
                if (pixel_on) begin
                    // 前景 16 色
                    unique case (fg_color)
                        4'h0: begin vga_r <= 4'h0; vga_g <= 4'h0; vga_b <= 4'h0; end  // 黑
                        4'h1: begin vga_r <= 4'h0; vga_g <= 4'h0; vga_b <= 4'hA; end  // 蓝
                        4'h2: begin vga_r <= 4'h0; vga_g <= 4'hA; vga_b <= 4'h0; end  // 绿
                        4'h3: begin vga_r <= 4'h0; vga_g <= 4'hA; vga_b <= 4'hA; end  // 青
                        4'h4: begin vga_r <= 4'hA; vga_g <= 4'h0; vga_b <= 4'h0; end  // 红
                        4'h5: begin vga_r <= 4'hA; vga_g <= 4'h0; vga_b <= 4'hA; end  // 品红
                        4'h6: begin vga_r <= 4'hA; vga_g <= 4'h5; vga_b <= 4'h0; end  // 棕
                        4'h7: begin vga_r <= 4'hA; vga_g <= 4'hA; vga_b <= 4'hA; end  // 浅灰
                        4'h8: begin vga_r <= 4'h5; vga_g <= 4'h5; vga_b <= 4'h5; end  // 深灰
                        4'h9: begin vga_r <= 4'h5; vga_g <= 4'h5; vga_b <= 4'hF; end  // 浅蓝
                        4'hA: begin vga_r <= 4'h5; vga_g <= 4'hF; vga_b <= 4'h5; end  // 浅绿
                        4'hB: begin vga_r <= 4'h5; vga_g <= 4'hF; vga_b <= 4'hF; end  // 浅青
                        4'hC: begin vga_r <= 4'hF; vga_g <= 4'h5; vga_b <= 4'h5; end  // 浅红
                        4'hD: begin vga_r <= 4'hF; vga_g <= 4'h5; vga_b <= 4'hF; end  // 浅品红
                        4'hE: begin vga_r <= 4'hF; vga_g <= 4'hF; vga_b <= 4'h5; end  // 黄
                        4'hF: begin vga_r <= 4'hF; vga_g <= 4'hF; vga_b <= 4'hF; end  // 白
                    endcase
                end else begin
                    // 背景 8 色
                    unique case (bg_color)
                        3'h0: begin vga_r <= 4'h0; vga_g <= 4'h0; vga_b <= 4'h0; end  // 黑
                        3'h1: begin vga_r <= 4'h0; vga_g <= 4'h0; vga_b <= 4'hA; end  // 蓝
                        3'h2: begin vga_r <= 4'h0; vga_g <= 4'hA; vga_b <= 4'h0; end  // 绿
                        3'h3: begin vga_r <= 4'h0; vga_g <= 4'hA; vga_b <= 4'hA; end  // 青
                        3'h4: begin vga_r <= 4'hA; vga_g <= 4'h0; vga_b <= 4'h0; end  // 红
                        3'h5: begin vga_r <= 4'hA; vga_g <= 4'h0; vga_b <= 4'hA; end  // 品红
                        3'h6: begin vga_r <= 4'hA; vga_g <= 4'h5; vga_b <= 4'h0; end  // 棕
                        3'h7: begin vga_r <= 4'hA; vga_g <= 4'hA; vga_b <= 4'hA; end  // 浅灰
                    endcase
                end
            end else begin
                vga_r <= 4'h0;
                vga_g <= 4'h0;
                vga_b <= 4'h0;
            end
        end
    end

endmodule
