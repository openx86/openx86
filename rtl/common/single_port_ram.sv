/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements single_port_ram.
*/
// ============================================================================
// single_port_ram
// ----------------------------------------------------------------------------
// 单端口 RAM（读写共用同一地址端口）。
//
// - 写：`we` 为 1 时在 posedge clock 写入 `addr`
// - 读：在 posedge clock 读出 `addr` 对应数据到 `rdata`（同步读）
//
// 注意：
// - 读写同地址同周期的行为（write-first/read-first/no-change）依赖综合器推断；
//   如需明确行为，建议在工程层使用器件 IP（如 Quartus RAM IP）。
// - reset 只影响输出/控制，不主动清零存储阵列（更贴近真实 BRAM 行为）。
// ============================================================================

module single_port_ram #(
    parameter int DATA_WIDTH = 8,    // 数据位宽
    parameter int ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int DEPTH      = 1 << ADDR_WIDTH  // 显式深度参数（可选）
) (
    // 读写端口
    input logic                   we,    // 写使能    input logic [ADDR_WIDTH-1:0]  addr,  // 地址    input logic [DATA_WIDTH-1:0]  wdata, // 写数据    output logic [DATA_WIDTH-1:0] rdata, // 读数据
    
    // 时钟和复位
    input logic                   clock,    input logic                   reset_n);

    // 存储器数组
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // 写操作（同步写）
    always_ff @(posedge clock) begin
        if (~reset_n) begin
            // 复位时可以选择清零，也可以保持（取决于应用需求）
            // 这里不自动清零，由用户控制
        end else begin
            if (we) begin
                mem[addr] <= wdata;
            end
        end
    end

    // 读操作（同步读，在时钟上升沿后输出）
    always_ff @(posedge clock) begin
        if (~reset_n) begin
            rdata <= '0;
        end else begin
            rdata <= mem[addr];
        end
    end

endmodule
