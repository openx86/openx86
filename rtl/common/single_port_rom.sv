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
//  File        : single_port_rom.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : single_port_rom module
// ============================================================================

module single_port_rom #(
    parameter int P_DATA_WIDTH = 8,    // 数据位宽
    parameter int P_ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int P_DEPTH      = 1 << P_ADDR_WIDTH  // 显式深度参数（可选）
) (
    // =========================
    // read port
    // =========================
    input  logic [P_ADDR_WIDTH - 1: 0] i_addr,
    output logic [P_DATA_WIDTH - 1: 0] o_rdata,

    // =========================
    // clock and reset
    // =========================
    input  logic                      clk,
    input  logic                      rst_n
);

    // ============================================================
    // read-only content array (initialized externally or by IP)
    // ============================================================
    /* verilator lint_off UNDRIVEN */
    logic [P_DATA_WIDTH-1: 0] rom [0:P_DEPTH-1];
    /* verilator lint_on UNDRIVEN */

    integer rom_init_i;
    initial begin
        for (rom_init_i = 0; rom_init_i < P_DEPTH; rom_init_i = rom_init_i + 1)
            rom[rom_init_i] = '0;
    end

    // ============================================================
    // synchronous read: reset clears output
    // ============================================================
    always_ff @(posedge clk) begin : ff_synchronous_read
        if (~rst_n) begin
            o_rdata <= '0;
        end else begin
            o_rdata <= rom[i_addr];
        end
    end

endmodule
