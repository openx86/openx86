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
//  File        : chip_8259_pic_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : chip_8259_pic_tb module
// ============================================================================

// ============================================================================
// chip_8259_pic testbench — 单主片初始化 + IMR + 中断线（ISA 并行口）
// ============================================================================
module chip_8259_pic_tb;

    logic         clk;
    logic         rst_n;
    logic         valid;
    logic         we;
    logic [15: 0] addr;
    logic [ 7: 0] wdata;
    logic [ 7: 0] rdata;
    logic [ 7: 0] ir;
    logic         intr;
    logic         hit;
    logic         cs_n;
    logic         wr_n;
    logic         rd_n;

    assign hit  = (addr >= 16'h0020) && (addr <= 16'h0021);
    assign cs_n = !(valid && hit);
    assign wr_n = !(valid && we && hit);
    assign rd_n = !(valid && !we && hit);

    chip_8259_pic dut (
        .i_cs_n ( cs_n ),
        .i_rd_n ( rd_n ),
        .i_wr_n ( wr_n ),
        .i_a0   ( addr[0] ),
        .i_d    ( wdata ),
        .o_d    ( rdata ),
        .i_ir   ( ir ),
        .o_intr ( intr ),
        .clk    ( clk ),
        .rst_n  ( rst_n )
    );

    always #5 clk = ~clk;

    task automatic wr(input logic [15: 0] a, input logic [ 7: 0] d);
        @(posedge clk);
        valid = 1;
        we    = 1;
        addr  = a;
        wdata = d;
        @(posedge clk);
        valid = 0;
    endtask

    initial begin : main_test
        clk   = 1'b0;
        ir    = 8'h0;
        rst_n = 1'b0;
        valid = 0;
        we    = 0;
        addr  = 16'h0020;
        wdata = '0;
        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        wr(16'h0020, 8'h13);
        wr(16'h0021, 8'h08);
        wr(16'h0021, 8'h01);
        wr(16'h0021, 8'hFE);
        @(negedge clk);
        ir = 8'h01;
        #1;
        if (!intr)
            $display("FAIL pic intr");
        else
            $display("PASS pic intr");

        $display("i8259_pic_tb done");
        $finish;
    end

endmodule
