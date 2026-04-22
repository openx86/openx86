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
    // 端口A（通常用于CPU访问）
    input  logic                      i_wea,       // A 口写使能
    input  logic [P_ADDR_WIDTH - 1: 0] i_addra,     // A 口地址（读/写共用）
    input  logic [P_DATA_WIDTH - 1: 0] i_wdataa,    // A 口写数据
    output logic [P_DATA_WIDTH - 1: 0] o_rdataa,    // A 口同步读输出

    // 端口B（通常用于VGA读取）
    input  logic                      i_web,       // B 口写使能；只读场景可常接 0
    input  logic [P_ADDR_WIDTH - 1: 0] i_addrb,     // B 口地址
    input  logic [P_DATA_WIDTH - 1: 0] i_wdatab,    // B 口写数据
    output logic [P_DATA_WIDTH - 1: 0] o_rdatab,    // B 口同步读输出

    // 时钟和复位
    input  logic                      clk,         // 双口共享单时钟
    input  logic                      rst_n        // 低有效：清零两路读输出，不清阵列
);

    // 共享存储体（双口冲突行为依赖器件/综合）
    logic [P_DATA_WIDTH-1: 0] mem [0:P_DEPTH-1];

    // A 口写：同步写入 addra；复位不刷阵列
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            // 复位时可以选择清零，也可以保持（取决于应用需求）
        end else begin
            if (i_wea) begin
                mem[i_addra] <= i_wdataa;
            end
        end
    end

    // A 口读：一拍同步读 addra
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            o_rdataa <= '0;
        end else begin
            o_rdataa <= mem[i_addra];
        end
    end

    // B 口写：同步写入 addrb
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            // 复位时可以选择清零，也可以保持
        end else begin
            if (i_web) begin
                mem[i_addrb] <= i_wdatab;
            end
        end
    end

    // B 口读：一拍同步读 addrb
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            o_rdatab <= '0;
        end else begin
            o_rdatab <= mem[i_addrb];
        end
    end

endmodule
