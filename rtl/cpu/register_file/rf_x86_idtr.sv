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
//  File        : rf_x86_idtr.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : rf_x86_idtr module
// ============================================================================

module rf_x86_idtr (
    input  logic         idtr_write_enable,       // IDTR 写使能
    input  logic [15: 0] idtr_write_data_limit, // 写入：IDT 限长
    input  logic [31: 0] idtr_write_data_base, // 写入：IDT 线性基址
    output logic [15: 0] idtr_limit, // 当前 IDT 限长
    output logic [31: 0] idtr_base, // 当前 IDT 基址
    input  logic         clk, // 时钟信号
    input  logic         rst_n // 复位信号
);

// SIDT 读出 / LIDT 写入的架构寄存器快照
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin  // Reset: real-mode default IDTR base=0, limit=3FFh
        idtr_limit <= 16'h03FF;
        idtr_base  <= 32'h0;
    end else if (idtr_write_enable) begin  // 加载 IDTR（通常来自 LIDT）
        idtr_limit <= idtr_write_data_limit;
        idtr_base  <= idtr_write_data_base;
    end
end

endmodule
