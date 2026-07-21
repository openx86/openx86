// ============================================================================
// Copyright (c) 2026 Chang Wei
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
// File : sdram_controller_tb.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : Byte-enable RMW and aligned dword write for sdram_controller
// ============================================================================

`timescale 1ns/1ns

module sdram_controller_tb;

    logic         clk;
    logic         rst_n;
    logic         en;
    logic         we;
    logic [23: 0] addr_off;
    logic [31: 0] wdata;
    logic [ 3: 0] be_n;
    logic [31: 0] rdata;
    logic         ready;
    logic         busy;
    logic         phy_clk, phy_cke, phy_cs_n, phy_ras_n, phy_cas_n, phy_we_n;
    logic [ 1: 0] phy_ba;
    logic [12: 0] phy_a;
    logic [ 1: 0] phy_dqm;
    logic [15: 0] phy_dq_out;
    logic         phy_dq_oe;
    logic [15: 0] phy_dq_in;

    integer cycles;

    always #1 clk = ~clk;

    sdram_controller #(
        .CLK_HZ            (50_000_000),
        .INIT_WAIT_CYCLES  (4),
        .P_BEHAVIORAL_MEM  (1'b1),
        .P_BEHAVIORAL_WORDS(1024),
        .REFRESH_CYCLES    (10000)
    ) dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .i_en           (en),
        .i_we           (we),
        .i_addr_off     (addr_off),
        .i_wdata        (wdata),
        .i_be_n         (be_n),
        .o_rdata        (rdata),
        .o_ready        (ready),
        .o_busy         (busy),
        .o_sdram_clk    (phy_clk),
        .o_sdram_cke    (phy_cke),
        .o_sdram_cs_n   (phy_cs_n),
        .o_sdram_ras_n  (phy_ras_n),
        .o_sdram_cas_n  (phy_cas_n),
        .o_sdram_we_n   (phy_we_n),
        .o_sdram_ba     (phy_ba),
        .o_sdram_a      (phy_a),
        .o_sdram_dqm    (phy_dqm),
        .o_sdram_dq_out (phy_dq_out),
        .o_sdram_dq_oe  (phy_dq_oe),
        .i_sdram_dq_in  (phy_dq_in)
    );

    task automatic wait_ready;
        begin
            cycles = 0;
            while (!ready && cycles < 200) begin
                @(posedge clk);
                cycles = cycles + 1;
            end
            if (!ready) begin
                $display("FAIL: timeout waiting for ready");
                $fatal(1);
            end
            @(posedge clk);
            en = 1'b0;
        end
    endtask

    task automatic do_write (
        input logic [23: 0] a,
        input logic [31: 0] d,
        input logic [ 3: 0] ben
    );
        begin
            @(posedge clk);
            en       = 1'b1;
            we       = 1'b1;
            addr_off = a;
            wdata    = d;
            be_n     = ben;
            @(posedge clk);
            wait_ready();
        end
    endtask

    task automatic do_read (
        input  logic [23: 0] a,
        output logic [31: 0] d
    );
        begin
            @(posedge clk);
            en       = 1'b1;
            we       = 1'b0;
            addr_off = a;
            be_n     = 4'h0;
            @(posedge clk);
            wait_ready();
            d = rdata;
        end
    endtask

    logic [31: 0] got;

    initial begin
        clk      = 1'b0;
        rst_n    = 1'b0;
        en       = 1'b0;
        we       = 1'b0;
        addr_off = 24'h0;
        wdata    = 32'h0;
        be_n     = 4'h0;
        phy_dq_in = 16'h0;
        #20 rst_n = 1'b1;

        // Wait for init to reach idle
        repeat (40) @(posedge clk);

        // Aligned dword write
        do_write(24'h100, 32'hAABB_CCDD, 4'b0000);
        do_read(24'h100, got);
        if (got !== 32'hAABB_CCDD) begin
            $display("FAIL dword: got %08h", got);
            $fatal(1);
        end

        // STOSB-style: write only byte 0, preserve others
        do_write(24'h100, 32'h0000_0011, 4'b1110);
        do_read(24'h100, got);
        if (got !== 32'hAABB_CC11) begin
            $display("FAIL byte0 RMW: got %08h", got);
            $fatal(1);
        end

        // IVT word at offset 2 within dword (bytes 2-3)
        do_write(24'h100, 32'h2233_0000, 4'b0011);
        do_read(24'h100, got);
        if (got !== 32'h2233_CC11) begin
            $display("FAIL halfword RMW: got %08h", got);
            $fatal(1);
        end

        // Adjacent IVT word at next dword should be untouched after byte stores there
        do_write(24'h104, 32'hDEAD_BEEF, 4'b0000);
        do_write(24'h104, 32'h0000_00AA, 4'b1110);
        do_read(24'h104, got);
        if (got !== 32'hDEAD_BEAA) begin
            $display("FAIL adjacent dword byte: got %08h", got);
            $fatal(1);
        end
        do_read(24'h100, got);
        if (got !== 32'h2233_CC11) begin
            $display("FAIL neighbor clobber: got %08h", got);
            $fatal(1);
        end

        $display("PASS sdram_controller_tb");
        $finish;
    end

endmodule
