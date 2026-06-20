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
//  File        : pipeline_controller.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : 80486-style pipeline stall and flush control
// ============================================================================

module pipeline_controller (
    input  logic         i_branch_taken,
    input  logic         i_mem_stall,
    input  logic         i_multicycle_stall,
    input  logic         i_exception_valid,
    input  logic         i_hlt,
    output logic         o_stall_ifu,
    output logic         o_stall_dec,
    output logic         o_stall_reg,
    output logic         o_stall_exu,
    output logic         o_flush_ifu,
    output logic         o_flush_dec,
    output logic         o_flush_reg,
    output logic         o_flush_exu,
    output logic         o_halted,
    input  logic         clk,
    input  logic         rst_n
);

    logic halted_r;

    assign o_stall_ifu = i_mem_stall | i_multicycle_stall | halted_r;
    assign o_stall_dec = i_mem_stall | i_multicycle_stall | halted_r;
    assign o_stall_reg = i_mem_stall | i_multicycle_stall;
    assign o_stall_exu = i_mem_stall;

    assign o_flush_ifu = i_branch_taken | i_exception_valid;
    assign o_flush_dec = i_branch_taken | i_exception_valid;
    assign o_flush_reg = i_branch_taken | i_exception_valid;
    assign o_flush_exu = i_exception_valid;

    assign o_halted = halted_r;

    always_ff @(posedge clk or negedge rst_n) begin : ff_halt
        if (~rst_n) begin
            halted_r <= 1'b0;
        end else if (i_exception_valid) begin
            halted_r <= 1'b0;
        end else if (i_hlt) begin
            halted_r <= 1'b1;
        end
    end

endmodule
