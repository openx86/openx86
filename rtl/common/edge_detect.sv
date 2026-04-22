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
//  File        : edge_detect.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : edge_detect module
// ============================================================================

module edge_detect (
    // ports
    input  logic i_signal,   // 待检测的单比特输入（建议已同步到本域）
    output logic o_pos_edge, // 上升沿脉冲：0→1 后维持 1 个 clk
    output logic o_neg_edge, // 下降沿脉冲：1→0 后维持 1 个 clk
    input  logic clk,        // 采样时钟
    input  logic rst_n       // 异步低有效复位：清零输出与上一拍寄存
);

// 上一拍输入，用于与当前 signal 比较得到边沿
logic signal_prev;

// 寄存上一拍输入并产生单周期边沿脉冲
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        o_pos_edge    <= 1'b0;
        o_neg_edge    <= 1'b0;
        signal_prev   <= 1'b0;
    end else begin
        o_pos_edge    <= ~signal_prev &  i_signal;
        o_neg_edge    <=  signal_prev & ~i_signal;
        signal_prev   <= i_signal;
    end
end

endmodule
