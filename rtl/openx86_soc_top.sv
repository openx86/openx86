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
//  File        : openx86_soc_top.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : openx86_soc_top module
// ============================================================================

// ============================================================================
// 最小 SoC：i486_cpu 仅接 bus_controller；SDRAM/ROM/VGA/chipset 由总线控制器译码驱动
// ============================================================================

module openx86_soc_top #(
    parameter bit P_USE_SDIO_DISK = 1'b0
) (
    // =========================
    // VGA: RGB444 + sync
    // =========================
    output logic         o_vga_hsync,
    output logic         o_vga_vsync,
    output logic [ 3: 0] o_vga_r,
    output logic [ 3: 0] o_vga_g,
    output logic [ 3: 0] o_vga_b,

    // =========================
    // PS/2: open-drain; each line has (output data, output enable, bus readback)
    // =========================
    output logic         o_ps2_kbd_clk_out,
    output logic         o_ps2_kbd_clk_oe,
    input  logic          i_ps2_kbd_clk_in,
    output logic         o_ps2_kbd_dat_out,
    output logic         o_ps2_kbd_dat_oe,
    input  logic          i_ps2_kbd_dat_in,
    output logic         o_ps2_aux_clk_out,
    output logic         o_ps2_aux_clk_oe,
    input  logic          i_ps2_aux_clk_in,
    output logic         o_ps2_aux_dat_out,
    output logic         o_ps2_aux_dat_oe,
    input  logic          i_ps2_aux_dat_in,

    // =========================
    // SDIO / SD 4-bit (IDE channel; PHY on-chip)
    // =========================
    output logic         o_sdio_clk,
    inout  logic         io_sdio_cmd,
    inout  logic [ 3: 0] io_sdio_dat,

    // =========================
    // SDRAM physical interface (x16 device)
    // =========================
    output logic         o_sdram_clk,
    output logic         o_sdram_cke,
    output logic         o_sdram_cs_n,
    output logic         o_sdram_ras_n,
    output logic         o_sdram_cas_n,
    output logic         o_sdram_we_n,
    output logic [ 1: 0] o_sdram_ba,
    output logic [12: 0] o_sdram_a,
    output logic [ 1: 0] o_sdram_dqm,
    inout  logic [15: 0] io_sdram_dq,

    // =========================
    // board-level clock and reset
    // =========================
    input  logic          clk,
    input  logic          rst_n
);

    // ============================================================
    // CPU bus signals
    // ============================================================
    logic        bus_valid;
    logic        bus_ready;
    logic        bus_busy;
    logic        bus_we;
    logic        bus_io;
    logic [31: 0] bus_addr;
    logic [31: 0] bus_rdata;
    logic [31: 0] bus_wdata;

    // ============================================================
    // VGA memory interface
    // ============================================================
    logic        vga_mem_en_w;
    logic        vga_mem_en_r;
    logic [19: 0] vga_mem_addr;
    logic [ 7: 0]  vga_mem_data_w;
    logic [ 7: 0]  vga_mem_data_r;

    // ============================================================
    // VGA I/O interface
    // ============================================================
    logic        vga_io_en_w;
    logic        vga_io_en_r;
    logic [15: 0] vga_io_addr;
    logic [ 7: 0]  vga_io_data_w;
    logic [ 7: 0]  vga_io_data_r;

    logic [16: 0] bios_addr;     // E0000–FFFFF 内字节偏移
    logic [31: 0] bios_rdata;
    logic         bios_we;
    logic [31: 0] bios_wdata;
    logic [16: 0] ext_bios_addr; // 扩展 ROM 窗口地址
    logic [31: 0] ext_bios_rdata;

    logic        o_sdram_en;     // SDRAM 控制器访问请求
    logic        o_sdram_we;
    logic [23: 0] o_sdram_addr_off;
    logic [31: 0] o_sdram_wdata;
    logic [31: 0] i_sdram_rdata;
    logic        i_sdram_ready;
    logic        i_sdram_busy;

    logic        sdram_phy_cs_n, sdram_phy_ras_n, sdram_phy_cas_n, sdram_phy_we_n;
    logic [ 1: 0]  sdram_phy_ba;
    logic [12: 0] sdram_phy_a;
    logic [ 1: 0]  sdram_phy_dqm;
    logic [15: 0] sdram_phy_dq_out;  // DQ 输出数据
    logic        sdram_phy_dq_oe;    // DQ 输出使能
    logic        sdram_phy_clk, sdram_phy_cke;

    logic        pic_intr;       // 主 PIC INTR → CPU

    logic        cpu_ads_n;
    logic [31: 0] cpu_address;
    logic [31: 0] cpu_data_out;
    logic        cpu_data_oe;
    logic [31: 0] cpu_data_in;
    logic [ 3: 0] cpu_be_n;
    logic        cpu_wr_n;
    logic        cpu_dc_n;
    logic        cpu_mio_n;
    logic        cpu_blast_n;
    logic        cpu_bready_n;
    logic        cpu_hold;
    logic        cpu_hlda;
    logic        cpu_ferr_n;

    i486_cpu u_cpu (
        .o_ads_n    (cpu_ads_n),
        .o_address  (cpu_address),
        .o_data_out (cpu_data_out),
        .o_data_oe  (cpu_data_oe),
        .i_data_in  (cpu_data_in),
        .o_be_n     (cpu_be_n),
        .o_wr_n     (cpu_wr_n),
        .o_dc_n     (cpu_dc_n),
        .o_mio_n    (cpu_mio_n),
        .o_blast_n  (cpu_blast_n),
        .i_bready_n (cpu_bready_n),
        .i_hold     (cpu_hold),
        .o_hlda     (cpu_hlda),
        .i_intr     (pic_intr),
        .i_nmi      (1'b0),
        .o_ferr_n   (cpu_ferr_n),
        .clk        (clk),
        .rst_n      (rst_n)
    );

    assign cpu_hold = 1'b0;

    i486_soc_bus_bridge u_cpu_bridge (
        .i_ads_n            (cpu_ads_n),
        .i_address          (cpu_address),
        .i_data_out         (cpu_data_out),
        .i_data_oe          (cpu_data_oe),
        .o_data_in          (cpu_data_in),
        .i_wr_n             (cpu_wr_n),
        .i_mio_n            (cpu_mio_n),
        .i_blast_n          (cpu_blast_n),
        .o_bready_n         (cpu_bready_n),
        .o_bus_valid        (bus_valid),
        .i_bus_ready        (bus_ready),
        .i_bus_busy         (bus_busy),
        .o_bus_write_enable (bus_we),
        .o_bus_io_access    (bus_io),
        .o_bus_address      (bus_addr),
        .i_bus_read_data    (bus_rdata),
        .o_bus_write_data   (bus_wdata),
        .clk                (clk),
        .rst_n              (rst_n)
    );

    logic        b_sd_nat_clk;   // ide→native 主机时钟
    logic        b_sd_cmd_o;
    logic        b_sd_cmd_oe;
    logic        b_nat_cmd_i;
    logic [ 3: 0]  b_sd_dat_o;
    logic        b_sd_dat_oe;
    logic [ 3: 0]  b_nat_dat_i;
    logic        sdio_cmd_out;  // PHY 侧 CMD 驱动
    logic        sdio_cmd_oe;
    logic        sdio_cmd_in;
    logic [ 3: 0]  sdio_dat_out;
    logic        sdio_dat_oe;
    logic [ 3: 0]  sdio_dat_in;

    // SDRAM DQ：仅当控制器 OE 时驱动，否则高阻。
    assign io_sdram_dq = sdram_phy_dq_oe ? sdram_phy_dq_out : 16'hZZZZ;

    // SDRAM 命令/地址引脚直连板级封装
    assign o_sdram_clk   = sdram_phy_clk;
    assign o_sdram_cke   = sdram_phy_cke;
    assign o_sdram_cs_n  = sdram_phy_cs_n;
    assign o_sdram_ras_n = sdram_phy_ras_n;
    assign o_sdram_cas_n = sdram_phy_cas_n;
    assign o_sdram_we_n  = sdram_phy_we_n;
    assign o_sdram_ba    = sdram_phy_ba;
    assign o_sdram_a     = sdram_phy_a;
    assign o_sdram_dqm   = sdram_phy_dqm;

    // SDIO CMD/DAT：顶层三态以满足综合对 inout 的结构要求
    assign io_sdio_cmd = sdio_cmd_oe ? sdio_cmd_out : 1'bz;
    assign sdio_cmd_in = io_sdio_cmd;
    assign io_sdio_dat = sdio_dat_oe ? sdio_dat_out : 4'bzzzz;
    assign sdio_dat_in = io_sdio_dat;

    bus_controller #(
        .USE_SDIO_DISK (P_USE_SDIO_DISK)
    ) u_bus_controller (
        .i_bus_valid        (bus_valid),
        .o_bus_ready        (bus_ready),
        .o_bus_busy         (bus_busy),
        .i_bus_write_enable (bus_we),
        .i_bus_io_access    (bus_io),
        .i_bus_address      (bus_addr),
        .o_bus_data_read    (bus_rdata),
        .i_bus_data_write   (bus_wdata),
        .o_vga_mem_en_w     (vga_mem_en_w),
        .o_vga_mem_en_r     (vga_mem_en_r),
        .o_vga_mem_addr     (vga_mem_addr),
        .o_vga_mem_data_w   (vga_mem_data_w),
        .i_vga_mem_data_r   (vga_mem_data_r),
        .o_vga_io_en_w      (vga_io_en_w),
        .o_vga_io_en_r      (vga_io_en_r),
        .o_vga_io_addr      (vga_io_addr),
        .o_vga_io_data_w    (vga_io_data_w),
        .i_vga_io_data_r    (vga_io_data_r),
        .o_bios_addr        (bios_addr),
        .i_bios_rdata       (bios_rdata),
        .o_bios_we          (bios_we),
        .o_bios_wdata       (bios_wdata),
        .o_ext_bios_addr    (ext_bios_addr),
        .i_ext_bios_rdata   (ext_bios_rdata),
        .o_sdram_en         (o_sdram_en),
        .o_sdram_we         (o_sdram_we),
        .o_sdram_addr_off   (o_sdram_addr_off),
        .o_sdram_wdata      (o_sdram_wdata),
        .i_sdram_rdata      (i_sdram_rdata),
        .i_sdram_ready      (i_sdram_ready),
        .i_sdram_busy       (i_sdram_busy),
        .o_ps2_kbd_clk_out (o_ps2_kbd_clk_out),
        .o_ps2_kbd_clk_oe  (o_ps2_kbd_clk_oe),
        .i_ps2_kbd_clk_in  (i_ps2_kbd_clk_in),
        .o_ps2_kbd_dat_out (o_ps2_kbd_dat_out),
        .o_ps2_kbd_dat_oe  (o_ps2_kbd_dat_oe),
        .i_ps2_kbd_dat_in  (i_ps2_kbd_dat_in),
        .o_ps2_aux_clk_out (o_ps2_aux_clk_out),
        .o_ps2_aux_clk_oe  (o_ps2_aux_clk_oe),
        .i_ps2_aux_clk_in  (i_ps2_aux_clk_in),
        .o_ps2_aux_dat_out (o_ps2_aux_dat_out),
        .o_ps2_aux_dat_oe  (o_ps2_aux_dat_oe),
        .i_ps2_aux_dat_in  (i_ps2_aux_dat_in),
        .o_sdio_clk         (b_sd_nat_clk),
        .o_sdio_cmd_o      (b_sd_cmd_o),
        .o_sdio_cmd_oe     (b_sd_cmd_oe),
        .i_sdio_cmd_i      (b_nat_cmd_i),
        .o_sdio_dat_o      (b_sd_dat_o),
        .o_sdio_dat_oe     (b_sd_dat_oe),
        .i_sdio_dat_i      (b_nat_dat_i),
        .o_pic_intr         (pic_intr),
        .clk                (clk),
        .rst_n              (rst_n)
    );

    sdcard_4bit_phy u_sdio_phy (
        .i_sd_clk       (b_sd_nat_clk),
        .i_host_cmd_out (b_sd_cmd_o),
        .i_host_cmd_oe  (b_sd_cmd_oe),
        .o_host_cmd_in  (b_nat_cmd_i),
        .i_host_dat_out (b_sd_dat_o),
        .i_host_dat_oe  (b_sd_dat_oe),
        .o_host_dat_in  (b_nat_dat_i),
        .o_sd_clk_pin   (o_sdio_clk),
        .o_sd_cmd_out   (sdio_cmd_out),
        .o_sd_cmd_oe    (sdio_cmd_oe),
        .i_sd_cmd_in    (sdio_cmd_in),
        .o_sd_dat_out   (sdio_dat_out),
        .o_sd_dat_oe    (sdio_dat_oe),
        .i_sd_dat_in    (sdio_dat_in)
    );

    sdram_controller #(
        .CLK_HZ         (50_000_000),
        .T_RP           (2),
        .T_RCD          (2),
        .T_RFC          (7),
        .T_MRD          (2),
        .T_WR           (2),
        .CAS            (2),
        .REFRESH_CYCLES (390)
    ) u_sdram (
        .clk            (clk),
        .rst_n          (rst_n),
        .i_en           (o_sdram_en),
        .i_we           (o_sdram_we),
        .i_addr_off     (o_sdram_addr_off),
        .i_wdata        (o_sdram_wdata),
        .o_rdata        (i_sdram_rdata),
        .o_ready        (i_sdram_ready),
        .o_busy         (i_sdram_busy),
        .o_sdram_clk    (sdram_phy_clk),
        .o_sdram_cke    (sdram_phy_cke),
        .o_sdram_cs_n   (sdram_phy_cs_n),
        .o_sdram_ras_n  (sdram_phy_ras_n),
        .o_sdram_cas_n  (sdram_phy_cas_n),
        .o_sdram_we_n   (sdram_phy_we_n),
        .o_sdram_ba     (sdram_phy_ba),
        .o_sdram_a      (sdram_phy_a),
        .o_sdram_dqm    (sdram_phy_dqm),
        .o_sdram_dq_out (sdram_phy_dq_out),
        .o_sdram_dq_oe  (sdram_phy_dq_oe),
        .i_sdram_dq_in  (io_sdram_dq)
    );

    // VGA Graphics Adapter: bus VRAM writes + VGA I/O decode (see rtl/bus_controller.sv)
    vga_graphics_adapter u_vga (
        .io_en_w      (vga_io_en_w),
        .io_en_r      (vga_io_en_r),
        .io_addr      (vga_io_addr),
        .io_data_w    (vga_io_data_w),
        .io_data_r    (vga_io_data_r),
        .mem_en_w     (vga_mem_en_w),
        .mem_en_r     (vga_mem_en_r),
        .mem_addr     (vga_mem_addr),
        .mem_data_w   (vga_mem_data_w),
        .mem_data_r   (vga_mem_data_r),
        .vga_hsync    (o_vga_hsync),
        .vga_vsync    (o_vga_vsync),
        .vga_r        (o_vga_r),
        .vga_g        (o_vga_g),
        .vga_b        (o_vga_b),
        .clk          (clk),
        .rst_n        (rst_n)
    );

    // 系统 BIOS 0xE0000–0xFFFFF → 128KiB 线性 ROM（复位向量在偏移 0x1FFF0）
    chip_pc_bios_eeprom u_bios_24lc32 (
        .clk                 (clk),
        .rst_n               (rst_n),
        .i_sys_bios_byte_off (bios_addr),
        .i_ext_bios_byte_off (ext_bios_addr),
        .o_sys_bios_rdata    (bios_rdata),
        .o_ext_bios_rdata    (ext_bios_rdata),
        .i_sys_bios_we       (bios_we),
        .i_sys_bios_wdata    (bios_wdata)
    );

endmodule
