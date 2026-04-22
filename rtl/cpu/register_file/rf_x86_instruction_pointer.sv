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
//  File        : rf_x86_instruction_pointer.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : rf_x86_instruction_pointer module
// ============================================================================

module rf_x86_instruction_pointer (
    input  logic         write_enable,   // 写使能（更新 EIP）
    input  logic [31: 0] write_data, // 完整 32 位指令指针写入值
    output logic [15: 0] IP, // 16 位可见 IP（EIP 低 16）
    output logic [31: 0] EIP, // 32 位 EIP
    input  logic         clk, // 时钟信号
    input  logic         rst_n // 复位信号
);

logic [31: 0] instruction_pointer;  // 内部统一存 32 位指令指针

// 复位到实模式入口附近典型初值；使能时整体更新
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin  // 复位：指向 0x0000FFF0
        instruction_pointer <= 32'h0000_FFF0;
    end else if (write_enable) begin  // 提交新的指令指针
        instruction_pointer <= write_data;
    end
end

// 拆分输出：16/32 位视图
assign IP  = instruction_pointer[15: 0];
assign EIP = instruction_pointer[31: 0];

endmodule
