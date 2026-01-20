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

    // ------------------------------------------------------------------------
    // 常量与参数（基于 IBM VGA 640x480@60Hz 标准时序）
    // ------------------------------------------------------------------------
    // 640x480 @ 60Hz, 像素时钟 25.175MHz，对应的典型时序参数如下：
    //  - 水平：可见 640, 前沿 16, 同步 96, 后沿 48 → 总计 800
    //  - 垂直：可见 480, 前沿 10, 同步 2,  后沿 33 → 总计 525

    localparam int H_VISIBLE   = 640;
    localparam int H_FRONT_POR = 16;
    localparam int H_SYNC      = 96;
    localparam int H_BACK_POR  = 48;
    localparam int H_TOTAL     = H_VISIBLE + H_FRONT_POR + H_SYNC + H_BACK_POR; // 800

    localparam int V_VISIBLE   = 480;
    localparam int V_FRONT_POR = 10;
    localparam int V_SYNC      = 2;
    localparam int V_BACK_POR  = 33;
    localparam int V_TOTAL     = V_VISIBLE + V_FRONT_POR + V_SYNC + V_BACK_POR; // 525

    // VGA VRAM 容量：307 KB = 314,368 字节
    localparam int VRAM_SIZE_BYTES = 640 * 480;  // 307,200 字节
    localparam int VRAM_ADDR_WIDTH = 8;          // 地址宽度
    localparam int VRAM_DEPTH      = VRAM_SIZE_BYTES;  // 实际深度：314,368

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
    // VRAM：使用双口RAM，CPU 写入（端口A）+ VGA 读出（端口B）
    // ------------------------------------------------------------------------

    // VGA 读 VRAM 使用的线性帧地址
    logic [VRAM_ADDR_WIDTH-1:0] vram_rd_addr;
    logic [7:0]                 vram_rd_data;

    // CPU 写地址（截断到VRAM地址宽度内）
    logic [VRAM_ADDR_WIDTH-1:0] vram_wr_addr;

    // 地址截断逻辑
    assign vram_wr_addr = mem_addr[VRAM_ADDR_WIDTH-1:0];

    // 双口RAM实例：端口A用于CPU写，端口B用于VGA读
    dual_port_ram #(
        .DATA_WIDTH ( 8                ),
        .ADDR_WIDTH ( VRAM_ADDR_WIDTH  ),
        .DEPTH      ( VRAM_DEPTH       )
    ) vram_inst (
        .clock  ( clock           ),
        .reset  ( reset           ),
        // 端口A：CPU写
        .wea    ( mem_en_w        ),
        .addra  ( vram_wr_addr    ),
        .wdataa ( mem_data_w      ),
        .rdataa (                 ),  // CPU暂不读VRAM
        // 端口B：VGA读
        .web    ( 1'b0            ),  // VGA只读不写
        .addrb  ( vram_rd_addr   ),
        .wdatab ( 8'h0           ),  // 不使用
        .rdatab ( vram_rd_data   )
    );

    // ------------------------------------------------------------------------
    // VGA 时序发生器（640x480@60Hz）
    // ------------------------------------------------------------------------

    logic [$clog2(H_TOTAL)-1:0] h_count;
    logic [$clog2(V_TOTAL)-1:0] v_count;

    logic h_visible;
    logic v_visible;
    logic video_active;

    // 像素/行/帧计数
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            h_count <= '0;
            v_count <= '0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= '0;
                if (v_count == V_TOTAL - 1) begin
                    v_count <= '0;
                end else begin
                    v_count <= v_count + 1;
                end
            end else begin
                h_count <= h_count + 1;
            end
        end
    end

    // 可见区域
    assign h_visible    = (h_count < H_VISIBLE);
    assign v_visible    = (v_count < V_VISIBLE);
    assign video_active = h_visible && v_visible;

    // 同步信号（VGA 标准为负极性）
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            vga_hsync <= 1'b1;
            vga_vsync <= 1'b1;
        end else begin
            // HSYNC：在可见区之后，前沿 + 同步 + 后沿 中的同步区为 0
            if (h_count >= (H_VISIBLE + H_FRONT_POR) &&
                h_count <  (H_VISIBLE + H_FRONT_POR + H_SYNC)) begin
                vga_hsync <= 1'b0;
            end else begin
                vga_hsync <= 1'b1;
            end

            // VSYNC：在可见区之后，前沿 + 同步 + 后沿 中的同步区为 0
            if (v_count >= (V_VISIBLE + V_FRONT_POR) &&
                v_count <  (V_VISIBLE + V_FRONT_POR + V_SYNC)) begin
                vga_vsync <= 1'b0;
            end else begin
                vga_vsync <= 1'b1;
            end
        end
    end

    // ------------------------------------------------------------------------
    // 帧缓冲读地址生成（线性、逐像素递增）
    // ------------------------------------------------------------------------

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            vram_rd_addr <= '0;
        end else begin
            if (video_active) begin
                // 在整个可见区域内，线性递增地址
                if (h_count == 0 && v_count == 0) begin
                    vram_rd_addr <= '0;
                end else begin
                    vram_rd_addr <= vram_rd_addr + 1'b1;
                end
            end else if (h_count == 0 && v_count == 0) begin
                // 每帧开始时重置
                vram_rd_addr <= '0;
            end
        end
    end

    // VRAM 读：由双口RAM模块在时钟上升沿后输出，这里不需要额外逻辑
    // vram_rd_data 直接从 dual_port_ram 的 rdatab 端口输出

    // ------------------------------------------------------------------------
    // 简化的调色板 / 像素格式
    // ------------------------------------------------------------------------
    // 这里假设 VRAM 中每个字节为 8bit 直接颜色：RRRGGGBB
    //   - R: [7:5]
    //   - G: [4:2]
    //   - B: [1:0]
    // 对应扩展到 4bit VGA R/G/B 输出。

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            vga_r <= 4'h0;
            vga_g <= 4'h0;
            vga_b <= 4'h0;
        end else begin
            if (video_active) begin
                vga_r <= {vram_rd_data[7:5], 1'b0};
                vga_g <= {vram_rd_data[4:2], 1'b0};
                vga_b <= {vram_rd_data[1:0], vram_rd_data[1:0]};
            end else begin
                vga_r <= 4'h0;
                vga_g <= 4'h0;
                vga_b <= 4'h0;
            end
        end
    end

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

