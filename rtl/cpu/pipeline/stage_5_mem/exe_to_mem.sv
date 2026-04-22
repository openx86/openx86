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
//  File        : exe_to_mem.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : Pipeline register from execute to memory stage
// ============================================================================

module exe_to_mem (
    input  logic        i_stage3_valid,
    output logic        o_stage3_valid,
    input  logic        i_mem_stage_ready,
    output logic        o_exe_ready,
    input  logic        i_start,
    output logic        o_start,
    input  logic        i_is_store,
    output logic        o_is_store,
    input  logic [31: 0] i_addr,
    output logic [31: 0] o_addr,
    input  logic [31: 0] i_wdata,
    output logic [31: 0] o_wdata,
    input  logic [31: 0] i_mem_rdata,
    output logic [31: 0] o_mem_rdata,
    input  logic        i_mem_ready,
    output logic        o_mem_ready,
    input  logic        i_flush,
    input  logic        clk,
    input  logic        rst_n
);
    // Simple pass-through pipeline register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_stage3_valid <= 1'b0;
            o_start        <= 1'b0;
            o_is_store     <= 1'b0;
            o_addr         <= 32'b0;
            o_wdata        <= 32'b0;
            o_mem_rdata    <= 32'b0;
            o_mem_ready    <= 1'b0;
        end else if (i_flush) begin
            o_stage3_valid <= 1'b0;
        end else if (i_mem_stage_ready) begin
            o_stage3_valid <= i_stage3_valid;
            o_start        <= i_start;
            o_is_store     <= i_is_store;
            o_addr         <= i_addr;
            o_wdata        <= i_wdata;
            o_mem_rdata    <= i_mem_rdata;
            o_mem_ready    <= i_mem_ready;
        end
    end

    assign o_exe_ready = i_mem_stage_ready;

endmodule
