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
//  File        : true_dual_port_ram.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : true_dual_port_ram module
// ============================================================================

module true_dual_port_ram #(
    parameter int P_DATA_WIDTH = 8,    // 数据位宽
    parameter int P_ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int P_DEPTH      = 1 << P_ADDR_WIDTH  // 显式深度参数（可选）
) (
    // =========================
    // port A (typically for CPU access)
    // =========================
    input  logic                      i_wea,
    input  logic [P_ADDR_WIDTH - 1: 0] i_addra,
    input  logic [P_DATA_WIDTH - 1: 0] i_wdataa,
    output logic [P_DATA_WIDTH - 1: 0] o_rdataa,

    // =========================
    // port B (typically for VGA access)
    // =========================
    input  logic                      i_web,
    input  logic [P_ADDR_WIDTH - 1: 0] i_addrb,
    input  logic [P_DATA_WIDTH - 1: 0] i_wdatab,
    output logic [P_DATA_WIDTH - 1: 0] o_rdatab,

    // =========================
    // clock and reset
    // =========================
    input  logic                      clk,
    input  logic                      rst_n
);

    // ============================================================
    // shared memory bank (dual-port conflict behavior depends on device)
    // ============================================================
    logic [P_DATA_WIDTH-1: 0] mem [0:P_DEPTH-1];

    // ============================================================
    // port A write: synchronous write to addra
    // ============================================================
    always_ff @(posedge clk) begin : ff_port_a_write
        if (~rst_n) begin
            // 复位时可以选择清零，也可以保持（取决于应用需求）
        end else begin
            if (i_wea) begin
                mem[i_addra] <= i_wdataa;
            end
        end
    end

    // ============================================================
    // port A read: one-cycle synchronous read from addra
    // ============================================================
    always_ff @(posedge clk) begin : ff_port_a_read
        if (~rst_n) begin
            o_rdataa <= '0;
        end else begin
            o_rdataa <= mem[i_addra];
        end
    end

    // ============================================================
    // port B write: synchronous write to addrb
    // ============================================================
    always_ff @(posedge clk) begin : ff_port_b_write
        if (~rst_n) begin
            // 复位时可以选择清零，也可以保持
        end else begin
            if (i_web) begin
                mem[i_addrb] <= i_wdatab;
            end
        end
    end

    // ============================================================
    // port B read: one-cycle synchronous read from addrb
    // ============================================================
    always_ff @(posedge clk) begin : ff_port_b_read
        if (~rst_n) begin
            o_rdatab <= '0;
        end else begin
            o_rdatab <= mem[i_addrb];
        end
    end

endmodule
