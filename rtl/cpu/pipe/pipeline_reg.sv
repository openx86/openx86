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
    parameter type T = logic [0: 0]
) (
    input  logic i_flush,

    input  logic i_valid,
    output logic o_ready,
    input  T     i_payload,

    output logic o_valid,
    input  logic i_ready,
    output T     o_payload,

    input  logic clk,
    input  logic rst_n
);

    logic full;
    T     payload_r;

    assign o_valid   = full;
    assign o_payload = payload_r;

    // Can accept new data when empty, or when current data is being accepted.
    assign o_ready = ~full | (full & i_ready);

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

