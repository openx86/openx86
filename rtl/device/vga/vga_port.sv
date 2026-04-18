/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements vga_port.
*/
// ============================================================================
// vga_port
// ----------------------------------------------------------------------------
// VGA 时序/像素输出端口模块。
//
// 职责：
// - 产生 VGA HSYNC/VSYNC 与 RGB 信号（当前为 4:4:4 低位宽输出）
// - 根据当前扫描位置，从 VRAM/字符 ROM 等读取显示数据
//
// 接口说明（摘要）：
// - `vram_rd_addr/vram_rd_data`：VRAM 读取端口（通常接双口 RAM 的读口）
// - `vga_*`：物理输出信号
//
// 备注：
// - VGA 像素时钟、行场参数（可见区/前后沿/同步脉冲）由内部参数或常量定义；
//   上板时需要与目标显示模式匹配。
// ============================================================================

module vga_port (
    // VRAM 读接口
    output logic [ 7: 0]           vram_rd_addr, // 当前像素对应的 VRAM 字节地址（截断宽度）
    input  logic [ 7: 0]            vram_rd_data, // VRAM 同步读回数据

    
    // VGA 物理信号输出
    output logic                   vga_hsync,   // 行同步（低有效区间见时序块）
    output logic                   vga_vsync,   // 场同步
    output logic [ 3: 0]           vga_r,       // RGB 各 4 位（图形调色展开）
    output logic [ 3: 0]           vga_g,
    output logic [ 3: 0]           vga_b,
    
    // 时序输出（供其他模块使用）
    output logic [$clog2(800)-1: 0] h_count,     // 行内像素计数 0..799
    output logic [$clog2(525)-1: 0] v_count,     // 行计数 0..524
    output logic                   video_active, // 可见像素窗口内为 1
    
    // 时钟和复位（放在末尾）
    input  logic                    reset_n,     // 异步低有效复位
    input  logic                    clock        // 像素时钟
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

    // h_count 和 v_count 现在是输出端口

    // 行列可见区标志（不含消隐）
    logic h_visible;
    logic v_visible;

    assign h_visible = (h_count < H_VISIBLE);
    assign v_visible = (v_count < V_VISIBLE);

    // 像素/行/帧计数：800x525 扫描计数器
    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
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
    assign video_active = (reset_n) && h_visible && v_visible;

    // 产生负极性 HSYNC/VSYNC 脉冲窗口
    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
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

    // 可见区内线性递增 vram_rd_addr；帧起点复位
    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
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
    //   - R: [ 7:  5]
    //   - G: [ 4:  2]
    //   - B: [ 1: 0]
    // 对应扩展到 4bit VGA R/G/B 输出。

    // 将 RRRGGGBB 展开为 4:4:4 RGB；消隐区输出黑
    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            vga_r <= 4'h0;
            vga_g <= 4'h0;
            vga_b <= 4'h0;
        end else begin
            if (video_active) begin
                vga_r <= {vram_rd_data[ 7:  5], 1'b0};
                vga_g <= {vram_rd_data[ 4:  2], 1'b0};
                vga_b <= {vram_rd_data[ 1: 0], vram_rd_data[ 1: 0]};
            end else begin
                vga_r <= 4'h0;
                vga_g <= 4'h0;
                vga_b <= 4'h0;
            end
        end
    end

endmodule
