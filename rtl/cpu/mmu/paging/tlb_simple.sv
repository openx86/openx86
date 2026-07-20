// ============================================================================
// Copyright (c) 2026 Chang Wei
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
// File : tlb_simple.sv
// Author : Chang Wei <changwei1006@gmail.com>
// Description : 4-entry fully-associative TLB (lookup / INVLPG / flush-all)
// ============================================================================

`include "openx86_defs.h.sv"

module tlb_simple #(
    parameter int P_ENTRIES = 4
) (
    input  logic         i_lookup_valid,
    input  logic [31: 0] i_lookup_linear,
    output logic         o_hit,
    output logic [31: 0] o_phys_page_base,
    input  logic         i_fill_valid,
    input  logic [31: 0] i_fill_linear,
    input  logic [31: 0] i_fill_phys_page,
    input  logic         i_invall,
    input  logic         i_invlpg,
    input  logic [31: 0] i_invlpg_linear,
    input  logic         clk,
    input  logic         rst_n
);

    logic         valid_r   [0:P_ENTRIES-1];
    logic [19: 0] tag_r     [0:P_ENTRIES-1];
    logic [19: 0] phys_r    [0:P_ENTRIES-1];
    logic [ 1: 0] victim_r;
    logic [19: 0] lookup_tag;
    logic [19: 0] fill_tag;
    logic [19: 0] inv_tag;
    logic         hit_comb;
    logic [31: 0] hit_phys;

    assign lookup_tag = i_lookup_linear[31: 12];
    assign fill_tag   = i_fill_linear[31: 12];
    assign inv_tag    = i_invlpg_linear[31: 12];

    always_comb begin
        hit_comb = 1'b0;
        hit_phys = 32'h0;
        for (int i = 0; i < P_ENTRIES; i++) begin
            if (valid_r[i] && (tag_r[i] == lookup_tag)) begin
                hit_comb = 1'b1;
                hit_phys = {phys_r[i], 12'h0};
            end
        end
    end

    assign o_hit            = i_lookup_valid & hit_comb;
    assign o_phys_page_base = hit_phys;

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            for (int i = 0; i < P_ENTRIES; i++) begin
                valid_r[i] <= 1'b0;
                tag_r[i]   <= 20'h0;
                phys_r[i]  <= 20'h0;
            end
            victim_r <= 2'd0;
        end else begin
            if (i_invall) begin
                for (int i = 0; i < P_ENTRIES; i++)
                    valid_r[i] <= 1'b0;
            end else if (i_invlpg) begin
                for (int i = 0; i < P_ENTRIES; i++) begin
                    if (valid_r[i] && (tag_r[i] == inv_tag))
                        valid_r[i] <= 1'b0;
                end
            end else if (i_fill_valid) begin
                valid_r[victim_r] <= 1'b1;
                tag_r[victim_r]   <= fill_tag;
                phys_r[victim_r]  <= i_fill_phys_page[31: 12];
                victim_r          <= victim_r + 2'd1;
            end
        end
    end

endmodule
