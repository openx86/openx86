/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Control register file.
*/

module rf_control_register (
    input  logic         write_enable,       // CR 写使能
    input  logic [ 2: 0] write_index,       // CR 编号（0–7）
    input  logic [31: 0] write_data,         // 写入数据
    output logic [31: 0] CR [ 0:  7],       // 控制寄存器 CR0–CR7
    output logic         PE,                 // CR0.0 保护模式使能
    output logic         MP,                 // CR0.1 监视协处理器
    output logic         EM,                 // CR0.2 仿真
    output logic         TS,                 // CR0.3 任务切换
    output logic         R,                  // CR0[4]
    output logic         PG,                 // CR0.31 分页使能
    output logic [19: 0] page_directory_base, // CR3 页目录物理基址（高 20 位域）
    input  logic         clock,
    input  logic         reset_n
);

// 复位清零全部 CR；使能时按索引写入（MOV CR 等）
always_ff @(posedge clock or negedge reset_n) begin : ff_control_register
    if (~reset_n) begin  // 复位：所有控制寄存器清零
        CR[0] <= 32'b0;
        CR[1] <= 32'b0;
        CR[2] <= 32'b0;
        CR[3] <= 32'b0;
        CR[4] <= 32'b0;
        CR[5] <= 32'b0;
        CR[6] <= 32'b0;
        CR[7] <= 32'b0;
    end else if (write_enable) begin  // 更新指定 CR
        CR[write_index] <= write_data;
    end
end

// CR0 常用位与 CR3 页目录基址域（供 MMU/模式检测快速采样）
assign PE = CR[0][0];
assign MP = CR[0][1];
assign EM = CR[0][2];
assign TS = CR[0][3];
assign R  = CR[0][4];
assign PG = CR[0][31];

assign page_directory_base = CR[3][31: 12];

endmodule
