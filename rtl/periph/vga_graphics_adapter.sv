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
    input  logic        io_en_w,
    input  logic        io_en_r,
    input  logic [15:0] io_addr,
    input  logic [7:0]  io_data_w,
    output logic [7:0]  io_data_r,

    // CPU memory access (VRAM window)
    input  logic        mem_en_w,
    input  logic [19:0] mem_addr,
    input  logic [7:0]  mem_data_w,

    // VGA physical signals
    output logic        vga_hsync,
    output logic        vga_vsync,
    output logic [3:0]  vga_r,
    output logic [3:0]  vga_g,
    output logic [3:0]  vga_b,

    // common
    input  logic        clock,
    input  logic        reset
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

    localparam logic [15:0] PORT_MISC_OUT  = 16'h03C2;
    localparam logic [15:0] PORT_STATUS1   = 16'h03DA;
    localparam logic [15:0] PORT_MODE_REG  = 16'h03C0;  // 模式选择寄存器（简化）

    // 模式定义
    localparam logic [1:0] MODE_GRAPHICS = 2'b00;  // 图形模式
    localparam logic [1:0] MODE_TEXT_COLOR = 2'b01;  // 彩色文本模式
    localparam logic [1:0] MODE_TEXT_INTENSE = 2'b10;  // 淡色文本模式

    // MISC 输出寄存器
    logic [7:0] misc_out_reg;
    
    // 模式选择寄存器
    logic [1:0] vga_mode;

    // ------------------------------------------------------------------------
    // VRAM：使用读写信号分离的RAM，CPU 写入 + VGA 读取
    // ------------------------------------------------------------------------

    // VGA 读 VRAM 接口（连接到 vga_port）
    logic [VRAM_ADDR_WIDTH-1:0] vram_rd_addr;
    logic [7:0]                 vram_rd_data;

    // CPU 写地址（截断到VRAM地址宽度内）
    logic [VRAM_ADDR_WIDTH-1:0] vram_wr_addr;

    // 地址截断逻辑
    assign vram_wr_addr = mem_addr[VRAM_ADDR_WIDTH-1:0];

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
        .reset ( reset           )
    );

    // ------------------------------------------------------------------------
    // VGA 时序生成（共享）
    // ------------------------------------------------------------------------
    
    // 时序信号（从 vga_port 或文本模式模块获取）
    logic [$clog2(800)-1:0] h_count;
    logic [$clog2(525)-1:0] v_count;
    logic video_active;
    
    // 图形模式输出
    logic [3:0] vga_r_graphics;
    logic [3:0] vga_g_graphics;
    logic [3:0] vga_b_graphics;
    
    // 文本模式输出
    logic [3:0] vga_r_text;
    logic [3:0] vga_g_text;
    logic [3:0] vga_b_text;
    
    // 文本模式 VRAM 接口
    logic [12:0] text_vram_addr;
    logic [7:0]  text_vram_char_data;
    logic [7:0]  text_vram_attr_data;
    
    // 文本模式 VRAM 地址映射（文本模式使用 VRAM 的前 4000 字节）
    logic [VRAM_ADDR_WIDTH-1:0] text_vram_rd_addr_char;
    logic [VRAM_ADDR_WIDTH-1:0] text_vram_rd_addr_attr;
    
    // 文本模式 VRAM 读取地址选择
    assign text_vram_rd_addr_char = text_vram_addr[12:1];  // 字符码地址（偶数地址）
    assign text_vram_rd_addr_attr = text_vram_addr[12:1] + 1;  // 属性地址（奇数地址）
    
    // 文本模式 VRAM 数据（需要两次读取，使用流水线）
    logic [7:0] text_vram_char_data_reg;
    logic [7:0] text_vram_attr_data_reg;
    
    // 文本模式 VRAM 读取流水线
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
    
    assign text_vram_char_data = text_vram_char_data_reg;
    assign text_vram_attr_data = text_vram_attr_data_reg;
    
    // 字符生成器接口
    logic [7:0] font_char_code;
    logic [3:0] font_row_index;
    logic [7:0] font_data;
    
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
        .reset        ( reset         )
    );
    
    // 字符生成器
    vga_font_rom font_rom_inst (
        .char_code  ( font_char_code ),
        .row_index  ( font_row_index ),
        .font_data  ( font_data       ),
        .clock      ( clock           ),
        .reset      ( reset           )
    );
    
    // 文本模式模块（根据模式选择）
    logic [3:0] vga_r_text_color;
    logic [3:0] vga_g_text_color;
    logic [3:0] vga_b_text_color;
    logic [3:0] vga_r_text_intense;
    logic [3:0] vga_g_text_intense;
    logic [3:0] vga_b_text_intense;
    
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
        .reset        ( reset                )
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
        .reset        ( reset                )
    );
    
    // 模式选择输出
    always_comb begin
        unique case (vga_mode)
            MODE_GRAPHICS: begin
                vga_r = vga_r_graphics;
                vga_g = vga_g_graphics;
                vga_b = vga_b_graphics;
            end
            MODE_TEXT_COLOR: begin
                vga_r = vga_r_text_color;
                vga_g = vga_g_text_color;
                vga_b = vga_b_text_color;
            end
            MODE_TEXT_INTENSE: begin
                vga_r = vga_r_text_intense;
                vga_g = vga_g_text_intense;
                vga_b = vga_b_text_intense;
            end
            default: begin
                vga_r = vga_r_graphics;
                vga_g = vga_g_graphics;
                vga_b = vga_b_graphics;
            end
        endcase
    end

    // ------------------------------------------------------------------------
    // CPU I/O 端口访问（简化版 VGA 寄存器）
    // ------------------------------------------------------------------------

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            misc_out_reg <= 8'h01; // 默认启用显示、选择合适极性等（具体含义参考 VGA 标准）
            vga_mode <= MODE_GRAPHICS; // 默认图形模式
        end else begin
            if (io_en_w) begin
                unique case (io_addr)
                    PORT_MISC_OUT: begin
                        misc_out_reg <= io_data_w;
                    end
                    PORT_MODE_REG: begin
                        // 模式选择寄存器：bit[1:0] 选择模式
                        vga_mode <= io_data_w[1:0];
                    end
                    default: begin
                        // 其他端口尚未实现
                    end
                endcase
            end
        end
    end

    // I/O 读：组合逻辑
    always_comb begin
        io_data_r = 8'hFF;

        if (io_en_r) begin
            unique case (io_addr)
                PORT_MISC_OUT: begin
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

