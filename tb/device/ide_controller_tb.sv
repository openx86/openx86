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
//  File        : ide_controller_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ide_controller_tb module
// ============================================================================

// ============================================================================

`timescale 1ns/1ps

module ide_controller_tb;

    logic        clk = 0;
    logic        rst_n;
    logic        io_valid;
    logic        io_we;
    logic [15: 0] io_addr;
    logic [ 7: 0] io_wdata;
    logic [ 7: 0] io_rdata;

    logic ide_hit = ((io_addr >= 16'h01F0) && (io_addr <= 16'h01F7)) | (io_addr == 16'h03F6);
    logic cs_n    = !(io_valid && ide_hit);
    logic wr_n    = !(io_valid && io_we && ide_hit);
    logic rd_n    = !(io_valid && !io_we && ide_hit);

    always #5 clk = ~clk;

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
        .clk          ( clk ),
        .rst_n        ( rst_n )
    );

    task automatic wr(input logic [15: 0] a, input logic [ 7: 0] d);
        @(posedge clk);
        io_valid = 1;
        io_we    = 1;
        io_addr  = a;
        io_wdata = d;
        @(posedge clk);
        io_valid = 0;
    endtask

    task automatic rd(input logic [15: 0] a, output logic [ 7: 0] d);
        @(posedge clk);
        io_valid = 1;
        io_we    = 0;
        io_addr  = a;
        @(posedge clk);
        d = io_rdata;
        io_valid = 0;
    endtask

    logic [ 7: 0] rb;
    initial begin
        rst_n  = 0;
        io_valid = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        wr(16'h01F2, 8'h01);
        wr(16'h01F3, 8'h00);
        wr(16'h01F4, 8'h00);
        wr(16'h01F5, 8'h00);
        wr(16'h01F6, 8'hE0);
        wr(16'h01F7, 8'h20);
        repeat (2) @(posedge clk);
        rd(16'h01F0, rb);
        if (rb !== 8'hA5)
            $display("FAIL ide_controller first byte %h", rb);
        else
            $display("PASS ide_controller_tb");

        $finish;
    end

endmodule
