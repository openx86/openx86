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
//  File        : bus_interface_unit_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : bus_interface_unit_tb module
// ============================================================================

`timescale 1ns/1ns
module bus_interface_unit_tb #(
    // parameters
    clock_period = 2
) (
    // ports
);
logic clk, rst_n;
always #(clock_period/2) clk = ~clk;

logic        i_mmu_valid;
logic        o_mmu_ready;
logic [31: 0] i_mmu_address;
logic [31: 0] o_mmu_data_read;
logic        i_code_valid;
logic        o_code_ready;
logic [31: 0] i_code_address;
logic [31: 0] o_code_data_read;
logic        i_data_valid;
logic        o_data_ready;
logic        i_data_write_enable;
logic        i_data_io_access;
logic [31: 0] i_data_address;
logic [31: 0] o_data_data_read;
logic [31: 0] i_data_data_write;
logic        o_bus_valid;
logic        i_bus_ready;
logic        i_bus_busy;
logic        o_bus_write_enable;
logic [31: 0] o_bus_address;
logic [31: 0] i_bus_data_read;
logic [31: 0] o_bus_data_write;

initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    i_mmu_valid = 0;
    i_mmu_address = 0;
    i_code_valid = 0;
    i_code_address = 0;
    i_data_valid = 0;
    i_data_write_enable = 0;
    i_data_io_access = 0;
    i_data_address = 0;
    i_data_data_write = 0;
    i_bus_ready = 0;
    i_bus_busy = 0;
    i_bus_data_read = 0;
    #(clock_period * 2);
    rst_n = 1'b1;
    #(clock_period * 2);

    // fetch code
    i_code_valid = 1;
    i_code_address = 32'h1;

    #(clock_period * 2);
    i_bus_ready = 1;
    i_bus_data_read = 32'h1;
    #(clock_period);
    i_bus_ready = 0;
    i_code_valid = 0;

    #(clock_period * 2);

    // fetch data
    i_data_valid = 1;
    i_data_address = 32'h20;

    #(clock_period * 2);
    i_bus_ready = 1;
    i_bus_data_read = 32'h200;
    #(clock_period);
    i_bus_ready = 0;
    i_data_valid = 0;

    #(clock_period * 2);

    // code and data are valid in the same time,
    // code is ready after 2 cycles, except fetch data immediately.
    i_code_valid = 1;
    i_code_address = 32'h1;

    i_data_valid = 1;
    i_data_address = 32'h20;

    #(clock_period);
    i_bus_ready = 1;
    i_bus_data_read = 32'h1;
    #(clock_period);
    i_bus_ready = 0;
    i_code_valid = 0;

    #(clock_period * 2);
    i_bus_ready = 1;
    i_bus_data_read = 32'h200;
    #(clock_period);
    i_bus_ready = 0;
    i_data_valid = 0;

    #(clock_period * 4);

    // fetch code first, then data is valid after 1 cycle,
    // data is ready after 2 cycles, except fetch code immediately.
    i_code_valid = 1;
    i_code_address = 32'h1;

    #(clock_period);

    i_data_valid = 1;
    i_data_address = 32'h20;

    #(clock_period);
    i_bus_ready = 1;
    i_bus_data_read = 32'h1;
    #(clock_period);
    i_bus_ready = 0;
    i_code_valid = 0;

    #(clock_period * 2);
    i_bus_ready = 1;
    i_bus_data_read = 32'h200;
    #(clock_period);
    i_bus_ready = 0;
    i_data_valid = 0;

    #(clock_period * 4);

    $display("PASS bus_interface_unit");
    $finish;
end

bus_interface_unit tb_bus_interface_unit (
    .i_mmu_valid         ( i_mmu_valid ),
    .o_mmu_ready         ( o_mmu_ready ),
    .i_mmu_address       ( i_mmu_address ),
    .o_mmu_data_read     ( o_mmu_data_read ),
    .i_code_valid        ( i_code_valid ),
    .o_code_ready        ( o_code_ready ),
    .i_code_address      ( i_code_address ),
    .o_code_data_read    ( o_code_data_read ),
    .i_data_valid        ( i_data_valid ),
    .o_data_ready        ( o_data_ready ),
    .i_data_write_enable ( i_data_write_enable ),
    .i_data_io_access    ( i_data_io_access ),
    .i_data_address      ( i_data_address ),
    .o_data_data_read    ( o_data_data_read ),
    .i_data_data_write   ( i_data_data_write ),
    .o_bus_valid         ( o_bus_valid ),
    .i_bus_ready         ( i_bus_ready ),
    .i_bus_busy          ( i_bus_busy ),
    .o_bus_write_enable  ( o_bus_write_enable ),
    .o_bus_address       ( o_bus_address ),
    .i_bus_data_read     ( i_bus_data_read ),
    .o_bus_data_write    ( o_bus_data_write ),
    .clk             ( clk ),
    .rst_n             ( rst_n )
);

endmodule
