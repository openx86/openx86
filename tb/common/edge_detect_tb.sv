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
//  File        : edge_detect_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : edge_detect_tb module
// ============================================================================

`timescale 1ns/1ns
module edge_detect_tb #(
    // parameters
    clock_period = 2
) (
    // ports
);

logic clk, rst_n;
logic signal;

always #(clock_period/2) clk = ~clk;

initial begin
    clk <= 0;
    rst_n <= 1;
    signal <= 0;

    #3;
    rst_n <= 0;

    #1;
    signal <= 0;

    #2;
    signal <= 1;

    #1;
    signal <= 1;

    #3;
    signal <= 0;

    #4;

    $finish;
end

logic pos_edge, neg_edge;
edge_detect edge_detect_inst (
    .signal ( signal ),
    .pos_edge ( pos_edge ),
    .neg_edge ( neg_edge ),
    .clk ( clk ),
    .rst_n ( rst_n )
);

endmodule