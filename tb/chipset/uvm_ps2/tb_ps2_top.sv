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
//  File        : tb_ps2_top.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Top-level testbench for chip_i8042_ps2 UVM environment
// ============================================================================

`timescale 1ns / 1ps

module tb_ps2_top;

    import uvm_pkg::*;
    import uvm_chipset_pkg::*;
    import uvm_ps2_pkg::*;

    logic clk;
    logic rst_n;
    logic kbd_irq, aux_irq;

    always #5 clk = ~clk;

    initial begin
        clk   = 1'b0;
        rst_n = 1'b0;
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
    end

    isa_if u_if (.*);

    chip_i8042_ps2 #(
        .P_USE_REAL_PS2 ( 1'b0 ),
        .P_CLK_HZ       ( 50_000_000 )
    ) u_dut (
        .i_cs_n          ( u_if.cs_n ),
        .i_rd_n          ( u_if.rd_n ),
        .i_wr_n          ( u_if.wr_n ),
        .i_a0            ( u_if.addr[0] ),
        .i_d             ( u_if.d_in ),
        .o_d             ( u_if.d_out ),
        .i_kbd_push      ( 1'b0 ),
        .i_kbd_data      ( 8'h00 ),
        .i_aux_push      ( 1'b0 ),
        .i_aux_data      ( 8'h00 ),
        .o_kbd_irq       ( kbd_irq ),
        .o_aux_irq       ( aux_irq ),
        .i_ps2_kbd_clk_in ( 1'b1 ),
        .i_ps2_kbd_dat_in ( 1'b1 ),
        .i_ps2_aux_clk_in ( 1'b1 ),
        .i_ps2_aux_dat_in ( 1'b1 ),
        .clk             ( clk ),
        .rst_n           ( rst_n )
    );

    initial begin
        uvm_config_db#(virtual isa_if)::set(null, "*", "vif", u_if);
        run_test();
    end

endmodule
