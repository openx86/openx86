// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : prefetch_unit.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : prefetch_unit module
// ============================================================================

module prefetch_unit (
    // ------------------------------------------------------------------------
    // Instruction fetch bus interface（取指总线：地址/数据/就绪握手）
    // ------------------------------------------------------------------------
    output logic         o_code_valid,         // 取指请求有效
    input  logic          i_code_ready,        // 取指侧可接收完成
    output logic [31: 0] o_code_address,       // 物理取指地址
    input  logic [31: 0] i_code_data_read,     // 返回的指令字（32b）

    // ------------------------------------------------------------------------
    // MMU backend bus interface（分页遍历时访问页表的总线）
    // ------------------------------------------------------------------------
    output logic         o_mmu_bus_valid,      // MMU 总线请求有效
    input  logic          i_mmu_bus_ready,      // MMU 总线完成
    output logic [31: 0] o_mmu_bus_addr,       // 页目录/页表/物理访问地址
    input  logic [31: 0] i_mmu_bus_rdata,      // MMU 总线读数据

    // ------------------------------------------------------------------------
    // CPU execution context inputs（段/分页/特权等执行上下文）
    // ------------------------------------------------------------------------
    input  logic          i_protected_mode,     // 保护模式（CR0.PE）
    input  logic [ 5: 0][15: 0] i_segment_selector,   // 段选择子（CS 等）
    input  logic [ 5: 0][63: 0] i_segment_descriptor, // 段描述符缓存
    input  logic [ 1: 0]        i_current_privilege_level, // 当前 CPL
    input  logic                 i_paging_enable,        // 分页使能（CR0.PG）
    input  logic [31: 0]        i_page_directory_base,  // 页目录基址（CR3）
    input  logic                 i_IP_valid,             // EIP 有效（可发起新取指）

    // ------------------------------------------------------------------------
    // Decoded instruction stream outputs（输出到译码级的指令缓冲）
    // ------------------------------------------------------------------------
    output logic [15: 0][ 7: 0] o_instruction,          // 已组装的指令字节窗口
    output logic                 o_instruction_ready,    // 本窗口有效且已填满
    output logic                 o_segment_fault,        // 段保护/越界等 fault

    // ------------------------------------------------------------------------
    // Clock / reset（时钟与复位；EIP 为取指指针输入）
    // ------------------------------------------------------------------------
    input  logic [31: 0]        i_eip,                 // 指令指针（线性/有效地址侧由 MMU 前级使用）
    input  logic                 rst_n,                 // 复位信号
    input  logic                 clk                    // 时钟信号
);

    // 取指 + 段/分页翻译封装
    instruction_fetch u_if_instruction_fetch (
        .o_code_valid              (o_code_valid),
        .i_code_ready              (i_code_ready),
        .o_code_address            (o_code_address),
        .i_code_data_read          (i_code_data_read),
        .o_mmu_bus_valid           (o_mmu_bus_valid),
        .i_mmu_bus_ready           (i_mmu_bus_ready),
        .o_mmu_bus_addr            (o_mmu_bus_addr),
        .i_mmu_bus_rdata           (i_mmu_bus_rdata),
        .i_protected_mode          (i_protected_mode),
        .i_segment_selector        (i_segment_selector),
        .i_segment_descriptor      (i_segment_descriptor),
        .i_current_privilege_level (i_current_privilege_level),
        .i_paging_enable           (i_paging_enable),
        .i_page_directory_base     (i_page_directory_base),
        .i_IP_valid                (i_IP_valid),
        .o_instruction             (o_instruction),
        .o_instruction_ready       (o_instruction_ready),
        .o_segment_fault           (o_segment_fault),
        .i_eip                     (i_eip),
        .clk                       (clk),
        .rst_n                     (rst_n)
    );

endmodule
