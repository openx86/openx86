module vga_port (
    // VRAM 读接口
    output logic [7:0]              vram_rd_addr,   // VRAM读地址（给双口RAM端口B）
    input  logic [7:0]              vram_rd_data,   // VRAM读数据（从双口RAM端口B）
    
    // VGA 物理信号输出
    output logic                    vga_hsync,
    output logic                    vga_vsync,
    output logic [3:0]              vga_r,
    output logic [3:0]              vga_g,
    output logic [3:0]              vga_b,
    
    // 时钟和复位（放在末尾）
    input  logic                    clock,
    input  logic                    reset
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

endmodule
