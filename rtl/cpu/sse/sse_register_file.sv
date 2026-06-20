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
//  File        : sse_register_file.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : SSE XMM0-XMM7 register file (128-bit, low 64b active)
// ============================================================================

module sse_register_file (
    input  logic         i_write_enable,
    input  logic [ 2: 0] i_write_index,
    input  logic [63: 0] i_write_data,
    input  logic [ 2: 0] i_read_index,
    output logic [63: 0] o_read_data,
    input  logic         clk,
    input  logic         rst_n
);

    logic [63: 0] xmm_reg [0: 7];

    always_ff @(posedge clk or negedge rst_n) begin : ff_sse_regs
        if (~rst_n) begin
            for (int i = 0; i < 8; i++) begin
                xmm_reg[i] <= 64'd0;
            end
        end else if (i_write_enable) begin
            xmm_reg[i_write_index] <= i_write_data;
        end
    end

    assign o_read_data = xmm_reg[i_read_index];

endmodule
