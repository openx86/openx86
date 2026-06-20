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
//  File        : i486_soc_bus_bridge_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Smoke test for 80486 to SoC bus bridge
// ============================================================================

`timescale 1ns/1ns

module i486_soc_bus_bridge_tb;

    logic clk;
    logic rst_n;
    logic        ads_n;
    logic [31: 0] address;
    logic [31: 0] data_out;
    logic         data_oe;
    logic [31: 0] data_in;
    logic         wr_n;
    logic         mio_n;
    logic         blast_n;
    logic         bready_n;
    logic         bus_valid;
    logic         bus_ready;
    logic         bus_busy;
    logic         bus_write_enable;
    logic         bus_io_access;
    logic [31: 0] bus_address;
    logic [31: 0] bus_read_data;
    logic [31: 0] bus_write_data;

    always #1 clk = ~clk;

    initial begin
        clk             = 1'b0;
        rst_n           = 1'b0;
        ads_n           = 1'b1;
        address         = 32'h0;
        data_out        = 32'h0;
        data_oe         = 1'b0;
        wr_n            = 1'b1;
        mio_n           = 1'b0;
        blast_n         = 1'b0;
        bus_ready       = 1'b0;
        bus_busy        = 1'b0;
        bus_read_data   = 32'hDEAD_BEEF;
        #4 rst_n = 1'b1;

        ads_n   = 1'b0;
        address = 32'h1000;
        #2;
        bus_ready = 1'b1;
        #2;
        bus_ready = 1'b0;
        ads_n     = 1'b1;
        blast_n   = 1'b1;
        #4;

        if (bus_valid !== 1'b0) begin
            $display("FAIL: bus_valid stuck after transaction");
            $fatal(1);
        end
        $display("PASS i486_soc_bus_bridge_tb");
        $finish;
    end

    i486_soc_bus_bridge dut (
        .i_ads_n            (ads_n),
        .i_address          (address),
        .i_data_out         (data_out),
        .i_data_oe          (data_oe),
        .o_data_in          (data_in),
        .i_wr_n             (wr_n),
        .i_mio_n            (mio_n),
        .i_blast_n          (blast_n),
        .o_bready_n         (bready_n),
        .o_bus_valid        (bus_valid),
        .i_bus_ready        (bus_ready),
        .i_bus_busy         (bus_busy),
        .o_bus_write_enable (bus_write_enable),
        .o_bus_io_access    (bus_io_access),
        .o_bus_address      (bus_address),
        .i_bus_read_data    (bus_read_data),
        .o_bus_write_data   (bus_write_data),
        .clk                (clk),
        .rst_n              (rst_n)
    );

endmodule
