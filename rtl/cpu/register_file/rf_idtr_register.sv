/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: IDTR register file.
*/

module rf_idtr_register (    input  logic         idtr_write_enable,       // IDTR 写使能
    input  logic [15: 0] idtr_write_data_limit, // 写入：IDT 限长
    input  logic [31: 0] idtr_write_data_base, // 写入：IDT 线性基址
    output logic [15: 0] idtr_limit, // 当前 IDT 限长
    output logic [31: 0] idtr_base, // 当前 IDT 基址
    input  logic         clk, // 时钟信号
    input  logic         rst_n // 复位信号
);

// SIDT 读出 / LIDT 写入的架构寄存器快照
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin  // 复位：基址与限长清零
        idtr_limit <= 16'b0;
        idtr_base <= 32'b0;
    end else if (idtr_write_enable) begin  // 加载 IDTR（通常来自 LIDT）
        idtr_limit <= idtr_write_data_limit;
        idtr_base <= idtr_write_data_base;
    end
end

endmodule
