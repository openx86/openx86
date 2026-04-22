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
//  File        : rf_x86_test.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : rf_x86_test module
// ============================================================================

module rf_x86_test (
    input  logic         write_enable,       // 写使能
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
