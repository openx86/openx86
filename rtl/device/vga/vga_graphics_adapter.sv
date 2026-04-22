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
//  File        : vga_graphics_adapter.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : vga_graphics_adapter module
// ============================================================================

// VGA Graphics Adapter — VRAM window 0xA0000–0xBFFFF + VGA I/O 0x03C0–0x03DF
module vga_graphics_adapter (
    // =========================
    // CPU I/O port access
    // =========================
    input  logic          io_en_w,
    input  logic          io_en_r,
    input  logic [15: 0] io_addr,
    input  logic [ 7: 0] io_data_w,
    output logic [ 7: 0] io_data_r,

    // =========================
    // CPU memory access (VRAM window)
    // =========================
    input  logic          mem_en_w,
    input  logic [19: 0]  mem_addr,
    input  logic [ 7: 0]  mem_data_w,

    // =========================
    // VGA physical signals
    // =========================
    output logic         vga_hsync,
    output logic         vga_vsync,
    output logic [ 3: 0] vga_r,
    output logic [ 3: 0] vga_g,
    output logic [ 3: 0] vga_b,

    // =========================
    // clock and reset
    // =========================
    input  logic          rst_n,
    input  logic          clk
);

    // ============================================================
    // VGA VRAM: one frame 640×480 byte linear buffer
    // ============================================================
    localparam int VRAM_SIZE_BYTES = 640 * 480;
    localparam int VRAM_ADDR_WIDTH = $clog2(VRAM_SIZE_BYTES);
    localparam int VRAM_DEPTH      = VRAM_SIZE_BYTES;

    // ============================================================
    // simplified I/O port definitions (referencing IBM VGA ports, subset implementation)
    // Implemented registers:
    //   - 0x03C2: MISC output register (lower 3 bits for display enable/disable)
    //   - 0x03DA: input status register 1 (VSYNC/HSYNC status bits)
    // Other ports reserved for future expansion.

    localparam logic [15: 0] PORT_MISC_OUT  = 16'h03C2;
    localparam logic [15: 0] PORT_STATUS1   = 16'h03DA;
    localparam logic [15: 0] PORT_MODE_REG  = 16'h03C0;  // 模式选择寄存器（简化）

    // 模式定义
    localparam logic [ 1: 0] MODE_GRAPHICS = 2'b00;  // 图形模式
    localparam logic [ 1: 0] MODE_TEXT_COLOR = 2'b01;  // 彩色文本模式
    localparam logic [ 1: 0] MODE_TEXT_INTENSE = 2'b10;  // 淡色文本模式

    // ============================================================
    // MISC output register (lower bits control display-related switches)
    // ============================================================
    logic [ 7: 0] misc_out_reg;

    // ============================================================
    // current display mode: graphics / color text / intense text
    // ============================================================
    logic [ 1: 0] vga_mode;

    // ============================================================
    // VRAM: using read/write separated RAM, CPU write + VGA read
    // ============================================================
    logic [VRAM_ADDR_WIDTH-1: 0] vram_rd_addr;
    logic [ 7: 0]                 vram_rd_data;

    // CPU write address truncated to VRAM depth (avoid out-of-bounds synthesis)
    logic [VRAM_ADDR_WIDTH-1: 0] vram_wr_addr;

    assign vram_wr_addr = mem_addr[VRAM_ADDR_WIDTH-1:0];

    // ============================================================
    // simple dual-port RAM instance: write port for CPU, read port for VGA
    // ============================================================
    simple_dual_port_ram #(
        .P_DATA_WIDTH ( 8                ),
        .P_ADDR_WIDTH ( VRAM_ADDR_WIDTH  ),
        .P_DEPTH      ( VRAM_DEPTH       )
    ) vram_inst (
        // 写端口（CPU）
        .i_we    ( mem_en_w        ),
        .i_waddr ( vram_wr_addr    ),
        .i_wdata ( mem_data_w      ),
        // 读端口（VGA）
        .i_re    ( 1'b1            ),  // VGA 持续读取
        .i_raddr ( vram_rd_addr    ),
        .o_rdata ( vram_rd_data    ),
        // 时钟与复位
        .clk     ( clk             ),
        .rst_n   ( rst_n           )
    );

    // ------------------------------------------------------------------------
    // VGA 时序生成（共享）
    // ------------------------------------------------------------------------
    
    // 时序计数与可视窗口标志（由 vga_port 驱动）
    logic [$clog2(800)-1: 0] h_count;
    logic [$clog2(525)-1: 0] v_count;
    logic video_active;
    
    // 图形模式 RGB（RRRGGGBB 展开）
    logic [ 3: 0] vga_r_graphics;
    logic [ 3: 0] vga_g_graphics;
    logic [ 3: 0] vga_b_graphics;
    
    // 文本 RGB 中间声明（当前未参与最终 mux，保留不删以免大范围改动）
    logic [ 3: 0] vga_r_text;
    logic [ 3: 0] vga_g_text;
    logic [ 3: 0] vga_b_text;
    
    // 文本子模块给出的 VRAM 字地址与回读数据（彩色/高亮两路分别计算，再按模式 mux，避免多驱动）
    logic [12: 0] text_vram_addr_color;
    logic [12: 0] text_vram_addr_intense;
    logic [12: 0] text_vram_addr;
    logic [ 7: 0] text_vram_char_data;
    logic [ 7: 0] text_vram_attr_data;
    logic [ 7: 0] text_vram_char_data_reg;
    logic [ 7: 0] text_vram_attr_data_reg;

    assign text_vram_char_data = text_vram_char_data_reg;
    assign text_vram_attr_data = text_vram_attr_data_reg;

    // 组合逻辑块
    always_comb begin
        unique case (vga_mode)
            MODE_TEXT_COLOR:   text_vram_addr = text_vram_addr_color;
            MODE_TEXT_INTENSE: text_vram_addr = text_vram_addr_intense;
            default:            text_vram_addr = '0;
        endcase
    end
    
    // 文本模式 VRAM 地址映射（文本模式使用 VRAM 的前 4000 字节）
    logic [VRAM_ADDR_WIDTH-1: 0] text_vram_rd_addr_char;  // 字符码字节在 VRAM 中的索引
    logic [VRAM_ADDR_WIDTH-1: 0] text_vram_rd_addr_attr;  // 属性字节索引（+1 相对字符）

    assign text_vram_rd_addr_char = VRAM_ADDR_WIDTH'(text_vram_addr[12:  1]);
    assign text_vram_rd_addr_attr = VRAM_ADDR_WIDTH'(text_vram_addr[12:  1]) + VRAM_ADDR_WIDTH'(1'b1);
    
    // 文本模式 VRAM 读取地址选择
    
    // 文本模式：将两次 VRAM 读流水对齐到字符/属性（与 vram_rd_data 对齐）
    always_ff @(posedge clk) begin
        if (vga_mode != MODE_GRAPHICS) begin
            // 第一级：读取字符码
            if (text_vram_rd_addr_char < 4000) begin
                text_vram_char_data_reg <= vram_rd_data;
            end
            // 第二级：读取属性（延迟一个时钟周期）
            if (text_vram_rd_addr_attr < 4000) begin
                text_vram_attr_data_reg <= vram_rd_data;
            end
        end
    end
    
    
    // 字符生成器接口（文本子模块分别驱动，再按模式 mux）
    logic [ 7: 0] font_char_code_color;
    logic [ 7: 0] font_char_code_intense;
    logic [ 7: 0] font_char_code;
    logic [ 3: 0] font_row_index_color;
    logic [ 3: 0] font_row_index_intense;
    logic [ 3: 0] font_row_index;
    logic [ 7: 0] font_data;

    // 组合逻辑块
    always_comb begin
        unique case (vga_mode)
            MODE_TEXT_COLOR: begin
                font_char_code   = font_char_code_color;
                font_row_index   = font_row_index_color;
            end
            MODE_TEXT_INTENSE: begin
                font_char_code   = font_char_code_intense;
                font_row_index   = font_row_index_intense;
            end
            default: begin
                font_char_code   = '0;
                font_row_index   = '0;
            end
        endcase
    end
    
    // VGA 端口（图形模式）
    vga_port #(
        .P_VRAM_ADDR_WIDTH ( VRAM_ADDR_WIDTH )
    ) vga_port_inst (
        .vram_rd_addr ( vram_rd_addr ),
        .vram_rd_data ( vram_rd_data ),
        .vga_hsync    ( vga_hsync    ),
        .vga_vsync    ( vga_vsync    ),
        .vga_r        ( vga_r_graphics ),
        .vga_g        ( vga_g_graphics ),
        .vga_b        ( vga_b_graphics ),
        .h_count      ( h_count       ),
        .v_count      ( v_count       ),
        .video_active ( video_active  ),
        .clk        ( clk         ),
        .rst_n        ( rst_n       )
    );
    
    // 字符生成器
    vga_font_rom font_rom_inst (
        .char_code  ( font_char_code ),
        .row_index  ( font_row_index ),
        .font_data  ( font_data       ),
        .clk      ( clk           ),
        .rst_n      ( rst_n         )
    );
    
    // 文本模式模块（根据模式选择）
    logic [ 3: 0] vga_r_text_color;
    logic [ 3: 0] vga_g_text_color;
    logic [ 3: 0] vga_b_text_color;
    logic [ 3: 0] vga_r_text_intense; // 高亮文本模式 RGB
    logic [ 3: 0] vga_g_text_intense;
    logic [ 3: 0] vga_b_text_intense;
    
    // 彩色文本模式
    vga_text_color text_color_inst (
        .vram_rd_addr  ( text_vram_addr_color ),
        .vram_char_data( text_vram_char_data ),
        .vram_attr_data( text_vram_attr_data ),
        .font_char_code( font_char_code_color ),
        .font_row_index( font_row_index_color ),
        .font_data    ( font_data            ),
        .vga_r        ( vga_r_text_color     ),
        .vga_g        ( vga_g_text_color     ),
        .vga_b        ( vga_b_text_color     ),
        .h_count      ( h_count              ),
        .v_count      ( v_count              ),
        .video_active ( video_active         ),
        .clk        ( clk                ),
        .rst_n        ( rst_n              )
    );
    
    // 淡色文本模式
    vga_text_intense text_intense_inst (
        .vram_rd_addr  ( text_vram_addr_intense ),
        .vram_char_data( text_vram_char_data ),
        .vram_attr_data( text_vram_attr_data ),
        .font_char_code( font_char_code_intense ),
        .font_row_index( font_row_index_intense ),
        .font_data    ( font_data            ),
        .vga_r        ( vga_r_text_intense   ),
        .vga_g        ( vga_g_text_intense   ),
        .vga_b        ( vga_b_text_intense   ),
        .h_count      ( h_count              ),
        .v_count      ( v_count              ),
        .video_active ( video_active         ),
        .clk        ( clk                ),
        .rst_n        ( rst_n              )
    );
    
    // 按 vga_mode 在图形与两种文本流水线输出间切换
    always_comb begin
        unique case (vga_mode)
            MODE_GRAPHICS: begin // 640x480 直接 VRAM 调色板展开
                vga_r = vga_r_graphics;
                vga_g = vga_g_graphics;
                vga_b = vga_b_graphics;
            end
            MODE_TEXT_COLOR: begin // 80x25 彩色文本
                vga_r = vga_r_text_color;
                vga_g = vga_g_text_color;
                vga_b = vga_b_text_color;
            end
            MODE_TEXT_INTENSE: begin // 80x25 高亮/淡色文本调色
                vga_r = vga_r_text_intense;
                vga_g = vga_g_text_intense;
                vga_b = vga_b_text_intense;
            end
            default: begin // 未定义模式回退图形
                vga_r = vga_r_graphics;
                vga_g = vga_g_graphics;
                vga_b = vga_b_graphics;
            end
        endcase
    end

    // ------------------------------------------------------------------------
    // CPU I/O 端口访问（简化版 VGA 寄存器）
    // ------------------------------------------------------------------------

    // 锁存 MISC/模式等可写寄存器
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            misc_out_reg <= 8'h01; // 默认启用显示、选择合适极性等（具体含义参考 VGA 标准）
            vga_mode <= MODE_GRAPHICS; // 默认图形模式
        end else begin
            if (io_en_w) begin
                unique case (io_addr)
                    PORT_MISC_OUT: begin // 杂项输出
                        misc_out_reg <= io_data_w;
                    end
                    PORT_MODE_REG: begin
                        // 模式选择寄存器：bit[ 1: 0] 选择模式
                        vga_mode <= io_data_w[ 1: 0];
                    end
                    default: begin
                        // 其他端口尚未实现
                    end
                endcase
            end
        end
    end

    // I/O 读：组合译码状态/MISC
    always_comb begin
        io_data_r = 8'hFF;

        if (io_en_r) begin
            unique case (io_addr)
                PORT_MISC_OUT: begin // 读回 MISC
                    io_data_r = misc_out_reg;
                end
                PORT_STATUS1: begin
                    // 状态寄存器 1（0x3DA）简化版本：
                    // bit 3: VSYNC 状态
                    // bit 4: HSYNC 状态
                    io_data_r = {
                        3'b000,
                        ~vga_hsync, // bit4: HSYNC 低有效 → 1 表示正在同步
                        ~vga_vsync, // bit3: VSYNC 低有效 → 1 表示正在同步
                        3'b000
                    };
                end
                default: begin
                    // 未实现端口返回 0xFF
                    io_data_r = 8'hFF;
                end
            endcase
        end
    end

endmodule

