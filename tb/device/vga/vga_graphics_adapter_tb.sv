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
//  File        : vga_graphics_adapter_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : vga_graphics_adapter_tb module
// ============================================================================

`timescale 1ns/1ns

module vga_graphics_adapter_tb;

    logic         clk;
    logic         rst_n;
    logic         io_en_w;
    logic         io_en_r;
    logic [15: 0] io_addr;
    logic [ 7: 0] io_data_w;
    logic [ 7: 0] io_data_r;
    logic         mem_en_w;
    logic         mem_en_r;
    logic [19: 0] mem_addr;
    logic [ 7: 0] mem_data_w;
    logic [ 7: 0] mem_data_r;
    logic         vga_hsync;
    logic         vga_vsync;
    logic [ 3: 0] vga_r;
    logic [ 3: 0] vga_g;
    logic [ 3: 0] vga_b;
    int           fail_count;
    bit           saw_vsync_fall;
    bit           saw_hsync_fall;

    vga_graphics_adapter dut (
        .io_en_w    ( io_en_w ),
        .io_en_r    ( io_en_r ),
        .io_addr    ( io_addr ),
        .io_data_w  ( io_data_w ),
        .io_data_r  ( io_data_r ),
        .mem_en_w   ( mem_en_w ),
        .mem_en_r   ( mem_en_r ),
        .mem_addr   ( mem_addr ),
        .mem_data_w ( mem_data_w ),
        .mem_data_r ( mem_data_r ),
        .vga_hsync  ( vga_hsync ),
        .vga_vsync  ( vga_vsync ),
        .vga_r      ( vga_r ),
        .vga_g      ( vga_g ),
        .vga_b      ( vga_b ),
        .clk        ( clk ),
        .rst_n      ( rst_n )
    );

    always #20 clk = ~clk;

    initial begin
        $readmemh("rtl/device/vga/vga_font_8x16.hex", dut.font_rom_inst.font_rom_inst.rom);
        clk            = 1'b0;
        rst_n          = 1'b0;
        io_en_w        = 1'b0;
        io_en_r        = 1'b0;
        io_addr        = '0;
        io_data_w      = '0;
        mem_en_w       = 1'b0;
        mem_en_r       = 1'b0;
        mem_addr       = '0;
        mem_data_w     = '0;
        fail_count     = 0;
        saw_vsync_fall = 1'b0;
        saw_hsync_fall = 1'b0;

        repeat (4) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        $display("=== VGA graphics adapter test start ===");

        io_en_w   = 1'b1;
        io_addr   = 16'h03C2;
        io_data_w = 8'h01;
        @(posedge clk);
        io_en_w = 1'b0;

        io_en_r = 1'b1;
        io_addr = 16'h03C2;
        @(posedge clk);
        #1;
        if (io_data_r !== 8'h01) begin
            $display("FAIL MISC register read mismatch got=%h", io_data_r);
            fail_count++;
        end
        io_en_r = 1'b0;

        io_en_w   = 1'b1;
        io_addr   = 16'h03C0;
        io_data_w = 8'h00;
        @(posedge clk);
        io_en_w = 1'b0;

        mem_en_w = 1'b1;
        for (int i = 0; i < 4; i++) begin
            mem_addr   = i[19: 0];
            mem_data_w = 8'hAA + i[7: 0];
            @(posedge clk);
        end
        mem_en_w = 1'b0;

        io_en_w   = 1'b1;
        io_addr   = 16'h03C0;
        io_data_w = 8'h01;
        @(posedge clk);
        io_en_w = 1'b0;

        mem_en_w   = 1'b1;
        mem_addr   = 20'h0;
        mem_data_w = 8'h41;
        @(posedge clk);
        mem_addr   = 20'h1;
        mem_data_w = 8'h0F;
        @(posedge clk);
        mem_en_w = 1'b0;

        fork
            begin
                @(negedge vga_vsync);
                saw_vsync_fall = 1'b1;
                @(negedge vga_hsync);
                saw_hsync_fall = 1'b1;
            end
            begin
                // One VGA frame is 800*525 clocks; allow ~2 frames then fail.
                repeat (900000) @(posedge clk);
                if (!saw_vsync_fall || !saw_hsync_fall) begin
                    $display("FAIL VGA sync timeout vsync_fall=%0d hsync_fall=%0d",
                             saw_vsync_fall, saw_hsync_fall);
                    fail_count++;
                end
            end
        join_any
        disable fork;

        rst_n = 1'b0;
        @(posedge clk);
        #1;
        if ((vga_r !== 4'h0) || (vga_g !== 4'h0) || (vga_b !== 4'h0)) begin
            $display("FAIL RGB must be 0 during reset");
            fail_count++;
        end
        rst_n = 1'b1;
        @(posedge clk);

        if (fail_count == 0)
            $display("PASS vga_graphics_adapter");
        else
            $display("FAIL vga_graphics_adapter fail_count=%0d", fail_count);
        $finish;
    end

endmodule
