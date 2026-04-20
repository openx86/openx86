/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Segment register file.
*/

module register_file_rf_segment_register (
    input  logic         write_enable,       // 写使能
    input  logic [ 2: 0] write_index,       // 段寄存器索引（CS/SS/…）
    input  logic [15: 0] write_selector,   // 段选择子（可见部分）
    input  logic [63: 0] write_descriptor,   // 段描述符缓存（隐藏寄存器）
    output logic [ 5: 0][15: 0] segment_selector, // 各段选择子输出
    output logic [ 5: 0][63: 0] descriptor_cache, // 各段描述符缓存输出
    input  logic         clk,
    input  logic         rst_n
);

// 选择子寄存器：复位清零；使能时与描述符同步更新索引对应项
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin  // 复位：全部选择子清零
        segment_selector[0] <= 16'b0;
        segment_selector[1] <= 16'b0;
        segment_selector[2] <= 16'b0;
        segment_selector[3] <= 16'b0;
        segment_selector[4] <= 16'b0;
        segment_selector[5] <= 16'b0;
    end else if (write_enable) begin  // 写入可见段选择子
        segment_selector[write_index] <= write_selector;
    end
end

// 描述符缓存：与选择子同索引配对更新
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin  // 复位：描述符缓存清零
        descriptor_cache[0] <= 64'b0;
        descriptor_cache[1] <= 64'b0;
        descriptor_cache[2] <= 64'b0;
        descriptor_cache[3] <= 64'b0;
        descriptor_cache[4] <= 64'b0;
        descriptor_cache[5] <= 64'b0;
    end else if (write_enable) begin  // 写入隐藏描述符字段
        descriptor_cache[write_index] <= write_descriptor;
    end
end

endmodule
