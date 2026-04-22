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
//  File        : mem_to_wrb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Pipeline register from memory to writeback stage
// ============================================================================

module mem_to_wrb (
    input  logic        i_stage4_valid,
    output logic        o_stage4_valid,
    input  logic        i_wrb_ready,
    output logic        o_mem_ready,
    input  logic        i_mem_valid,
    output logic        o_mem_valid,
    input  logic        i_mem_write_enable,
    output logic        o_mem_write_enable,
    input  logic [31: 0] i_mem_address,
    output logic [31: 0] o_mem_address,
    input  logic [31: 0] i_mem_write_data,
    output logic [31: 0] o_mem_write_data,
    input  logic        i_flush,
    input  logic        clk,
    input  logic        rst_n
);
    // Simple pass-through pipeline register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_stage4_valid      <= 1'b0;
            o_mem_valid         <= 1'b0;
            o_mem_write_enable  <= 1'b0;
            o_mem_address       <= 32'b0;
            o_mem_write_data    <= 32'b0;
        end else if (i_flush) begin
            o_stage4_valid <= 1'b0;
        end else if (i_wrb_ready) begin
            o_stage4_valid      <= i_stage4_valid;
            o_mem_valid         <= i_mem_valid;
            o_mem_write_enable  <= i_mem_write_enable;
            o_mem_address       <= i_mem_address;
            o_mem_write_data    <= i_mem_write_data;
        end
    end

    assign o_mem_ready = i_wrb_ready;

endmodule
