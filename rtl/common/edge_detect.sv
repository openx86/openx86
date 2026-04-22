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
//  File        : edge_detect.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : edge_detect module
// ============================================================================

module edge_detect (
    // =========================
    // signal detection interface
    // =========================
    input  logic i_signal,
    output logic o_pos_edge,
    output logic o_neg_edge,

    // =========================
    // clock and reset
    // =========================
    input  logic clk,
    input  logic rst_n
);

    // ============================================================
    // previous cycle input register (for edge detection)
    // ============================================================
    logic signal_prev;

    // ============================================================
    // edge detection logic
    // ============================================================
    always_ff @(posedge clk or negedge rst_n) begin : ff_edge_detect
    if (~rst_n) begin
        o_pos_edge    <= 1'b0;
        o_neg_edge    <= 1'b0;
        signal_prev   <= 1'b0;
    end else begin
        o_pos_edge    <= ~signal_prev &  i_signal;
        o_neg_edge    <=  signal_prev & ~i_signal;
        signal_prev   <= i_signal;
    end
end

endmodule
