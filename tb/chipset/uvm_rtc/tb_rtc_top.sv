// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : tb_rtc_top.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Top-level testbench for chip_mc146818_rtc UVM environment
// ============================================================================

`timescale 1ns / 1ps

module tb_rtc_top;

    import uvm_pkg::*;
    import uvm_chipset_pkg::*;
    import uvm_rtc_pkg::*;

    logic clk;
    logic rst_n;
    logic rtc_irq;

    always #5 clk = ~clk;

    initial begin
        clk   = 1'b0;
        rst_n = 1'b0;
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
    end

    isa_if u_if (.*);

    chip_mc146818_rtc #(
        .P_CLK_HZ ( 100 )  // slow for simulation
    ) u_dut (
        .i_cs_n     ( u_if.cs_n ),
        .i_rd_n     ( u_if.rd_n ),
        .i_wr_n     ( u_if.wr_n ),
        .i_a0       ( u_if.addr[0] ),
        .i_d        ( u_if.d_in ),
        .o_d        ( u_if.d_out ),
        .o_rtc_irq  ( rtc_irq ),
        .clk        ( clk ),
        .rst_n      ( rst_n )
    );

    initial begin
        uvm_config_db#(virtual isa_if)::set(null, "*", "vif", u_if);
        run_test();
    end

endmodule
