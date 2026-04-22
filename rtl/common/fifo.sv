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
//  File        : fifo.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : fifo module
// ============================================================================

module fifo #(
    parameter int P_DEPTH      = 16,
    parameter int P_DATA_WIDTH = 8
) (
    // =========================
    // push interface
    // =========================
    input  logic                                  i_push_valid,
    input  logic [P_DEPTH - 1: 0][P_DATA_WIDTH - 1: 0] i_push_data,
    input  logic [$clog2(P_DEPTH + 1) - 1: 0]     i_push_bytes,
    output logic                                  o_push_ready,

    // =========================
    // pop interface
    // =========================
    input  logic                                  i_pop_valid,
    input  logic [$clog2(P_DEPTH + 1) - 1: 0]     i_pop_bytes,
    output logic                                  o_pop_ready,

    // =========================
    // status interface
    // =========================
    output logic [P_DEPTH - 1: 0][P_DATA_WIDTH - 1: 0] o_window_data,
    output logic [$clog2(P_DEPTH + 1) - 1: 0]     o_count,
    output logic                                  o_full,
    output logic                                  o_empty,

    // =========================
    // clock and reset
    // =========================
    input  logic                                  clk,
    input  logic                                  rst_n
);

    localparam int LP_ADDR_WIDTH  = $clog2(P_DEPTH);
    localparam int LP_COUNT_WIDTH = $clog2(P_DEPTH + 1);

    localparam logic [LP_COUNT_WIDTH - 1: 0] LP_DEPTH_W = LP_COUNT_WIDTH'(P_DEPTH);

    // ============================================================
    // FIFO storage and pointers
    // ============================================================
    logic [P_DATA_WIDTH - 1: 0] fifo_mem [0: P_DEPTH - 1];
    logic [LP_ADDR_WIDTH - 1: 0] head_ptr;
    logic [LP_ADDR_WIDTH - 1: 0] tail_ptr;
    logic [LP_COUNT_WIDTH - 1: 0] count;

    // ============================================================
    // control signals
    // ============================================================
    logic [LP_COUNT_WIDTH - 1: 0] free_count;
    logic                         do_push;
    logic                         do_pop;

    function automatic logic [LP_ADDR_WIDTH - 1: 0] f_wrap_index (
        input logic [LP_ADDR_WIDTH - 1: 0] i_base,
        input logic [LP_COUNT_WIDTH - 1: 0] i_offset
    );
        logic [LP_COUNT_WIDTH: 0] sum;
        logic [LP_COUNT_WIDTH: 0] sum_sub;
        begin
            sum = {1'b0, i_base} + {1'b0, i_offset};
            if (sum >= {1'b0, LP_DEPTH_W}) begin
                sum_sub      = sum - {1'b0, LP_DEPTH_W};
                f_wrap_index = sum_sub[LP_ADDR_WIDTH - 1: 0];
            end else begin
                f_wrap_index = sum[LP_ADDR_WIDTH - 1: 0];
            end
        end
    endfunction

    assign free_count   = LP_DEPTH_W - count;
    assign o_push_ready = (i_push_bytes <= free_count);
    assign o_pop_ready  = (i_pop_bytes != LP_COUNT_WIDTH'(0)) & (i_pop_bytes <= count);

    assign do_push      = i_push_valid & o_push_ready & (i_push_bytes != LP_COUNT_WIDTH'(0));
    assign do_pop       = i_pop_valid & o_pop_ready;

    assign o_count      = count;
    assign o_empty      = (count == LP_COUNT_WIDTH'(0));
    assign o_full       = (count == LP_DEPTH_W);

    // ============================================================
    // window data generation
    // ============================================================
    always_comb begin : comb_window_data
        for (int i = 0; i < P_DEPTH; i++) begin
            if (LP_COUNT_WIDTH'(i) < count) begin
                o_window_data[i] = fifo_mem[f_wrap_index(head_ptr, LP_COUNT_WIDTH'(i))];
            end else begin
                o_window_data[i] = '0;
            end
        end
    end

    // ============================================================
    // sequential logic
    // ============================================================
    always_ff @(posedge clk or negedge rst_n) begin : ff_fifo_control
        if (~rst_n) begin
            head_ptr <= '0;
            tail_ptr <= '0;
            count    <= '0;
        end else begin
            if (do_push) begin
                for (int i = 0; i < P_DEPTH; i++) begin
                    if (LP_COUNT_WIDTH'(i) < i_push_bytes) begin
                        fifo_mem[f_wrap_index(tail_ptr, LP_COUNT_WIDTH'(i))] <= i_push_data[i];
                    end
                end
                tail_ptr <= f_wrap_index(tail_ptr, i_push_bytes);
            end

            if (do_pop) begin
                head_ptr <= f_wrap_index(head_ptr, i_pop_bytes);
            end

            unique case ({do_push, do_pop})
                2'b10: count <= count + i_push_bytes;
                2'b01: count <= count - i_pop_bytes;
                2'b11: count <= count + i_push_bytes - i_pop_bytes;
                default: begin
                end
            endcase
        end
    end

endmodule
