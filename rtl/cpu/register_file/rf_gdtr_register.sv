/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: GDTR register file.
*/

module rf_gdtr_register (    input  logic         gdtr_write_enable,       // GDTR 写使能
    input  logic [15: 0] gdtr_write_data_limit, // 写入：GDT 限长
    input  logic [31: 0] gdtr_write_data_base, // 写入：GDT 线性基址
    output logic [15: 0] gdtr_limit, // 当前 GDT 限长
    output logic [31: 0] gdtr_base, // 当前 GDT 基址
    input  logic         clk, // 时钟信号
    input  logic         rst_n // 复位信号
);

// SGDT 读出 / LGDT 写入的架构寄存器快照
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin  // 复位：基址与限长清零
        gdtr_limit <= 16'b0;
        gdtr_base <= 32'b0;
    end else if (gdtr_write_enable) begin  // 加载 GDTR（通常来自 LGDT）
        gdtr_limit <= gdtr_write_data_limit;
        gdtr_base <= gdtr_write_data_base;
    end
end

endmodule
