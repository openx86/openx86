/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements bus_chipset_integration_tb.
*/
// ============================================================================
// bus + chipset 集成读冒烟（I/O 0x0080 DMA 页寄存器）
// ============================================================================
`timescale 1ns/1ps
module bus_chipset_integration_tb;

    logic        clock = 0;
    logic        reset;
    logic        bus_valid;
    logic        bus_ready;
    logic        bus_busy;
    logic        bus_we;
    logic        bus_io;
    logic [31:0] bus_addr;
    logic [31:0] bus_rdata;
    logic [31:0] bus_wdata;

    logic        vga_mem_en_w;
    logic [19:0] vga_mem_addr;
    logic [7:0]  vga_mem_data_w;
    logic        vga_io_en_w;
    logic        vga_io_en_r;
    logic [15:0] vga_io_addr;
    logic [7:0]  vga_io_data_w;
    logic [7:0]  vga_io_data_r;

    logic        o_sdram_en;
    logic        o_sdram_we;
    logic [23:0] o_sdram_addr_off;
    logic [31:0] o_sdram_wdata;
    logic [31:0] i_sdram_rdata;
    logic        i_sdram_ready;
    logic        i_sdram_busy;

    logic [15:0] bios_addr;
    logic [31:0] bios_rdata;
    logic [16:0] ext_bios_addr;
    logic [31:0] ext_bios_rdata;

    bus_controller u_bus_controller (
        .i_bus_valid        ( bus_valid ),
        .o_bus_ready        ( bus_ready ),
        .o_bus_busy         ( bus_busy ),
        .i_bus_write_enable ( bus_we ),
        .i_bus_io_access    ( bus_io ),
        .i_bus_address      ( bus_addr ),
        .o_bus_data_read    ( bus_rdata ),
        .i_bus_data_write   ( bus_wdata ),
        .o_vga_mem_en_w     ( vga_mem_en_w ),
        .o_vga_mem_addr     ( vga_mem_addr ),
        .o_vga_mem_data_w   ( vga_mem_data_w ),
        .o_vga_io_en_w      ( vga_io_en_w ),
        .o_vga_io_en_r      ( vga_io_en_r ),
        .o_vga_io_addr      ( vga_io_addr ),
        .o_vga_io_data_w    ( vga_io_data_w ),
        .i_vga_io_data_r    ( vga_io_data_r ),
        .o_bios_addr        ( bios_addr ),
        .i_bios_rdata       ( bios_rdata ),
        .o_ext_bios_addr    ( ext_bios_addr ),
        .i_ext_bios_rdata   ( ext_bios_rdata ),
        .o_sdram_en         ( o_sdram_en ),
        .o_sdram_we         ( o_sdram_we ),
        .o_sdram_addr_off   ( o_sdram_addr_off ),
        .o_sdram_wdata      ( o_sdram_wdata ),
        .i_sdram_rdata      ( i_sdram_rdata ),
        .i_sdram_ready      ( i_sdram_ready ),
        .i_sdram_busy       ( i_sdram_busy ),
        .o_ps2_kbd_clk_out ( ),
        .o_ps2_kbd_clk_oe  ( ),
        .i_ps2_kbd_clk_in  ( 1'b1 ),
        .o_ps2_kbd_dat_out ( ),
        .o_ps2_kbd_dat_oe  ( ),
        .i_ps2_kbd_dat_in  ( 1'b1 ),
        .o_ps2_aux_clk_out ( ),
        .o_ps2_aux_clk_oe  ( ),
        .i_ps2_aux_clk_in  ( 1'b1 ),
        .o_ps2_aux_dat_out ( ),
        .o_ps2_aux_dat_oe  ( ),
        .i_ps2_aux_dat_in  ( 1'b1 ),
        .o_sdio_clk    ( ),
        .o_sdio_cmd_o  ( ),
        .o_sdio_cmd_oe ( ),
        .i_sdio_cmd_i  ( 1'b1 ),
        .o_sdio_dat_o  ( ),
        .o_sdio_dat_oe ( ),
        .i_sdio_dat_i  ( 4'hF ),
        .o_pic_intr ( ),
        .i_clock            ( clock ),
        .i_reset            ( reset )
    );

    assign i_sdram_rdata = 32'h0;
    assign i_sdram_ready = 1'b0;
    assign i_sdram_busy  = 1'b0;
    assign bios_rdata = 32'h0;
    assign ext_bios_rdata = 32'h0;
    assign vga_io_data_r = 8'hFF;

    always #5 clock = ~clock;

    initial begin
        reset     = 1;
        bus_valid = 0;
        bus_we    = 0;
        bus_io    = 0;
        bus_addr  = 0;
        bus_wdata = 0;
        repeat (4) @(posedge clock);
        reset = 0;
        @(posedge clock);

        bus_valid = 1;
        bus_we    = 0;
        bus_io    = 1;
        bus_addr  = 32'h0000_0080;
        @(posedge clock);
        wait (bus_ready);
        if (bus_rdata[7:0] !== 8'h00)
            $display("FAIL bus chipset read %h", bus_rdata);
        else
            $display("PASS bus_chipset_integration");

        bus_valid = 0;
        $finish;
    end

endmodule
