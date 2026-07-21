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
//  File        : fifo_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : fifo_tb module
// ============================================================================

`timescale 1ns/1ns

module fifo_tb;

    // ============================================================
    // test signals
    // ============================================================
    logic                clk;
    logic                rst_n;

    logic                i_push_valid;
    logic [15: 0][ 7: 0] i_push_data;
    logic [ 4: 0]        i_push_bytes;
    logic                o_push_ready;

    logic                i_pop_valid;
    logic [ 4: 0]        i_pop_bytes;
    logic                o_pop_ready;

    logic [15: 0][ 7: 0] o_window_data;
    logic [ 4: 0]        o_count;
    logic                o_full;
    logic                o_empty;
    logic                i_clear;

    // ============================================================
    // DUT instantiation
    // ============================================================
    fifo #(
        .P_DEPTH      ( 16 ),
        .P_DATA_WIDTH ( 8 )
    ) u_dut (
        .i_push_valid  ( i_push_valid ),
        .i_push_data   ( i_push_data ),
        .i_push_bytes  ( i_push_bytes ),
        .o_push_ready  ( o_push_ready ),
        .i_pop_valid   ( i_pop_valid ),
        .i_pop_bytes   ( i_pop_bytes ),
        .o_pop_ready   ( o_pop_ready ),
        .o_window_data ( o_window_data ),
        .o_count       ( o_count ),
        .o_full        ( o_full ),
        .o_empty       ( o_empty ),
        .i_clear       ( i_clear ),
        .clk           ( clk ),
        .rst_n         ( rst_n )
    );

    // ============================================================
    // tasks
    // ============================================================
    task automatic tick;
        begin
            #5 clk = 1'b1;
            #5 clk = 1'b0;
        end
    endtask

    // ============================================================
    // test procedure
    // ============================================================
    initial begin : main_test
        clk         = 1'b0;
        rst_n       = 1'b0;
        i_push_valid = 1'b0;
        i_push_data  = '0;
        i_push_bytes = 5'd0;
        i_pop_valid  = 1'b0;
        i_pop_bytes  = 5'd0;
        i_clear      = 1'b0;

        tick();
        rst_n = 1'b1;

        if (o_empty !== 1'b1) begin
            $fatal(1, "fifo should be empty after reset");
        end

        for (int i = 0; i < 16; i++) begin
            i_push_data[i] = 8'(i);
        end

        i_push_bytes = 5'd16;
        i_push_valid = 1'b1;
        tick();
        i_push_valid = 1'b0;
        i_push_bytes = 5'd0;

        if (o_count !== 5'd16 || o_full !== 1'b1) begin
            $fatal(1, "fifo should be full after pushing 16 bytes");
        end
        if (o_window_data[0] !== 8'h00 || o_window_data[15] !== 8'h0F) begin
            $fatal(1, "fifo window mismatch after full push");
        end

        i_pop_bytes = 5'd3;
        i_pop_valid = 1'b1;
        tick();
        i_pop_valid = 1'b0;
        i_pop_bytes = 5'd0;

        if (o_count !== 5'd13 || o_window_data[0] !== 8'h03) begin
            $fatal(1, "fifo pop-3 behavior mismatch");
        end

        i_pop_bytes = 5'd5;
        i_pop_valid = 1'b1;
        tick();
        i_pop_valid = 1'b0;
        i_pop_bytes = 5'd0;

        if (o_count !== 5'd8 || o_window_data[0] !== 8'h08) begin
            $fatal(1, "fifo pop-5 behavior mismatch");
        end

        i_push_data = '0;
        for (int i = 0; i < 8; i++) begin
            i_push_data[i] = 8'(16 + i);
        end

        i_push_bytes = 5'd8;
        i_push_valid = 1'b1;
        tick();
        i_push_valid = 1'b0;
        i_push_bytes = 5'd0;

        if (o_count !== 5'd16 || o_window_data[0] !== 8'h08) begin
            $fatal(1, "fifo wraparound push behavior mismatch");
        end

        i_pop_bytes = 5'd16;
        i_pop_valid = 1'b1;
        tick();
        i_pop_valid = 1'b0;
        i_pop_bytes = 5'd0;

        if (o_empty !== 1'b1 || o_count !== 5'd0) begin
            $fatal(1, "fifo should be empty after pop-16");
        end

        $display("fifo_tb PASS");
        $finish;
    end

endmodule
