/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements w686_cpu.
*/
// ============================================================================
// w686_cpu
// ----------------------------------------------------------------------------
// CPU 顶层封装：对外提供统一的简化 SoC bus 接口（valid/ready）。
//
// 说明：
// - 该模块目前实例化 `w686_core` 作为具体实现。
// - 历史命名 `w80386_*`/`w486_*` 已统一更名为 `w686_*`。
// ============================================================================
module w686_cpu (
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
    // inout  logic [31:  0] data,
    // output logic [31:  2] address,
    // output logic [ 3:0] byte_enables_n,
    // output logic        write_read_n,
    // output logic        data_control_n,
    // output logic        memory_io_n,
    // output logic        bus_lock_n,
    // output logic        address_status_n,
    output logic        bus_vaild,
    input  logic        bus_ready,
    input  logic        bus_busy,
    output logic        bus_write_enable,
    output logic        bus_io_access,
    output logic [31:  0] bus_address,
    input  logic [31:  0] bus_read_data,
    output logic [31:  0] bus_write_data,
    input  logic        reset_n,
    input  logic        clock);

logic        mmu_vaild;
logic        mmu_ready;
logic [31:  0] mmu_address;
logic [31:  0] mmu_data_read;

logic        code_vaild;
logic        code_ready;
logic [31:  0] code_address;
logic [31:  0] code_data_read;

logic        data_vaild;
logic        data_ready;
logic        data_write_enable;
logic        data_io_access;
logic [31:  0] data_address;
logic [31:  0] data_data_read;
logic [31:  0] data_data_write;

w686_core core_0 (
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
    .clock              ( clock ),
    .reset_n              ( reset_n )
);

stage_4_mem_bus_interface_unit biu_0 (
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
    .i_bus_ready        ( bus_ready & ~bus_busy ),
    .i_bus_busy         ( bus_busy ),
    .o_bus_write_enable ( bus_write_enable ),
    .o_bus_io_access    ( bus_io_access ),
    .o_bus_address      ( bus_address ),
    .i_bus_data_read    ( bus_read_data ),
    .o_bus_data_write   ( bus_write_data ),
    .clock            ( clock ),
    .reset_n            ( reset_n )
);

// TODO: shared cache
// TODO: system agent
// TODO: SDRAM controller

endmodule
