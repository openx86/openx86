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
    // 读端口A
    input  logic [P_ADDR_WIDTH - 1: 0] i_addra,  // A 口读地址
    output logic [P_DATA_WIDTH - 1: 0] o_rdataa, // A 口同步读数据

    // 读端口B
    input  logic [P_ADDR_WIDTH - 1: 0] i_addrb,  // B 口读地址
    output logic [P_DATA_WIDTH - 1: 0] o_rdatab, // B 口同步读数据

    // 时钟和复位
    input  logic                      clk,       // 两读口共享时钟
    input  logic                      rst_n      // 低有效：两路输出清零
);

    // 双读口共享 ROM 体（内容由外部初始化）
    logic [P_DATA_WIDTH-1: 0] rom [0:P_DEPTH-1];

    // A 口同步读
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            o_rdataa <= '0;
        end else begin
            o_rdataa <= rom[i_addra];
        end
    end

    // B 口同步读
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            o_rdatab <= '0;
        end else begin
            o_rdatab <= rom[i_addrb];
        end
    end

endmodule
