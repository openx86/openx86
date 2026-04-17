/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements single_port_rom.
*/
// ============================================================================
// single_port_rom
// ----------------------------------------------------------------------------
// 单端口 ROM（同步读），用于仿真/综合中的 ROM 建模。
//
// - **内容初始化**：不在本模块内装载；仿真时由 testbench 通过层次化引用
//   写入内部阵列，或使用厂商 ROM IP / 工程脚本做上板初始化。
// - **读时序**：posedge clock 更新 `rdata`（同步读）。
// - **复位**：将 `rdata` 清零（ROM 内容不变）。
// ============================================================================

module single_port_rom #(
    parameter int DATA_WIDTH = 8,    // 数据位宽
    parameter int ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int DEPTH      = 1 << ADDR_WIDTH  // 显式深度参数（可选）
) (
    // 读端口
    input  logic [ADDR_WIDTH-1:0]   addr,            // 地址
    output logic [DATA_WIDTH-1:0]   rdata,           // 读数据

    input  logic                    clock,
    input  logic                    reset
);

    logic [DATA_WIDTH-1:0] rom [0:DEPTH-1];

    always_ff @(posedge clock) begin
        if (reset) begin
            rdata <= '0;
        end else begin
            rdata <= rom[addr];
        end
    end

endmodule
