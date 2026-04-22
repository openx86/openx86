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
//  File        : rf_x86_seg_ss.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : SS segment register module
// ============================================================================

module rf_x86_seg_ss (
    input  logic         i_write_enable,
    input  logic [15: 0] i_write_selector,
    input  logic [63: 0] i_write_descriptor,
    output logic [15: 0] o_selector,
    output logic [63: 0] o_descriptor,
    input  logic         clk,
    input  logic         rst_n
);

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        o_selector <= 16'b0;
    end else if (i_write_enable) begin
        o_selector <= i_write_selector;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        o_descriptor <= 64'b0;
    end else if (i_write_enable) begin
        o_descriptor <= i_write_descriptor;
    end
end

endmodule
