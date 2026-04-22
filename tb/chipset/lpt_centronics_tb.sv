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
//  File        : lpt_centronics_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : lpt_centronics_tb module
// ============================================================================

﻿
// ============================================================================
// lpt_centronics testbench — 写数据口、读状态/控制（ISA 并行口）
// ============================================================================
`timescale 1ns/1ps

module lpt_centronics_tb;

    logic        clk = 0;
    logic rst_n;
    logic        io_valid, io_we;
    logic [15: 0] io_addr;
    logic [ 7: 0] io_wdata, io_rdata;

    logic lpt_hit = (io_addr >= 16'h0378) && (io_addr <= 16'h037F);
    logic cs_n    = !(io_valid && lpt_hit);
    logic wr_n    = !(io_valid && io_we && lpt_hit);
    logic rd_n    = !(io_valid && !io_we && lpt_hit);

    chip_centronics_lpt dut (
        .clk    ( clk ),
        .rst_n    ( rst_n ),
        .i_cs_n     ( cs_n ),
        .i_rd_n     ( rd_n ),
        .i_wr_n     ( wr_n ),
        .i_a        ( io_addr[ 2: 0] ),
        .i_d        ( io_wdata ),
        .o_d        ( io_rdata )
    );

    always #5 clk = ~clk;

    task automatic wr(input logic [15: 0] a, input  logic [ 7: 0] d);
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
        rst_n = 1;
        io_valid = 0;
        repeat (4) @(posedge clk);
        rst_n = 0;
        repeat (2) @(posedge clk);

        wr(16'h0378, 8'hA5);
        rd(16'h0378, rb);
        if (rb !== 8'hA5)
            $display("FAIL lpt data %h", rb);
        else
            $display("PASS lpt data readback");

        rd(16'h0379, rb);
        $display("STATUS=%h", rb);
        $display("lpt_centronics_tb done");
        $finish;
    end

endmodule

