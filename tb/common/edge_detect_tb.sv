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
    parameter clock_period = 2
);

    logic clk;
    logic rst_n;
    logic signal;
    logic pos_edge;
    logic neg_edge;
    int   pos_count;
    int   neg_count;

    always #(clock_period/2) clk = ~clk;

    edge_detect edge_detect_inst (
        .i_signal   ( signal ),
        .o_pos_edge ( pos_edge ),
        .o_neg_edge ( neg_edge ),
        .clk        ( clk ),
        .rst_n      ( rst_n )
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            pos_count <= 0;
            neg_count <= 0;
        end else begin
            if (pos_edge)
                pos_count <= pos_count + 1;
            if (neg_edge)
                neg_count <= neg_count + 1;
        end
    end

    initial begin : main_test
        clk    = 1'b0;
        rst_n  = 1'b0;
        signal = 1'b0;
        repeat (2) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);

        @(negedge clk);
        signal = 1'b1;
        repeat (3) @(posedge clk);

        @(negedge clk);
        signal = 1'b0;
        repeat (3) @(posedge clk);

        if ((pos_count == 1) && (neg_count == 1))
            $display("PASS edge_detect");
        else
            $display("FAIL edge_detect pos=%0d neg=%0d", pos_count, neg_count);
        $finish;
    end

endmodule
