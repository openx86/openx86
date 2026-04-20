/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Test register file.
*/

module rf_test_register (    input  logic         write_enable,       // 写使能
    input  logic [ 2: 0] write_index, // 目标寄存器索引（0–7）
    input  logic [31: 0] write_data, // 写入数据
    output logic [ 7: 0][31: 0] TR, // 测试寄存器组 TR0–TR7
    input  logic         clk, // 时钟信号
    input  logic         rst_n // 复位信号
);

// 异步复位：清零全部 TR；使能时按索引写入
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin  // 复位：全部清零
        TR[0] <= 32'b0;
        TR[1] <= 32'b0;
        TR[2] <= 32'b0;
        TR[3] <= 32'b0;
        TR[4] <= 32'b0;
        TR[5] <= 32'b0;
        TR[6] <= 32'b0;
        TR[7] <= 32'b0;
    end else if (write_enable) begin  // 单口写：更新选中 TR
        TR[write_index] <= write_data;
    end
end

endmodule
