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
//  File        : tb_eeprom_top.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Top-level testbench for chip_at24lc32_eeprom UVM environment
// ============================================================================

`timescale 1ns / 1ps

module tb_eeprom_top;

    import uvm_pkg::*;
    import uvm_eeprom_pkg::*;

    logic clk;
    logic rst_n;

    always #5 clk = ~clk;

    initial begin
        clk   = 1'b0;
        rst_n = 1'b0;
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
    end

    i2c_if u_if ();

    logic sda_drive;

    chip_at24lc32_eeprom #(
        .P_A_PINS    ( 3'b000 ),
        .P_NUM_BYTES ( 4096 ),
        .P_PAGE_BYTES( 32 )
    ) u_dut (
        .i_scl    ( u_if.scl ),
        .i_sda    ( u_if.sda_in ),
        .o_sda_oe ( sda_drive ),
        .clk      ( clk ),
        .rst_n    ( rst_n )
    );

    assign u_if.sda_slave_drv = sda_drive ? 1'b0 : 1'b1;

    initial begin
        uvm_config_db#(virtual i2c_if)::set(null, "*", "vif", u_if);
        run_test();
    end

endmodule
