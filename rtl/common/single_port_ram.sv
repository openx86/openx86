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
//  File        : single_port_ram.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : single_port_ram module
// ============================================================================

module single_port_ram #(
    parameter int P_DATA_WIDTH = 8,    // 数据位宽
    parameter int P_ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int P_DEPTH      = 1 << P_ADDR_WIDTH  // 显式深度参数（可选）
) (
    // 读写端口
    input  logic                      i_we,       // 写使能：高电平在时钟沿将 wdata 写入 addr
    input  logic [P_ADDR_WIDTH - 1: 0] i_addr,     // 读写共用地址（半字/字节粒度由 DATA_WIDTH 决定）
    input  logic [P_DATA_WIDTH - 1: 0] i_wdata,    // 待写入数据
    output logic [P_DATA_WIDTH - 1: 0] o_rdata,    // 同步读输出（一拍延迟，见 always_ff 读口）

    // 时钟和复位
    input  logic                      clk,        // 单时钟域：写与读均在此沿更新
    input  logic                      rst_n       // 异步低有效复位：清零 rdata；阵列内容不强制清零
);

    // 存储阵列（综合为 BRAM 时行为由器件/工具决定）
    logic [P_DATA_WIDTH-1: 0] mem [0:P_DEPTH-1];

    // 写口时序：时钟上升沿采样；复位分支占位，有效时写入当前地址
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            // 复位时可以选择清零，也可以保持（取决于应用需求）
            // 这里不自动清零，由用户控制
        end else begin
            if (i_we) begin
                mem[i_addr] <= i_wdata;
            end
        end
    end

    // 读口时序：同步读一拍；复位将读数据口置 0
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            o_rdata <= '0;
        end else begin
            o_rdata <= mem[i_addr];
        end
    end

endmodule
