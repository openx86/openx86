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
//  File        : simple_dual_port_ram.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : simple_dual_port_ram module
// ============================================================================

module simple_dual_port_ram #(
    parameter int P_DATA_WIDTH = 8,    // 数据位宽
    parameter int P_ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int P_DEPTH      = 1 << P_ADDR_WIDTH  // 显式深度参数（可选）
) (
    // =========================
    // write port
    // =========================
    input  logic                      i_we,
    input  logic [P_ADDR_WIDTH - 1: 0] i_waddr,
    input  logic [P_DATA_WIDTH - 1: 0] i_wdata,

    // =========================
    // read port
    // =========================
    input  logic                      i_re,
    input  logic [P_ADDR_WIDTH - 1: 0] i_raddr,
    output logic [P_DATA_WIDTH - 1: 0] o_rdata,

    // =========================
    // clock and reset
    // =========================
    input  logic                      clk,
    input  logic                      rst_n
);

    // ============================================================
    // single memory bank with separate write/read ports
    // ============================================================
    logic [P_DATA_WIDTH-1: 0] mem [0:P_DEPTH-1];

    // ============================================================
    // write port: synchronous write to waddr
    // ============================================================
    always_ff @(posedge clk) begin : ff_write_port
        if (~rst_n) begin
            // 可选：清零或保持
        end else begin
            if (i_we) begin
                mem[i_waddr] <= i_wdata;
            end
        end
    end

    // ============================================================
    // read port: synchronous read from raddr
    // ============================================================
    always_ff @(posedge clk) begin : ff_read_port
        if (~rst_n) begin
            o_rdata <= '0;
        end else begin
            if (i_re) begin
                o_rdata <= mem[i_raddr];
            end
        end
    end

endmodule
