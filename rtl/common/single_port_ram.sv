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
    // =========================
    // read/write port
    // =========================
    input  logic                      i_we,
    input  logic [P_ADDR_WIDTH - 1: 0] i_addr,
    input  logic [P_DATA_WIDTH - 1: 0] i_wdata,
    output logic [P_DATA_WIDTH - 1: 0] o_rdata,

    // =========================
    // clock and reset
    // =========================
    input  logic                      clk,
    input  logic                      rst_n
);

    // ============================================================
    // storage array (BRAM behavior depends on device/tool)
    // ============================================================
    logic [P_DATA_WIDTH-1: 0] mem [0:P_DEPTH-1];

    // ============================================================
    // write port timing: sampled on rising edge
    // ============================================================
    always_ff @(posedge clk) begin : ff_write_port
        if (~rst_n) begin
            // 复位时可以选择清零，也可以保持（取决于应用需求）
            // 这里不自动清零，由用户控制
        end else begin
            if (i_we) begin
                mem[i_addr] <= i_wdata;
            end
        end
    end

    // ============================================================
    // read port timing: synchronous read with one cycle delay
    // ============================================================
    always_ff @(posedge clk) begin : ff_read_port
        if (~rst_n) begin
            o_rdata <= '0;
        end else begin
            o_rdata <= mem[i_addr];
        end
    end

endmodule
