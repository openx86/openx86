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
//  File        : tb_bios_top.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Top-level testbench for chip_pc_bios_eeprom UVM environment
// ============================================================================

`timescale 1ns / 1ps

module tb_bios_top;

    import uvm_pkg::*;
    import uvm_bios_pkg::*;

    logic clk;
    logic rst_n;

    always #5 clk = ~clk;

    initial begin
        clk   = 1'b0;
        rst_n = 1'b0;
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
    end

    bios_if u_if ();

    chip_pc_bios_eeprom u_dut (
        .i_sys_bios_byte_off ( u_if.sys_bios_off ),
        .o_sys_bios_rdata    ( u_if.sys_bios_data ),
        .i_ext_bios_byte_off ( u_if.ext_bios_off ),
        .o_ext_bios_rdata    ( u_if.ext_bios_data ),
        .clk                 ( clk ),
        .rst_n               ( rst_n )
    );

    initial begin
        uvm_config_db#(virtual bios_if)::set(null, "*", "vif", u_if);
        run_test();
    end

endmodule
