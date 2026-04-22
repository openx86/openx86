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
    // 写端口
    input  logic                      i_we,       // 写使能：高时本拍写入 waddr
    input  logic [P_ADDR_WIDTH - 1: 0] i_waddr,    // 写地址
    input  logic [P_DATA_WIDTH - 1: 0] i_wdata,    // 写数据
    // 读端口
    input  logic                      i_re,       // 读使能：高时下一拍更新 rdata（与写口同相）
    input  logic [P_ADDR_WIDTH - 1: 0] i_raddr,    // 读地址
    output logic [P_DATA_WIDTH - 1: 0] o_rdata,    // 读数据输出（re=0 时本实现仍保持上一值路径见代码）
    // 时钟与复位（放在末尾）
    input  logic                      clk,        // 单时钟
    input  logic                      rst_n       // 低有效：清零 rdata
);

    // 单存储体：一写一读端口分离
    logic [P_DATA_WIDTH-1: 0] mem [0:P_DEPTH-1];

    // 写口：同步写 waddr；复位不刷 memory
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            // 可选：清零或保持
        end else begin
            if (i_we) begin
                mem[i_waddr] <= i_wdata;
            end
        end
    end

    // 读口：re 高时读出 raddr；复位清零 rdata
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            o_rdata <= '0;
        end else begin
            if (i_re) begin
                o_rdata <= mem[i_raddr];
            end
        end
    end

endmodule
