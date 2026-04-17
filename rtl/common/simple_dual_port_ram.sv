/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements simple_dual_port_ram.
*/
// ============================================================================
// simple_dual_port_ram
// ----------------------------------------------------------------------------
// 简单双口 RAM（1x write + 1x read）。
//
// - 写：`we` 为 1 时在 posedge clock 将 `wdata` 写入 `waddr`
// - 读：`re` 为 1 时在 posedge clock 将 `raddr` 对应数据输出到 `rdata`
// - 复位：清零 `rdata`（不清 RAM 内容）
//
// 适用场景：小容量寄存/缓存/测试用存储模型。对综合成 block RAM 的行为，
// 取决于综合器/器件推断规则与端口时序写法。
// ============================================================================

module simple_dual_port_ram #(
    parameter int DATA_WIDTH = 8,    // 数据位宽
    parameter int ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int DEPTH      = 1 << ADDR_WIDTH  // 显式深度参数（可选）
) (
    // 写端口
    input  logic                    we,
    input  logic [ADDR_WIDTH-1:0]   waddr,
    input  logic [DATA_WIDTH-1:0]   wdata,

    // 读端口
    input  logic                    re,
    input  logic [ADDR_WIDTH-1:0]   raddr,
    output logic [DATA_WIDTH-1:0]   rdata,

    // 时钟与复位（放在末尾）
    input  logic                    clock,
    input  logic                    reset
);

    // 存储器数组
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // 写操作（同步写）
    always_ff @(posedge clock) begin
        if (reset) begin
            // 可选：清零或保持
        end else begin
            if (we) begin
                mem[waddr] <= wdata;
            end
        end
    end

    // 读操作（同步读，在时钟上升沿后输出）
    always_ff @(posedge clock) begin
        if (reset) begin
            rdata <= '0;
        end else begin
            if (re) begin
                rdata <= mem[raddr];
            end
        end
    end

endmodule
