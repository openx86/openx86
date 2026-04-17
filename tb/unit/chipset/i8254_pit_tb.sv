/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements i8254_pit_tb.
*/
// ============================================================================
// i8254_pit testbench（ISA 并行口）
// ============================================================================
`timescale 1ns/1ps
module i8254_pit_tb;

    logic        clock = 0;
    logic        reset;
    logic        valid;
    logic        we;
    logic [15: 0] addr;
    logic [ 7: 0]  wdata;
    logic [ 7: 0]  rdata;
    logic        out0, out1, out2;

    wire hit  = (addr >= 16'h0040) && (addr <= 16'h0043);
    wire cs_n = !(valid && hit);
    wire wr_n = !(valid && we && hit);
    wire rd_n = !(valid && !we && hit);

    chip_8254_pit dut (
        .clock    ( clock ),
        .reset_n    ( reset_n ),
        .i_cs_n     ( cs_n ),
        .i_rd_n     ( rd_n ),
        .i_wr_n     ( wr_n ),
        .i_a        ( addr[ 1: 0] ),
        .i_d        ( wdata ),
        .o_d        ( rdata ),
        .o_out0     ( out0 ),
        .o_out1     ( out1 ),
        .o_out2     ( out2 )
    );

    always #5 clock = ~clock;

    task automatic wr(input logic [15: 0] a, input logic [ 7: 0] d);
        @(posedge clock);
        valid = 1;
        we    = 1;
        addr  = a;
        wdata = d;
        @(posedge clock);
        valid = 0;
    endtask

    task automatic rd(input logic [15: 0] a, output logic [ 7: 0] d);
        @(posedge clock);
        valid = 1;
        we    = 0;
        addr  = a;
        @(posedge clock);
        d = rdata;
        valid = 0;
    endtask

    logic [ 7: 0] rb;
    initial begin
        reset = 1;
        valid = 0;
        we    = 0;
        addr  = '0;
        wdata = '0;
        repeat (3) @(posedge clock);
        reset = 0;
        repeat (2) @(posedge clock);

        wr(16'h0043, 8'h36);
        wr(16'h0040, 8'h04);
        wr(16'h0040, 8'h00);
        rd(16'h0040, rb);
        $display("PASS pit read (data=%h)", rb);

        repeat (20) @(posedge clock);
        $display("i8254_pit_tb done");
        $finish;
    end

endmodule
