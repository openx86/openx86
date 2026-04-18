/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements vga_text_color.
*/
// VGA 彩色文本模式
// 支持 80x25 字符，16 色前景 + 8 色背景
// 属性字节格式：[7:闪烁][6:4背景色][3:0前景色]

module vga_text_color (
    // VRAM 读接口（文本模式：80x25 = 2000 字符 = 4000 字节）
    output logic [12: 0]          vram_rd_addr,   // 文本 VRAM 地址（0-3999）
    input  logic [ 7: 0]           vram_char_data, // 字符码（偶数地址）
    input  logic [ 7: 0]           vram_attr_data, // 属性字节（奇数地址）


    // 字符生成器接口
    output logic [ 7: 0]          font_char_code,
    output logic [ 3: 0]          font_row_index,
    input  logic [ 7: 0]           font_data,

    // VGA 输出
    output logic [ 3: 0]          vga_r,
    output logic [ 3: 0]          vga_g,
    output logic [ 3: 0]          vga_b,

    // 时序输入
    input  logic [$clog2(800)-1: 0] h_count,      // 水平计数（0-799）
    input  logic [$clog2(525)-1: 0] v_count,      // 垂直计数（0-524）
    input  logic                   video_active,

    // 时钟和复位
    input  logic                   reset_n,
    input  logic                   clock
);

    // 文本模式参数
    localparam int TEXT_COLS = 80;
    localparam int TEXT_ROWS = 25;
    localparam int CHAR_WIDTH = 8;
    localparam int CHAR_HEIGHT = 16;
    localparam int PIXELS_PER_CHAR = CHAR_WIDTH * CHAR_HEIGHT; // 128 像素/字符

    // 当前字符位置
    logic [ 6: 0] char_col = h_count[ 9:  3];  // 0-79
    logic [ 4: 0] char_row = v_count[ 8:  4];  // 0-24
    logic [ 3: 0] char_pixel_x = h_count[ 2: 0];  // 0-7（字符内 X）
    logic [ 3: 0] char_pixel_y = v_count[ 3: 0];  // 0-15（字符内 Y）

    // 字符和属性寄存器
    logic [ 7: 0] char_code_reg;
    logic [ 7: 0] attr_reg;
    logic [ 7: 0] font_data_reg;

    // 属性解码
    logic        blink = attr_reg[7];  // 闪烁位
    logic [ 2: 0]  bg_color = attr_reg[ 6:  4];  // 背景色（3bit）
    logic [ 3: 0]  fg_color = attr_reg[ 3: 0];  // 前景色（4bit）
    logic        pixel_on = font_data_reg[7 - char_pixel_x[ 2: 0]];  // 当前像素是否为字符前景

    // 计算字符位置

    // VRAM 地址计算：地址 = (char_row * 80 + char_col) * 2
    // 字符码地址（偶数）
    assign vram_rd_addr = {char_row, 7'h00} + {5'h00, char_col, 1'b0};

    // 属性解码

    // 字符生成器接口
    assign font_char_code = char_code_reg;
    assign font_row_index = char_pixel_y;

    // 像素判断：从字体数据中提取当前像素

    // 字符码和属性寄存器（需要流水线处理）
    logic [ 7: 0] char_code_next;
    logic [ 7: 0] attr_next;

    // 第一级：读取字符码和属性
    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
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

    // 第二级：读取字体数据
    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            font_data_reg <= '0;
        end else begin
            if (video_active) begin
                font_data_reg <= font_data;
            end
        end
    end

    // VGA 颜色输出（16 色 VGA 调色板）
    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            vga_r <= 4'h0;
            vga_g <= 4'h0;
            vga_b <= 4'h0;
        end else begin
            if (video_active) begin
                if (pixel_on) begin
                    // 前景色（16 色）
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
                    // 背景色（8 色，bit 3 控制亮度）
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
