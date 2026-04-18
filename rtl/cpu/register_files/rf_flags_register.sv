/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: EFLAGS/FLAGS register file.
*/

module rf_flags_register (
    input  logic         write_enable,    // EFLAGS 整体写使能
    input  logic [31: 0] write_data,       // 写入的 EFLAGS 位域
    output logic         CF,              // 进位
    output logic         PF,              // 奇偶
    output logic         AF,              // 辅助进位
    output logic         ZF,              // 零标志
    output logic         SF,              // 符号
    output logic         TF,              // 陷阱（单步）
    output logic         IF,              // 可屏蔽中断允许
    output logic         DF,              // 方向
    output logic         OF,              // 溢出
    output logic [ 1: 0] IOPL,            // I/O 特权级
    output logic         NT,              // 嵌套任务
    output logic         RF,              // 恢复标志
    output logic         VM,              // 虚拟 8086
    output logic [31: 0] EFLAGS,          // 完整 32 位标志
    output logic [15: 0] FLAGS,           // 低 16 位 FLAGS 视图
    input  logic         clk,
    input  logic         rst_n
);

logic [31: 0] flags_reg;  // 内部 EFLAGS 存储

// 复位清零；使能时整体装载（各条件码由译码/ALU 侧写回组装）
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin  // 复位：标志清零
        flags_reg <= 32'b0;
    end else if (write_enable) begin  // 写回 EFLAGS
        flags_reg <= write_data;
    end
end

// 总线/调试视图
assign EFLAGS = flags_reg[31: 0];
assign FLAGS  = flags_reg[15: 0];

// 常用条件码与系统位拆分（位号与 x86 EFLAGS 布局一致）
assign CF   = flags_reg[    0];
assign PF   = flags_reg[    2];
assign AF   = flags_reg[    4];
assign ZF   = flags_reg[    6];
assign SF   = flags_reg[    7];
assign TF   = flags_reg[    8];
assign IF   = flags_reg[    9];
assign DF   = flags_reg[   10];
assign OF   = flags_reg[   11];
assign IOPL = flags_reg[13: 12];
assign NT   = flags_reg[   14];
assign RF   = flags_reg[   16];
assign VM   = flags_reg[   17];

endmodule
