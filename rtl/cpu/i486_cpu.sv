/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements i486_cpu.
*/
// ============================================================================
// i486_cpu
// ----------------------------------------------------------------------------
// CPU 顶层封装：对外提供统一的简化 SoC bus 接口（valid/ready）。
//
// 说明：
// - 实例化 `i486_cpu_core` 作为 CPU 核实现，并在核外封装 `bus_interface_unit`。
// ============================================================================
module i486_cpu (
    // 以下为历史 80386 风格总线信号（保留注释，未接线）
    // input  logic        next_address_n,
    // input  logic        bus_ready_n,
    // input  logic        bus_size_16_n,
    // input  logic        bus_hold_request,
    // output logic        bus_hold_acknowledge,
    // input  logic        busy_n,
    // input  logic        error_n,
    // input  logic        precessor_extension_request,
    // input  logic        interrupt_request,
    // input  logic        non_maskable_interrupt_request,
    // inout  logic [31: 0] data,
    // output logic [31:  2] address,
    // output logic [ 3: 0] byte_enables_n,
    // output logic        write_read_n,
    // output logic        data_control_n,
    // output logic        memory_io_n,
    // output logic        bus_lock_n,
    // output logic        address_status_n,
    output logic         bus_vaild,         // 对外总线事务请求有效（拼写沿用 legacy）
    input  logic          bus_ready,         // 从设备就绪（完成）
    input  logic          bus_busy,          // 总线忙（与 ready 相与后送入 BIU）
    output logic         bus_write_enable,  // 写/读指示
    output logic         bus_io_access,      // 存储器或 I/O 映射访问
    output logic [31: 0] bus_address,        // 地址
    input  logic [31: 0]  bus_read_data,     // 读数据
    output logic [31: 0] bus_write_data,     // 写数据
    input  logic          rst_n,
    input  logic          clk
);

// core → BIU：MMU（页表遍历）端口
logic        mmu_vaild;
logic        mmu_ready;
logic [31: 0] mmu_address;
logic [31: 0] mmu_data_read;

// core → BIU：指令取指端口
logic        code_vaild;
logic        code_ready;
logic [31: 0] code_address;
logic [31: 0] code_data_read;

// core → BIU：数据 load/store 端口
logic        data_vaild;
logic        data_ready;
logic        data_write_enable;
logic        data_io_access;
logic [31: 0] data_address;
logic [31: 0] data_data_read;
logic [31: 0] data_data_write;

// 具体 CPU 微架构实现（MMU/取指/数据三主端口出核）
i486_cpu_core cpu_core_0 (
    .o_mmu_vaild        ( mmu_vaild ),
    .i_mmu_ready        ( mmu_ready ),
    .o_mmu_address      ( mmu_address ),
    .i_mmu_data_read    ( mmu_data_read ),
    .o_code_vaild       ( code_vaild ),
    .i_code_ready       ( code_ready ),
    .o_code_address     ( code_address ),
    .i_code_data_read   ( code_data_read ),
    .o_data_vaild       ( data_vaild ),
    .i_data_ready       ( data_ready ),
    .o_data_write_enable( data_write_enable ),
    .o_data_io_access   ( data_io_access ),
    .o_data_address     ( data_address ),
    .i_data_data_read   ( data_data_read ),
    .o_data_data_write  ( data_data_write ),
    .clk              ( clk ),
    .rst_n              ( rst_n )
);

// 总线接口单元：仲裁并折叠到单一 valid/ready SoC 总线
bus_interface_unit biu_0 (
    .i_mmu_vaild        ( mmu_vaild ),
    .o_mmu_ready        ( mmu_ready ),
    .i_mmu_address      ( mmu_address ),
    .o_mmu_data_read    ( mmu_data_read ),
    .i_code_vaild       ( code_vaild ),
    .o_code_ready       ( code_ready ),
    .i_code_address     ( code_address ),
    .o_code_data_read   ( code_data_read ),
    .i_data_vaild       ( data_vaild ),
    .o_data_ready       ( data_ready ),
    .i_data_write_enable( data_write_enable ),
    .i_data_io_access   ( data_io_access ),
    .i_data_address     ( data_address ),
    .o_data_data_read   ( data_data_read ),
    .i_data_data_write  ( data_data_write ),
    .o_bus_vaild        ( bus_vaild ),
    .i_bus_ready        ( bus_ready & ~bus_busy ),  // 忙时不视为完成
    .i_bus_busy         ( bus_busy ),
    .o_bus_write_enable ( bus_write_enable ),
    .o_bus_io_access    ( bus_io_access ),
    .o_bus_address      ( bus_address ),
    .i_bus_data_read    ( bus_read_data ),
    .o_bus_data_write   ( bus_write_data ),
    .clk            ( clk ),
    .rst_n            ( rst_n )
);

// TODO: shared cache
// TODO: system agent
// TODO: SDRAM controller

endmodule
