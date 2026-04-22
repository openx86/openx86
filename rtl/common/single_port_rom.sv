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
    // 读端口
    input  logic [P_ADDR_WIDTH - 1: 0] i_addr,     // 读地址（深度 2^ADDR_WIDTH，内容需外部初始化）
    output logic [P_DATA_WIDTH - 1: 0] o_rdata,    // 同步读数据输出

    // 时钟和复位
    input  logic                      clk,        // 读数据在此时钟沿更新
    input  logic                      rst_n       // 低有效：复位时 rdata 清零，ROM 内容不变
);

    // 只读内容阵列（仿真/综合由外部或 IP 装载；TB 可层次化写入）
    /* verilator lint_off UNDRIVEN */
    logic [P_DATA_WIDTH-1: 0] rom [0:P_DEPTH-1];
    /* verilator lint_on UNDRIVEN */

    integer rom_init_i;
    initial begin
        for (rom_init_i = 0; rom_init_i < P_DEPTH; rom_init_i = rom_init_i + 1)
            rom[rom_init_i] = '0;
    end

    // 同步读：无效地址仍组合取数，由上层保证；复位清零输出
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            o_rdata <= '0;
        end else begin
            o_rdata <= rom[i_addr];
        end
    end

endmodule
