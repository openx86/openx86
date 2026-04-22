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
//  File        : dual_port_rom.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : dual_port_rom module
// ============================================================================

module dual_port_rom #(
    parameter int P_DATA_WIDTH = 8,    // 数据位宽
    parameter int P_ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int P_DEPTH      = 1 << P_ADDR_WIDTH  // 显式深度参数（可选）
) (
    // =========================
    // read port A
    // =========================
    input  logic [P_ADDR_WIDTH - 1: 0] i_addra,
    output logic [P_DATA_WIDTH - 1: 0] o_rdataa,

    // =========================
    // read port B
    // =========================
    input  logic [P_ADDR_WIDTH - 1: 0] i_addrb,
    output logic [P_DATA_WIDTH - 1: 0] o_rdatab,

    // =========================
    // clock and reset
    // =========================
    input  logic                      clk,
    input  logic                      rst_n
);

    // ============================================================
    // dual-port shared ROM body (initialized externally)
    // ============================================================
    logic [P_DATA_WIDTH-1: 0] rom [0:P_DEPTH-1];

    // ============================================================
    // port A synchronous read
    // ============================================================
    always_ff @(posedge clk) begin : ff_port_a_read
        if (~rst_n) begin
            o_rdataa <= '0;
        end else begin
            o_rdataa <= rom[i_addra];
        end
    end

    // ============================================================
    // port B synchronous read
    // ============================================================
    always_ff @(posedge clk) begin : ff_port_b_read
        if (~rst_n) begin
            o_rdatab <= '0;
        end else begin
            o_rdatab <= rom[i_addrb];
        end
    end

endmodule
