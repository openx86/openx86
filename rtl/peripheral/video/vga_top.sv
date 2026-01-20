module vga_top (
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

    // MISC 输出寄存器
    logic [7:0] misc_out_reg;

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
    // VGA 端口：读取VRAM并输出VGA信号
    // ------------------------------------------------------------------------

    vga_port vga_port_inst (
        .vram_rd_addr ( vram_rd_addr ),
        .vram_rd_data ( vram_rd_data ),
        .vga_hsync    ( vga_hsync    ),
        .vga_vsync    ( vga_vsync    ),
        .vga_r        ( vga_r        ),
        .vga_g        ( vga_g        ),
        .vga_b        ( vga_b        ),
        .clock        ( clock        ),
        .reset        ( reset        )
    );

    // ------------------------------------------------------------------------
    // CPU I/O 端口访问（简化版 VGA 寄存器）
    // ------------------------------------------------------------------------

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            misc_out_reg <= 8'h01; // 默认启用显示、选择合适极性等（具体含义参考 VGA 标准）
        end else begin
            if (io_en_w) begin
                unique case (io_addr)
                    PORT_MISC_OUT: begin
                        misc_out_reg <= io_data_w;
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

