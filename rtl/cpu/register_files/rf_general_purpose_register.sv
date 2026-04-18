/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: General purpose register file.
*/

module rf_general_purpose_register (
    input  logic         write_enable,       // GPR 写使能
    input  logic [ 2: 0] write_index,       // 目标 GPR 编号（0–7）
    input  logic [31: 0] write_data,         // 写入数据（32 位）
    output logic [31: 0] read__8 [ 0:  7],   // 8 位读视图（零扩展到 32）
    output logic [31: 0] read_16 [ 0:  7],   // 16 位读视图（零扩展到 32）
    output logic [31: 0] read_32 [ 0:  7],   // 32 位读视图
    input  logic         reset_n,
    input  logic         clock
);

logic [31: 0] general_register [ 0:  7];  // 8 个 32 位通用寄存器存储

// 单写口：复位清零；使能时写入选中寄存器
always_ff @(posedge clock or negedge reset_n) begin : ff_basic_register
    if (~reset_n) begin  // 复位：GPR 全 0
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