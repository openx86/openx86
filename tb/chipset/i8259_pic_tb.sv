/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements i8259_pic_tb.
*/
// ============================================================================
// i8259_pic testbench — 单主片初始化 + IMR + 中断线（ISA 并行口）
// ============================================================================
module i8259_pic_tb;

    logic        clk = 0;
    logic rst_n;
    logic        valid;
    logic        we;
    logic [15: 0] addr;
    logic [ 7: 0]  wdata;
    logic [ 7: 0]  rdata;
    logic [ 7: 0] ir;
    logic        intr;

    logic hit   = (addr >= 16'h0020) && (addr <= 16'h0021);
    logic cs_n  = !(valid && hit);
    logic wr_n  = !(valid && we && hit);
    logic rd_n  = !(valid && !we && hit);

    chip_8259_pic dut (
        .clk    ( clk ),
        .rst_n    ( rst_n ),
        .i_cs_n     ( cs_n ),
        .i_rd_n     ( rd_n ),
        .i_wr_n     ( wr_n ),
        .i_a0       ( addr[0] ),
        .i_d        ( wdata ),
        .o_d        ( rdata ),
        .i_ir       ( ir ),
        .o_intr     ( intr )
    );

    always #5 clk = ~clk;

    task automatic wr(input logic [15: 0] a, input  logic [ 7: 0] d);
        @(posedge clk);
        valid = 1;
        we    = 1;
        addr  = a;
        wdata = d;
        @(posedge clk);
        valid = 0;
    endtask

    initial begin
        ir    = 8'h0;
        rst_n = 1;
        valid = 0;
        we    = 0;
        addr  = 16'h0020;
        wdata = '0;
        repeat (3) @(posedge clk);
        rst_n = 0;
        repeat (2) @(posedge clk);

        wr(16'h0020, 8'h13);
        wr(16'h0021, 8'h08);
        wr(16'h0021, 8'h01);
        wr(16'h0021, 8'hFE);
        ir = 8'h01;
        repeat (2) @(posedge clk);
        if (!intr)
            $display("FAIL pic intr");
        else
            $display("PASS pic intr");

        $display("i8259_pic_tb done");
        $finish;
    end

endmodule

