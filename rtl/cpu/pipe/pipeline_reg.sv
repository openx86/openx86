/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: generic valid/ready pipeline register with flush.
*/
// ============================================================================
// pipeline_reg
// ----------------------------------------------------------------------------
// One-entry pipeline register implementing standard valid/ready handshake:
// - Upstream drives i_valid + i_payload
// - Downstream drives i_ready
// - Transfer when (o_valid & i_ready) OR (i_valid & o_ready)
// - Holds payload while stalled
// - Flush drops stored valid
// ============================================================================

module pipeline_reg #(
    parameter int unsigned P_DATA_WIDTH = 1
) (
    input  logic i_flush, // 输入信号

    input  logic i_valid, // 输入信号
    output logic o_ready, // 输出信号
    input  logic [P_DATA_WIDTH - 1: 0] i_payload, // 输入信号

    output logic o_valid, // 输出信号
    input  logic i_ready, // 输入信号
    output logic [P_DATA_WIDTH - 1: 0] o_payload, // 输出信号

    input  logic clk, // 时钟信号
    input  logic rst_n // 复位信号
);

    logic                             full;
    logic [P_DATA_WIDTH - 1: 0] payload_r;

    assign o_valid   = full;
    assign o_payload = payload_r;

    // Can accept new data when empty, or when current data is being accepted.
    assign o_ready = ~full | (full & i_ready);

    // 时序逻辑块
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            full      <= 1'b0;
            payload_r <= '0;
        end else if (i_flush) begin
            full <= 1'b0;
        end else begin
            if (o_ready) begin
                full <= i_valid;
                if (i_valid) begin
                    payload_r <= i_payload;
                end
            end
        end
    end

endmodule

