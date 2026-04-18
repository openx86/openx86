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
// - `pos_edge`：检测到 0->1 上升沿时拉高 1 个 clk 周期
// - `neg_edge`：检测到 1->0 下降沿时拉高 1 个 clk 周期
//
// 设计要点：
// - 通过寄存 `signal_prev` 与当前 `signal` 比较得到边沿。
// - 异步复位（negedge rst_n）将输出与 `signal_prev` 清零。
// ============================================================================

module edge_detect (
    // ports
    input  logic signal,    // 待检测的单比特输入（建议已同步到本域）
    output logic pos_edge,  // 上升沿脉冲：0→1 后维持 1 个 clk
    output logic neg_edge,  // 下降沿脉冲：1→0 后维持 1 个 clk
    input  logic clk,     // 采样时钟
    input  logic rst_n    // 异步低有效复位：清零输出与上一拍寄存
);

// 上一拍输入，用于与当前 signal 比较得到边沿
logic signal_prev;

// 寄存上一拍输入并产生单周期边沿脉冲
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
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
