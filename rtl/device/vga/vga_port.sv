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
//  File        : vga_port.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : vga_port module
// ============================================================================

module vga_port #(
    parameter int P_VRAM_ADDR_WIDTH = 19
) (
    // =========================
    // VRAM read interface
    // =========================
    output logic [P_VRAM_ADDR_WIDTH-1: 0] vram_rd_addr,
    input  logic [ 7: 0]                   vram_rd_data,

    // =========================
    // VGA physical signal outputs
    // =========================
    output logic                   vga_hsync,
    output logic                   vga_vsync,
    output logic [ 3: 0]           vga_r,
    output logic [ 3: 0]           vga_g,
    output logic [ 3: 0]           vga_b,

    // =========================
    // timing outputs (for other modules)
    // =========================
    output logic [$clog2(800)-1: 0] h_count,
    output logic [$clog2(525)-1: 0] v_count,
    output logic                   video_active,

    // =========================
    // clock and reset
    // =========================
    input  logic                    rst_n,
    input  logic                    clk
);

    // ============================================================
    // constants and parameters (based on IBM VGA 640x480@60Hz standard timing)
    // ============================================================
    // 640x480 @ 60Hz, pixel clock 25.175MHz, typical timing parameters:
    // - horizontal: visible 640, front porch 16, sync 96, back porch 48 → total 800
    // - vertical: visible 480, front porch 10, sync 2, back porch 33 → total 525

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

    localparam int W_H_CNT     = $clog2(H_TOTAL);
    localparam int W_V_CNT     = $clog2(V_TOTAL);

    // ============================================================
    // VGA timing generator (640x480@60Hz)
    // ============================================================

    // ============================================================
    // row/column visible area flags (excluding blanking)
    // ============================================================
    logic h_visible;
    logic v_visible;

    assign h_visible = (h_count < W_H_CNT'(H_VISIBLE));
    assign v_visible = (v_count < W_V_CNT'(V_VISIBLE));

    // ============================================================
    // pixel/row/frame counter: 800x525 scan counter
    // ============================================================
    always_ff @(posedge clk or negedge rst_n) begin : ff_scan_counter
        if (~rst_n) begin
            h_count <= '0;
            v_count <= '0;
        end else begin
            if (h_count == W_H_CNT'(H_TOTAL - 1)) begin
                h_count <= '0;
                if (v_count == W_V_CNT'(V_TOTAL - 1)) begin
                    v_count <= '0;
                end else begin
                    v_count <= v_count + W_V_CNT'(1);
                end
            end else begin
                h_count <= h_count + W_H_CNT'(1);
            end
        end
    end

    // ============================================================
    // visible area
    // ============================================================
    assign video_active = (rst_n) && h_visible && v_visible;

    // 产生负极性 HSYNC/VSYNC 脉冲窗口
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            vga_hsync <= 1'b1;
            vga_vsync <= 1'b1;
        end else begin
            // HSYNC：在可见区之后，前沿 + 同步 + 后沿 中的同步区为 0
            if (h_count >= W_H_CNT'(H_VISIBLE + H_FRONT_POR) &&
                h_count <  W_H_CNT'(H_VISIBLE + H_FRONT_POR + H_SYNC)) begin
                vga_hsync <= 1'b0;
            end else begin
                vga_hsync <= 1'b1;
            end

            // VSYNC：在可见区之后，前沿 + 同步 + 后沿 中的同步区为 0
            if (v_count >= W_V_CNT'(V_VISIBLE + V_FRONT_POR) &&
                v_count <  W_V_CNT'(V_VISIBLE + V_FRONT_POR + V_SYNC)) begin
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
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
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
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
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
