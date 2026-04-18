/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Instruction pointer register file.
*/

module rf_instruction_pointer_register (
    input  logic         write_enable,   // 写使能（更新 EIP）
    input  logic [31: 0] write_data,      // 完整 32 位指令指针写入值
    output logic [15: 0] IP,             // 16 位可见 IP（EIP 低 16）
    output logic [31: 0] EIP,            // 32 位 EIP
    input  logic         clk,
    input  logic         rst_n
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
