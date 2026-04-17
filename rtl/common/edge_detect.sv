/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements edge_detect.
*/
// ============================================================================
// edge_detect
// ----------------------------------------------------------------------------
// 对输入 `signal` 做边沿检测，输出单周期脉冲：
// - `pos_edge`：检测到 0->1 上升沿时拉高 1 个 clock 周期
// - `neg_edge`：检测到 1->0 下降沿时拉高 1 个 clock 周期
//
// 设计要点：
// - 通过寄存 `signal_prev` 与当前 `signal` 比较得到边沿。
// - 异步复位（negedge reset_n）将输出与 `signal_prev` 清零。
// ============================================================================

module edge_detect (
    // ports
    input  logic        signal,
    output logic        pos_edge,
    output logic        neg_edge,
    input  logic        reset_n,

    input  logic        clock
);

logic signal_prev;

always_ff @(posedge clock or negedge reset_n) begin
    if (~reset_n) begin
        pos_edge <= 0;
        neg_edge <= 0;
        signal_prev <= 0;
    end else begin
        pos_edge <= ~signal_prev &  signal;
        neg_edge <=  signal_prev & ~signal;
        signal_prev <= signal;
    end
end

endmodule
