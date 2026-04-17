/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Integration testbench for bus_controller + chip_8237_dma path.
*/
// ============================================================================
// bus + chipset integration test (DMA ports through bus_controller)
// ============================================================================
`timescale 1ns/1ps
module bus_chipset_integration_tb;

    logic         clock = 0;
    logic         reset_n;
    logic         bus_valid;
    logic         bus_ready;
    logic         bus_busy;
    logic         bus_we;
    logic         bus_io;
    logic [31: 0] bus_addr;
    logic [31: 0] bus_rdata;
    logic [31: 0] bus_wdata;
    integer       fail_count;

    logic        vga_mem_en_w;
    logic [19: 0] vga_mem_addr;
    logic [ 7: 0]  vga_mem_data_w;
    logic        vga_io_en_w;
    logic        vga_io_en_r;
    logic [15: 0] vga_io_addr;
    logic [ 7: 0]  vga_io_data_w;
    logic [ 7: 0]  vga_io_data_r;

    logic        o_sdram_en;
    logic        o_sdram_we;
    logic [23: 0] o_sdram_addr_off;
    logic [31: 0] o_sdram_wdata;
    logic [31: 0] i_sdram_rdata;
    logic        i_sdram_ready;
    logic        i_sdram_busy;

    logic [15: 0] bios_addr;
    logic [31: 0] bios_rdata;
    logic [16: 0] ext_bios_addr;
    logic [31: 0] ext_bios_rdata;

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
        .clock            ( clock ),
        .reset_n          ( reset_n )
    );

    assign i_sdram_rdata = 32'h0;
    assign i_sdram_ready = 1'b0;
    assign i_sdram_busy  = 1'b0;
    assign bios_rdata = 32'h0;
    assign ext_bios_rdata = 32'h0;
    assign vga_io_data_r = 8'hFF;

    always #5 clock = ~clock;

    task automatic io_write(input logic [15: 0] i_addr, input logic [ 7: 0] i_data);
        @(negedge clock);
        bus_valid = 1'b1;
        bus_we    = 1'b1;
        bus_io    = 1'b1;
        bus_addr  = { 16'h0000, i_addr };
        bus_wdata = { 24'h0, i_data };
        @(posedge clock);
        wait (bus_ready == 1'b1);
        @(negedge clock);
        bus_valid = 1'b0;
        bus_we    = 1'b0;
        bus_io    = 1'b0;
    endtask

    task automatic io_read(input logic [15: 0] i_addr, output logic [ 7: 0] o_data);
        @(negedge clock);
        bus_valid = 1'b1;
        bus_we    = 1'b0;
        bus_io    = 1'b1;
        bus_addr  = { 16'h0000, i_addr };
        @(posedge clock);
        wait (bus_ready == 1'b1);
        o_data = bus_rdata[ 7: 0];
        @(negedge clock);
        bus_valid = 1'b0;
        bus_io    = 1'b0;
    endtask

    task automatic expect_eq(
        input string      i_tag,
        input logic [7:0] i_got,
        input logic [7:0] i_exp
    );
        if (i_got !== i_exp) begin
            fail_count = fail_count + 1;
            $display("FAIL %s got=%02h exp=%02h", i_tag, i_got, i_exp);
        end else begin
            $display("PASS %s value=%02h", i_tag, i_got);
        end
    endtask

    logic [7:0] rb;

    initial begin
        fail_count = 0;
        reset_n    = 1'b0;
        bus_valid  = 1'b0;
        bus_we     = 1'b0;
        bus_io     = 1'b0;
        bus_addr   = 32'h0;
        bus_wdata  = 32'h0;

        repeat (4) @(posedge clock);
        reset_n = 1'b1;
        repeat (2) @(posedge clock);

        io_read(16'h000A, rb);
        expect_eq("reset mask", rb, 8'h0F);

        io_write(16'h000F, 8'h03);
        io_read(16'h000A, rb);
        expect_eq("mask write/read", rb, 8'h03);

        io_write(16'h0000, 8'h78);
        io_write(16'h0000, 8'h56);
        io_write(16'h000C, 8'h00);
        io_read(16'h0000, rb);
        expect_eq("addr low via bus", rb, 8'h78);
        io_read(16'h0000, rb);
        expect_eq("addr high via bus", rb, 8'h56);

        io_write(16'h0080, 8'h12);
        io_write(16'h0088, 8'h34);
        io_read(16'h0080, rb);
        expect_eq("page 80h via bus", rb, 8'h12);
        io_read(16'h0088, rb);
        expect_eq("page 88h via bus", rb, 8'h34);

        if (fail_count == 0)
            $display("PASS bus_chipset_integration_tb");
        else
            $display("FAIL bus_chipset_integration_tb fail_count=%0d", fail_count);

        $finish;
    end

endmodule
