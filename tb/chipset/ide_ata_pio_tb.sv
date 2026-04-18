/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Legacy shim — forwards to ide_controller PIO path (BRAM disk).
*/
// ============================================================================

`timescale 1ns/1ps

module ide_ata_pio_tb;

    logic        clock = 0;
    logic        reset_n;
    logic        io_valid;
    logic        io_we;
    logic [15: 0] io_addr;
    logic [ 7: 0] io_wdata;
    logic [ 7: 0] io_rdata;

    logic ide_hit = ((io_addr >= 16'h01F0) && (io_addr <= 16'h01F7)) | (io_addr == 16'h03F6);
    logic cs_n    = !(io_valid && ide_hit);
    logic wr_n    = !(io_valid && io_we && ide_hit);
    logic rd_n    = !(io_valid && !io_we && ide_hit);

    always #5 clock = ~clock;

    ide_controller #(
        .P_SECTOR_BYTES  ( 512 ),
        .P_SECTOR_COUNT  ( 4 ),
        .P_USE_SDIO_DISK ( 1'b0 )
    ) dut (
        .i_cs_n         ( cs_n ),
        .i_rd_n         ( rd_n ),
        .i_wr_n         ( wr_n ),
        .i_addr         ( io_addr ),
        .i_wdata        ( io_wdata ),
        .o_rdata        ( io_rdata ),
        .o_sdio_clk     ( ),
        .o_sdio_cmd_out ( ),
        .o_sdio_cmd_oe  ( ),
        .i_sdio_cmd_in  ( 1'b1 ),
        .o_sdio_dat_out ( ),
        .o_sdio_dat_oe  ( ),
        .i_sdio_dat_in  ( 4'hF ),
        .clock          ( clock ),
        .reset_n        ( reset_n )
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
    initial begin
        reset_n  = 0;
        io_valid = 0;
        repeat (3) @(posedge clock);
        reset_n = 1;
        repeat (2) @(posedge clock);

        wr(16'h01F2, 8'h01);
        wr(16'h01F3, 8'h00);
        wr(16'h01F4, 8'h00);
        wr(16'h01F5, 8'h00);
        wr(16'h01F6, 8'hE0);
        wr(16'h01F7, 8'h20);
        repeat (2) @(posedge clock);
        rd(16'h01F0, rb);
        if (rb !== 8'hA5)
            $display("FAIL ide first byte %h", rb);
        else
            $display("PASS ide pio read");

        $finish;
    end

endmodule
