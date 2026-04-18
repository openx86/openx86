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
    input  logic                  we,    // 写使能：高电平在时钟沿将 wdata 写入 addr
    input  logic [ADDR_WIDTH-1: 0] addr,  // 读写共用地址（半字/字节粒度由 DATA_WIDTH 决定）
    input  logic [DATA_WIDTH-1: 0] wdata, // 待写入数据
    output logic [DATA_WIDTH-1: 0] rdata, // 同步读输出（一拍延迟，见 always_ff 读口）

    
    // 时钟和复位
    input  logic                  clock,   // 单时钟域：写与读均在此沿更新
    input  logic                  reset_n  // 异步低有效复位：清零 rdata；阵列内容不强制清零
);

    // 存储阵列（综合为 BRAM 时行为由器件/工具决定）
    logic [DATA_WIDTH-1: 0] mem [0:DEPTH-1];

    // 写口时序：时钟上升沿采样；复位分支占位，有效时写入当前地址
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

    // 读口时序：同步读一拍；复位将读数据口置 0
    always_ff @(posedge clock) begin
        if (~reset_n) begin
            rdata <= '0;
        end else begin
            rdata <= mem[addr];
        end
    end

endmodule
