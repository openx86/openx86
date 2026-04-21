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
// - 写：`we` 为 1 时在 posedge clk 将 `wdata` 写入 `waddr`
// - 读：`re` 为 1 时在 posedge clk 将 `raddr` 对应数据输出到 `rdata`
// - 复位：清零 `rdata`（不清 RAM 内容）
//
// 适用场景：小容量寄存/缓存/测试用存储模型。对综合成 block RAM 的行为，
// 取决于综合器/器件推断规则与端口时序写法。
// ============================================================================

module simple_dual_port_ram #(
    parameter int P_DATA_WIDTH = 8,    // 数据位宽
    parameter int P_ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int P_DEPTH      = 1 << P_ADDR_WIDTH  // 显式深度参数（可选）
) (
    // 写端口
    input  logic                  we,     // 写使能：高时本拍写入 waddr
    input  logic [P_ADDR_WIDTH-1: 0] waddr, // 写地址
    input  logic [P_DATA_WIDTH-1: 0] wdata, // 写数据
    // 读端口
    input  logic                  re,     // 读使能：高时下一拍更新 rdata（与写口同相）
    input  logic [P_ADDR_WIDTH-1: 0] raddr, // 读地址
    output logic [P_DATA_WIDTH-1: 0] rdata, // 读数据输出（re=0 时本实现仍保持上一值路径见代码）
    // 时钟与复位（放在末尾）
    input  logic                  clk,    // 单时钟
    input  logic                  rst_n   // 低有效：清零 rdata
);

    // 单存储体：一写一读端口分离
    logic [P_DATA_WIDTH-1: 0] mem [0:P_DEPTH-1];

    // 写口：同步写 waddr；复位不刷 memory
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            // 可选：清零或保持
        end else begin
            if (we) begin
                mem[waddr] <= wdata;
            end
        end
    end

    // 读口：re 高时读出 raddr；复位清零 rdata
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            rdata <= '0;
        end else begin
            if (re) begin
                rdata <= mem[raddr];
            end
        end
    end

endmodule
