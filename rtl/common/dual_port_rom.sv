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
// - **时序**：两路读口均为 **同步读**（posedge clk 更新输出）。
//
// Reset 行为：复位时把读数据输出清零（不影响 ROM 内容）。
// ============================================================================

module dual_port_rom #(
    parameter int DATA_WIDTH = 8,    // 数据位宽
    parameter int ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int DEPTH      = 1 << ADDR_WIDTH  // 显式深度参数（可选）
) (
    // 读端口A
    input  logic [ADDR_WIDTH-1: 0] addra, // A 口读地址
    output logic [DATA_WIDTH-1: 0] rdataa, // A 口同步读数据

    // 读端口B
    input  logic [ADDR_WIDTH-1: 0] addrb, // B 口读地址
    output logic [DATA_WIDTH-1: 0] rdatab, // B 口同步读数据

    // 时钟和复位
    input  logic                  clk, // 两读口共享时钟
    input  logic                  rst_n // 低有效：两路输出清零
);

    // 双读口共享 ROM 体（内容由外部初始化）
    logic [DATA_WIDTH-1: 0] rom [0:DEPTH-1];

    // A 口同步读
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            rdataa <= '0;
        end else begin
            rdataa <= rom[addra];
        end
    end

    // B 口同步读
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            rdatab <= '0;
        end else begin
            rdatab <= rom[addrb];
        end
    end

endmodule
