/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: ide_controller (SDIO) + sd_mmc_card_model_native — read LBA0 via CMD17 path.
*/
// ============================================================================

`timescale 1ns/1ps

module ide_sd_native_disk_tb;

    logic        clock = 0;
    logic        reset_n;
    logic        io_valid, io_we;
    logic [15: 0] io_addr;
    logic [ 7: 0] io_wdata, io_rdata;

    logic ide_hit = ((io_addr >= 16'h01F0) && (io_addr <= 16'h01F7)) | (io_addr == 16'h03F6);
    logic ide_cs_n = !(io_valid && ide_hit);
    logic ide_wr_n = !(io_valid && io_we && ide_hit);
    logic ide_rd_n = !(io_valid && !io_we && ide_hit);

    logic        sd_cmd = dut.o_sdio_cmd_oe ? dut.o_sdio_cmd_out : (card_cmd_oe ? card_cmd_o : 1'b1);
    logic [ 3: 0] sd_dat = dut.o_sdio_dat_oe ? dut.o_sdio_dat_out : (card_dat_oe ? card_dat_o : 4'hF);

    logic        card_cmd_oe;
    logic        card_cmd_o;
    logic        card_dat_oe;
    logic [ 3: 0] card_dat_o;

    logic        host_sd_clk;

    always #5 clock = ~clock;


    ide_controller #(
        .P_SECTOR_BYTES  ( 512 ),
        .P_SECTOR_COUNT  ( 16 ),
        .P_USE_SDIO_DISK ( 1'b1 )
    ) dut (
        .i_cs_n         ( ide_cs_n ),
        .i_rd_n         ( ide_rd_n ),
        .i_wr_n         ( ide_wr_n ),
        .i_addr         ( io_addr ),
        .i_wdata        ( io_wdata ),
        .o_rdata        ( io_rdata ),
        .o_sdio_clk     ( host_sd_clk ),
        .o_sdio_cmd_out ( ),
        .o_sdio_cmd_oe  ( ),
        .i_sdio_cmd_in  ( sd_cmd ),
        .o_sdio_dat_out ( ),
        .o_sdio_dat_oe  ( ),
        .i_sdio_dat_in  ( sd_dat ),
        .clock          ( clock ),
        .reset_n        ( reset_n )
    );

    sd_mmc_card_model_native u_card (
        .i_sd_clk      ( host_sd_clk ),
        .reset_n       ( reset_n ),
        .i_host_cmd_oe ( dut.o_sdio_cmd_oe ),
        .i_host_cmd_o  ( dut.o_sdio_cmd_out ),
        .i_sd_cmd_bus  ( sd_cmd ),
        .o_card_cmd_oe ( card_cmd_oe ),
        .o_card_cmd_o  ( card_cmd_o ),
        .i_host_dat_oe ( dut.o_sdio_dat_oe ),
        .i_host_dat_o  ( dut.o_sdio_dat_out ),
        .o_card_dat_oe ( card_dat_oe ),
        .o_card_dat_o  ( card_dat_o )
    );

    task automatic wr(input logic [15: 0] a, input logic [ 7: 0] d);
        @(posedge clock);
        io_valid = 1;
        io_we    = 1;
        io_addr  = a;
        io_wdata = d;
        @(posedge clock);
        io_valid = 0;
    endtask

    task automatic rd(input logic [15: 0] a, output logic [ 7: 0] d);
        @(posedge clock);
        io_valid = 1;
        io_we    = 0;
        io_addr  = a;
        @(posedge clock);
        d = io_rdata;
        io_valid = 0;
    endtask

    logic [ 7: 0] rb;
    int unsigned wait_cycles;

    initial begin
        reset_n  = 0;
        io_valid = 0;
        repeat (5) @(posedge clock);
        reset_n = 1;
        repeat (5) @(posedge clock);

        wr(16'h01F2, 8'h01);
        wr(16'h01F3, 8'h00);
        wr(16'h01F4, 8'h00);
        wr(16'h01F5, 8'h00);
        wr(16'h01F6, 8'hE0);
        wr(16'h01F7, 8'h20);

        wait_cycles = 0;
        while (wait_cycles < 400000) begin
            @(posedge clock);
            wait_cycles = wait_cycles + 1;
        end

        rd(16'h01F0, rb);
        if (rb !== 8'hA5)
            $display("FAIL ide_sd_native first byte %h", rb);
        else
            $display("PASS ide_sd_native_disk_tb");

        $finish;
    end

endmodule
