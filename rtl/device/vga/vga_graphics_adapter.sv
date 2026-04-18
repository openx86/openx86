/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements vga_graphics_adapter.
*/
// VGA Graphics Adapter — VRAM window 0xA0000–0xBFFFF + VGA I/O 0x03C0–0x03DF
module vga_graphics_adapter (
    // bus

    // CPU I/O port access
    input  logic          io_en_w,    // I/O 写选通（已译码到 VGA 窗口）
    input  logic          io_en_r,    // I/O 读选通
    input  logic [15: 0] io_addr,     // I/O 地址（如 03C0/03C2/03DA）
    input  logic [ 7: 0] io_data_w,   // I/O 写数据
    output logic [ 7: 0] io_data_r,   // I/O 读数据

    // CPU memory access (VRAM window)
    input  logic          mem_en_w,   // VRAM 窗口写使能
    input  logic [19: 0]  mem_addr,   // VRAM 字节地址（高位由映射决定）
    input  logic [ 7: 0]  mem_data_w, // VRAM 写数据

    // VGA physical signals
    output logic         vga_hsync,   // 行同步（负极性约定由 vga_port 产生）
    output logic         vga_vsync,   // 场同步
    output logic [ 3: 0] vga_r,       // 像素红分量
    output logic [ 3: 0] vga_g,
    output logic [ 3: 0] vga_b,

    // common
    input  logic          reset_n,    // 异步低有效复位
    input  logic          clock       // 像素域主时钟
);

    // VGA VRAM 容量：307 KB = 314,368 字节
    localparam int VRAM_SIZE_BYTES = 640 * 480;  // 307,200 字节
    localparam int VRAM_ADDR_WIDTH = 8;          // 地址宽度
    localparam int VRAM_DEPTH      = VRAM_SIZE_BYTES;  // 实际深度：307,200

    // 简化的 I/O 端口定义（参考 IBM VGA 端口，但只实现子集）
    // 我们实现几个常用寄存器示意：
    //   - 0x03C2: MISC 输出寄存器（只实现最低 3bit，用于启用/关闭显示等）
    //   - 0x03DA: 输入状态寄存器 1（只实现 VSYNC/HSYNC 状态位）
    // 其他端口留待将来扩展。

    localparam logic [15: 0] PORT_MISC_OUT  = 16'h03C2;
    localparam logic [15: 0] PORT_STATUS1   = 16'h03DA;
    localparam logic [15: 0] PORT_MODE_REG  = 16'h03C0;  // 模式选择寄存器（简化）

    // 模式定义
    localparam logic [ 1: 0] MODE_GRAPHICS = 2'b00;  // 图形模式
    localparam logic [ 1: 0] MODE_TEXT_COLOR = 2'b01;  // 彩色文本模式
    localparam logic [ 1: 0] MODE_TEXT_INTENSE = 2'b10;  // 淡色文本模式

    // MISC 输出寄存器（简化：低几位控制显示相关开关）
    logic [ 7: 0] misc_out_reg;
    
    // 当前显示模式：图形 / 彩色文本 / 高亮文本
    logic [ 1: 0] vga_mode;

    // ------------------------------------------------------------------------
    // VRAM：使用读写信号分离的RAM，CPU 写入 + VGA 读取
    // ------------------------------------------------------------------------

    // VGA 读 VRAM 接口（连接到 vga_port 读口）
    logic [VRAM_ADDR_WIDTH-1: 0] vram_rd_addr;
    logic [ 7: 0]                 vram_rd_data;

    // CPU 写地址截断到 VRAM 深度（避免越界综合）
    logic [VRAM_ADDR_WIDTH-1: 0] vram_wr_addr;

    assign vram_wr_addr = mem_addr[VRAM_ADDR_WIDTH-1:0];

    // 地址截断逻辑

    // 简单双口RAM实例：写端口给CPU，读端口给VGA
    simple_dual_port_ram #(
        .DATA_WIDTH ( 8                ),
        .ADDR_WIDTH ( VRAM_ADDR_WIDTH  ),
        .DEPTH      ( VRAM_DEPTH       )
    ) vram_inst (
        // 写端口（CPU）
        .we    ( mem_en_w        ),
        .waddr ( vram_wr_addr    ),
        .wdata ( mem_data_w      ),
        // 读端口（VGA）
        .re    ( 1'b1            ),  // VGA 持续读取
        .raddr ( vram_rd_addr    ),
        .rdata ( vram_rd_data    ),
        // 时钟与复位
        .clock ( clock           ),
        .reset_n ( reset_n         )
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
    
    // 文本子模块给出的 VRAM 字地址与回读数据
    logic [12: 0] text_vram_addr;
    logic [ 7: 0] text_vram_char_data;
    logic [ 7: 0] text_vram_attr_data;

    assign text_vram_char_data = text_vram_char_data_reg;
    assign text_vram_attr_data = text_vram_attr_data_reg;
    
    // 文本模式 VRAM 地址映射（文本模式使用 VRAM 的前 4000 字节）
    logic [VRAM_ADDR_WIDTH-1: 0] text_vram_rd_addr_char;  // 字符码字节在 VRAM 中的索引
    logic [VRAM_ADDR_WIDTH-1: 0] text_vram_rd_addr_attr;  // 属性字节索引（+1 相对字符）

    assign text_vram_rd_addr_char = text_vram_addr[12:  1];
    assign text_vram_rd_addr_attr = text_vram_addr[12:  1] + 1;
    
    // 文本模式 VRAM 读取地址选择
    
    // 文本模式 VRAM 数据（需要两次读取，使用流水线）
    logic [ 7: 0] text_vram_char_data_reg;
    logic [ 7: 0] text_vram_attr_data_reg;
    
    // 文本模式：将两次 VRAM 读流水对齐到字符/属性（与 vram_rd_data 对齐）
    always_ff @(posedge clock) begin
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
    
    
    // 字符生成器接口（文本子模块驱动 char/row，font_rom 输出点阵）
    logic [ 7: 0] font_char_code;
    logic [ 3: 0] font_row_index;
    logic [ 7: 0] font_data;
    
    // VGA 端口（图形模式）
    vga_port vga_port_inst (
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
        .clock        ( clock         ),
        .reset_n        ( reset_n       )
    );
    
    // 字符生成器
    vga_font_rom font_rom_inst (
        .char_code  ( font_char_code ),
        .row_index  ( font_row_index ),
        .font_data  ( font_data       ),
        .clock      ( clock           ),
        .reset_n      ( reset_n         )
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
        .vram_rd_addr  ( text_vram_addr      ),
        .vram_char_data( text_vram_char_data ),
        .vram_attr_data( text_vram_attr_data ),
        .font_char_code( font_char_code      ),
        .font_row_index( font_row_index      ),
        .font_data    ( font_data            ),
        .vga_r        ( vga_r_text_color     ),
        .vga_g        ( vga_g_text_color     ),
        .vga_b        ( vga_b_text_color     ),
        .h_count      ( h_count              ),
        .v_count      ( v_count              ),
        .video_active ( video_active         ),
        .clock        ( clock                ),
        .reset_n        ( reset_n              )
    );
    
    // 淡色文本模式
    vga_text_intense text_intense_inst (
        .vram_rd_addr  ( text_vram_addr      ),
        .vram_char_data( text_vram_char_data ),
        .vram_attr_data( text_vram_attr_data ),
        .font_char_code( font_char_code      ),
        .font_row_index( font_row_index      ),
        .font_data    ( font_data            ),
        .vga_r        ( vga_r_text_intense   ),
        .vga_g        ( vga_g_text_intense   ),
        .vga_b        ( vga_b_text_intense   ),
        .h_count      ( h_count              ),
        .v_count      ( v_count              ),
        .video_active ( video_active         ),
        .clock        ( clock                ),
        .reset_n        ( reset_n              )
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
    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
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

