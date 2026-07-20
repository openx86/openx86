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
// File : tss_privilege_stack_tb.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : tss_privilege_stack ESP/SS field fetch smoke test
// ============================================================================

`timescale 1ns/1ns

module tss_privilege_stack_tb;

    logic         clk;
    logic         rst_n;
    logic         start;
    logic [31: 0] tss_base;
    logic [ 1: 0] target_cpl;
    logic         busy;
    logic         done;
    logic [31: 0] new_esp;
    logic [15: 0] new_ss;
    logic         bus_valid;
    logic         bus_ready;
    logic         bus_we;
    logic [31: 0] bus_addr;
    logic [31: 0] bus_rdata;
    logic [31: 0] bus_wdata;
    logic [31: 0] mem [0: 255];
    logic         bus_ready_r;
    int           pass_count;

    always #1 clk = ~clk;

    assign bus_rdata = mem[bus_addr[9: 2]];
    assign bus_ready = bus_ready_r;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            bus_ready_r <= 1'b0;
        else
            bus_ready_r <= bus_valid;
    end

    tss_privilege_stack dut (
        .i_start            (start),
        .i_tss_base         (tss_base),
        .i_target_cpl       (target_cpl),
        .o_busy             (busy),
        .o_done             (done),
        .o_new_esp          (new_esp),
        .o_new_ss           (new_ss),
        .o_bus_valid        (bus_valid),
        .i_bus_ready        (bus_ready),
        .o_bus_write_enable (bus_we),
        .o_bus_address      (bus_addr),
        .i_bus_data_read    (bus_rdata),
        .o_bus_data_write   (bus_wdata),
        .clk                (clk),
        .rst_n              (rst_n)
    );

    initial begin
        clk         = 1'b0;
        rst_n       = 1'b0;
        start       = 1'b0;
        tss_base    = 32'h0000_0100;
        target_cpl  = 2'd0;
        pass_count  = 0;
        for (int i = 0; i < 256; i++)
            mem[i] = 32'h0;
        mem[(32'h104) >> 2] = 32'h0000_AAAA;
        mem[(32'h108) >> 2] = 32'h0000_0018;
        mem[(32'h10C) >> 2] = 32'h0000_BBBB;
        mem[(32'h110) >> 2] = 32'h0000_0020;
        #4;
        rst_n = 1'b1;
        @(posedge clk);

        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
        wait (done);
        if ((new_esp == 32'h0000_AAAA) && (new_ss == 16'h0018))
            pass_count++;

        target_cpl = 2'd1;
        @(posedge clk);
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
        wait (done);
        if ((new_esp == 32'h0000_BBBB) && (new_ss == 16'h0020))
            pass_count++;

        if (pass_count == 2)
            $display("PASS tss_privilege_stack");
        else
            $fatal(1, "FAIL tss_privilege_stack");
        $finish;
    end

endmodule
