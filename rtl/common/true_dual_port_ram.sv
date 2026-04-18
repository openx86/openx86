/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements true_dual_port_ram.
*/
// ============================================================================
// true_dual_port_ram
// ----------------------------------------------------------------------------
// 真双口 RAM（2x read/write port），常用于“CPU 写入 + VGA/外设并行读取”等场景。
//
// - 端口 A/B 均支持同步写、同步读（posedge clk）。
// - 复位：清零读数据输出（不清 RAM 内容）。
//
// 冲突说明：
// - 双口同周期访问同地址（尤其是同时写）时的最终内容与读出的数据，
//   依赖综合器/器件 RAM primitive 的定义；若系统依赖确定行为，建议采用
//   厂商 IP 并显式配置 read-during-write 模式。
// ============================================================================

module true_dual_port_ram #(
    parameter int DATA_WIDTH = 8,    // 数据位宽
    parameter int ADDR_WIDTH = 10,   // 地址位宽（深度 = 2^ADDR_WIDTH）
    parameter int DEPTH      = 1 << ADDR_WIDTH  // 显式深度参数（可选）
) (    
    // 端口A（通常用于CPU访问）
    input  logic                  wea,    // A 口写使能
    input  logic [ADDR_WIDTH-1: 0] addra,  // A 口地址（读/写共用）
    input  logic [DATA_WIDTH-1: 0] wdataa, // A 口写数据
    output logic [DATA_WIDTH-1: 0] rdataa, // A 口同步读输出

    
    // 端口B（通常用于VGA读取）
    input  logic                  web,    // B 口写使能；只读场景可常接 0
    input  logic [ADDR_WIDTH-1: 0] addrb,  // B 口地址
    input  logic [DATA_WIDTH-1: 0] wdatab, // B 口写数据
    output logic [DATA_WIDTH-1: 0] rdatab, // B 口同步读输出

    
    // 时钟和复位
    input  logic                   clk,   // 双口共享单时钟
    input  logic                   rst_n  // 低有效：清零两路读输出，不清阵列
);

    // 共享存储体（双口冲突行为依赖器件/综合）
    logic [DATA_WIDTH-1: 0] mem [0:DEPTH-1];

    // A 口写：同步写入 addra；复位不刷阵列
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            // 复位时可以选择清零，也可以保持（取决于应用需求）
        end else begin
            if (wea) begin
                mem[addra] <= wdataa;
            end
        end
    end

    // A 口读：一拍同步读 addra
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            rdataa <= '0;
        end else begin
            rdataa <= mem[addra];
        end
    end

    // B 口写：同步写入 addrb
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            // 复位时可以选择清零，也可以保持
        end else begin
            if (web) begin
                mem[addrb] <= wdatab;
            end
        end
    end

    // B 口读：一拍同步读 addrb
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            rdatab <= '0;
        end else begin
            rdatab <= mem[addrb];
        end
    end

endmodule
