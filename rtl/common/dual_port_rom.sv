/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements dual_port_rom.
*/
// ============================================================================
// dual_port_rom
// ----------------------------------------------------------------------------
// 双端口只读存储器（2x read port），用于仿真/综合中的 ROM 建模。
//
// - **内容初始化**：不在本模块内装载；仿真由 testbench 层次化写入阵列，
//   上板请使用 ROM IP 或工程级 memory init。
// - **时序**：两路读口均为 **同步读**（posedge clock 更新输出）。
//
// Reset 行为：复位时把读数据输出清零（不影响 ROM 内容）。
// ============================================================================

module dual_port_rom #(
    parameter int DATA_WIDTH = 8,    // 数据位宽
    parameter int ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int DEPTH      = 1 << ADDR_WIDTH  // 显式深度参数（可选）
) (
    // 读端口A
    input logic [ADDR_WIDTH-1:0]  addra,  // 端口A地址    output logic [DATA_WIDTH-1:0] rdataa, // 端口A读数据
    // 读端口B
    input logic [ADDR_WIDTH-1:0]  addrb,  // 端口B地址    output logic [DATA_WIDTH-1:0] rdatab, // 端口B读数据
    // 时钟和复位
    input logic                   clock,    input logic                   reset_n);

    logic [DATA_WIDTH-1:0] rom [0:DEPTH-1];

    always_ff @(posedge clock) begin
        if (~reset_n) begin
            rdataa <= '0;
        end else begin
            rdataa <= rom[addra];
        end
    end

    always_ff @(posedge clock) begin
        if (~reset_n) begin
            rdatab <= '0;
        end else begin
            rdatab <= rom[addrb];
        end
    end

endmodule
