/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Debug register file.
*/

module rf_x86_debug (
    input  logic         write_enable,       // 写使能
    input  logic [ 2: 0] write_index, // DR 索引（0–7）
    input  logic [31: 0] write_data, // 写入数据
    output logic [ 7: 0][31: 0] DR, // 调试寄存器 DR0–DR7
    input  logic         clk, // 时钟信号
    input  logic         rst_n // 复位信号
);

// 异步复位清零；使能时写入选中 DR（断点地址/调试控制等由上层语义决定）
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin  // 复位：全部 DR 清零
        DR[0] <= 32'b0;
        DR[1] <= 32'b0;
        DR[2] <= 32'b0;
        DR[3] <= 32'b0;
        DR[4] <= 32'b0;
        DR[5] <= 32'b0;
        DR[6] <= 32'b0;
        DR[7] <= 32'b0;
    end else if (write_enable) begin  // 单口写 DR
        DR[write_index] <= write_data;
    end
end

endmodule
