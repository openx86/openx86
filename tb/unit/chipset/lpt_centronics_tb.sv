/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements lpt_centronics_tb.
*/
// ============================================================================
// lpt_centronics testbench — 写数据口、读状态/控制（ISA 并行口）
// ============================================================================
`timescale 1ns/1ps

module lpt_centronics_tb;

    logic        clock = 0;
    logic        reset;
    logic        io_valid, io_we;
    logic [15:0] io_addr;
    logic [7:0]  io_wdata, io_rdata;

    wire lpt_hit = (io_addr >= 16'h0378) && (io_addr <= 16'h037F);
    wire cs_n    = !(io_valid && lpt_hit);
    wire wr_n    = !(io_valid && io_we && lpt_hit);
    wire rd_n    = !(io_valid && !io_we && lpt_hit);

    chip_centronics_lpt dut (
        .i_clock    ( clock ),
        .i_reset    ( reset ),
        .i_cs_n     ( cs_n ),
        .i_rd_n     ( rd_n ),
        .i_wr_n     ( wr_n ),
        .i_a        ( io_addr[2:0] ),
        .i_d        ( io_wdata ),
        .o_d        ( io_rdata )
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
        reset = 1;
        io_valid = 0;
        repeat (4) @(posedge clock);
        reset = 0;
        repeat (2) @(posedge clock);

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
