/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements com_ns16550_tb.
*/
// ============================================================================
// com_ns16550 testbench — 写 THR + 回环读 RBR，读 LSR（ISA 并行口）
// ============================================================================
`timescale 1ns/1ps

module com_ns16550_tb;

    logic        clock = 0;
    logic        reset;
    logic        io_valid, io_we;
    logic [15:0] io_addr;
    logic [7:0]  io_wdata, io_rdata;
    logic        rx_push;
    logic [7:0]  rx_data;

    wire com_hit = (io_addr >= 16'h03F8) && (io_addr <= 16'h03FF);
    wire cs_n    = !(io_valid && com_hit);
    wire wr_n    = !(io_valid && io_we && com_hit);
    wire rd_n    = !(io_valid && !io_we && com_hit);

    chip_ns16550_com dut (
        .i_clock    ( clock ),
        .i_reset    ( reset ),
        .i_cs_n     ( cs_n ),
        .i_rd_n     ( rd_n ),
        .i_wr_n     ( wr_n ),
        .i_a        ( io_addr[2:0] ),
        .i_d        ( io_wdata ),
        .o_d        ( io_rdata ),
        .i_rx_push  ( rx_push ),
        .i_rx_data  ( rx_data )
    );

    always #5 clock = ~clock;

    task automatic wr(input logic [15:0] a, input logic [7:0] d);
        @(posedge clock);
        io_valid = 1;
        io_we    = 1;
        io_addr  = a;
        io_wdata = d;
        @(posedge clock);
        io_valid = 0;
    endtask

    task automatic rd(input logic [15:0] a, output logic [7:0] d);
        @(posedge clock);
        io_valid = 1;
        io_we    = 0;
        io_addr  = a;
        @(posedge clock);
        d = io_rdata;
        io_valid = 0;
    endtask

    logic [7:0] rb;
    initial begin
        rx_push = 0;
        rx_data = 0;
        reset   = 1;
        io_valid = 0;
        repeat (4) @(posedge clock);
        reset = 0;
        repeat (2) @(posedge clock);

        wr(16'h03FC, 8'h10);
        wr(16'h03F8, 8'h55);
        rd(16'h03F8, rb);
        if (rb !== 8'h55)
            $display("FAIL com loopback %h", rb);
        else
            $display("PASS com loopback");

        rd(16'h03FD, rb);
        $display("LSR=%h", rb);
        $display("com_ns16550_tb done");
        $finish;
    end

endmodule
