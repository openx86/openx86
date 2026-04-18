/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements edge_detect_tb.
*/
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