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
//  File        : win95_boot_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Windows 95 boot regression stub (extends SeaBIOS SoC TB)
// ============================================================================

module win95_boot_tb;

    logic clk;
    logic rst_n;
    logic        o_vga_hsync;
    logic        o_vga_vsync;
    logic [ 3: 0] o_vga_r;
    logic [ 3: 0] o_vga_g;
    logic [ 3: 0] o_vga_b;
    logic  [15: 0] sdram_dq;
    logic         io_sdio_cmd;
    logic  [ 3: 0] io_sdio_dat;
    int          max_cycles;
    int          c;

    openx86_soc_top #(
        .P_USE_SDIO_DISK ( 1'b0 )
    ) dut (
        .clk   ( clk ),
        .rst_n   ( rst_n ),
        .o_vga_hsync ( o_vga_hsync ),
        .o_vga_vsync ( o_vga_vsync ),
        .o_vga_r     ( o_vga_r     ),
        .o_vga_g     ( o_vga_g     ),
        .o_vga_b     ( o_vga_b     ),
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
        .o_sdio_clk  ( ),
        .io_sdio_cmd ( io_sdio_cmd ),
        .io_sdio_dat ( io_sdio_dat ),
        .o_sdram_clk   ( ),
        .o_sdram_cke   ( ),
        .o_sdram_cs_n  ( ),
        .o_sdram_ras_n ( ),
        .o_sdram_cas_n ( ),
        .o_sdram_we_n  ( ),
        .o_sdram_ba    ( ),
        .o_sdram_a     ( ),
        .o_sdram_dqm   ( ),
        .io_sdram_dq   ( sdram_dq )
    );

    initial begin
        $readmemh("rtl/device/vga/vga_font_8x16.hex", dut.u_vga.font_rom_inst.font_rom_inst.rom);
        max_cycles = 500000;
        void'($value$plusargs("MAX_CYCLES=%0d", max_cycles));
    end

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("=== win95_boot_tb (stub) ===");
        rst_n = 1'b0;
        #25;
        rst_n = 1'b1;

        c = 0;
        while (c < max_cycles) begin
            @(posedge clk);
            c++;
        end

        $display("win95_boot_tb PASS stub (ran %0d cycles)", c);
        $finish;
    end

endmodule
