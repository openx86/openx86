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
//  File        : rf_x86_general_purpose.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : rf_x86_general_purpose module
// ============================================================================

module rf_x86_general_purpose (
    input  logic         write_enable,       // GPR 写使能
    input  logic [ 2: 0] write_index, // 目标 GPR 编号（0–7）
    input  logic [31: 0] write_data, // 写入数据（32 位）
    output logic [ 7: 0][31: 0] read__8, // 8 位读视图（零扩展到 32）
    output logic [ 7: 0][31: 0] read_16, // 16 位读视图（零扩展到 32）
    output logic [ 7: 0][31: 0] read_32, // 32 位读视图
    input  logic         rst_n, // 复位信号
    input  logic         clk // 时钟信号
);

logic [31: 0] general_register [ 0:  7];  // 8 个 32 位通用寄存器存储

// 单写口：复位清零；使能时写入选中寄存器
always_ff @(posedge clk or negedge rst_n) begin : ff_basic_register
    if (~rst_n) begin  // 复位：GPR 全 0
        for (int i = 0; i < 8; i++) begin
            general_register[i] <= 32'h0;
        end
    end else if (write_enable) begin  // 写回阶段更新一条 GPR
        general_register[write_index] <= write_data;
    end
end

// 组合读端口：按操作数宽度提供零扩展视图
always_comb begin
    for (int i = 0; i < 8; i++) begin
        read_32[i] = general_register[i];
        read_16[i] = {16'h0, general_register[i][15: 0]};
        read__8[i] = {24'h0, general_register[i][ 7: 0]};
    end
end

endmodule
