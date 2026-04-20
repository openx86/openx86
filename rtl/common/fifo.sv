/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: byte FIFO with variable push/pop bytes and 16-byte decode window output.
*/
// ============================================================================
// fifo
// ----------------------------------------------------------------------------
// Parameterized byte FIFO used by IFU.
// - Supports variable byte-count push and pop in one cycle
// - Exposes a 16-byte logical window from current head
// ============================================================================

module fifo #(
    parameter int P_DEPTH      = 16,
    parameter int P_DATA_WIDTH = 8
) (
    input  logic                                  i_push_valid, // 输入信号
    input  logic [P_DEPTH - 1: 0][P_DATA_WIDTH - 1: 0] i_push_data, // 输入信号
    input  logic [$clog2(P_DEPTH + 1) - 1: 0]    i_push_bytes, // 输入信号
    output logic                                  o_push_ready, // 输出信号

    input  logic                                  i_pop_valid, // 输入信号
    input  logic [$clog2(P_DEPTH + 1) - 1: 0]    i_pop_bytes, // 输入信号
    output logic                                  o_pop_ready, // 输出信号

    output logic [P_DEPTH - 1: 0][P_DATA_WIDTH - 1: 0] o_window_data, // 输出信号
    output logic [$clog2(P_DEPTH + 1) - 1: 0]    o_count, // 输出信号
    output logic                                  o_full, // 输出信号
    output logic                                  o_empty, // 输出信号

    input  logic                                  clk, // 时钟信号
    input  logic                                  rst_n // 复位信号
);

    localparam int LP_ADDR_WIDTH  = $clog2(P_DEPTH);
    localparam int LP_COUNT_WIDTH = $clog2(P_DEPTH + 1);

    localparam logic [LP_COUNT_WIDTH - 1: 0] LP_DEPTH_W = LP_COUNT_WIDTH'(P_DEPTH);

    logic [P_DATA_WIDTH - 1: 0] fifo_mem [0: P_DEPTH - 1];
    logic [LP_ADDR_WIDTH - 1: 0] head_ptr;
    logic [LP_ADDR_WIDTH - 1: 0] tail_ptr;
    logic [LP_COUNT_WIDTH - 1: 0] count;

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

    assign do_push = i_push_valid & o_push_ready & (i_push_bytes != LP_COUNT_WIDTH'(0));
    assign do_pop  = i_pop_valid & o_pop_ready;

    assign o_count = count;
    assign o_empty = (count == LP_COUNT_WIDTH'(0));
    assign o_full  = (count == LP_DEPTH_W);

    // 组合逻辑块
    always_comb begin
        for (int i = 0; i < P_DEPTH; i++) begin
            if (LP_COUNT_WIDTH'(i) < count) begin
                o_window_data[i] = fifo_mem[f_wrap_index(head_ptr, LP_COUNT_WIDTH'(i))];
            end else begin
                o_window_data[i] = '0;
            end
        end
    end

    // 时序逻辑块
    always_ff @(posedge clk or negedge rst_n) begin
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
