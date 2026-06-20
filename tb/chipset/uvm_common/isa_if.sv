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
//  File        : isa_if.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ISA-style CPU bus interface (common for chipset UVM agents)
// ============================================================================

interface isa_if (
    input logic clk,
    input logic rst_n
);

    logic         cs_n;
    logic         rd_n;
    logic         wr_n;
    logic [15: 0] addr;
    logic [ 7: 0] d_in;
    logic [ 7: 0] d_out;

    clocking drv_cb @(posedge clk);
        default input #1step output #1;
        output cs_n, rd_n, wr_n, addr, d_in;
        input  d_out;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step;
        input cs_n, rd_n, wr_n, addr, d_in, d_out;
    endclocking

    modport drv_mp (clocking drv_cb, input clk, rst_n);
    modport mon_mp (clocking mon_cb, input clk, rst_n);

endinterface
