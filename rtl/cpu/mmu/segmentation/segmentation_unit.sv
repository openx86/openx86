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
//  File        : segmentation_unit.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : segmentation_unit module
// ============================================================================

/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: segmentation_unit
create at: 2022-01-31 01:31:23
description: segmentation_unit
*/

module segmentation_unit #(
    parameter bit read_from_fetch = 1'b0
) (
    // ------------------------------------------------------------------------
    // Segmentation context inputs（段式地址：选择子 + 描述符 + 偏移）
    // ------------------------------------------------------------------------
    input  logic          i_protected_mode,            // CR0.PE
    input  logic [ 5: 0][15: 0] i_segment_selector,    // 段寄存器侧选择子
    input  logic [ 5: 0][63: 0] i_segment_descriptor,  // 描述符缓存（与选择子对应）
    input  logic [ 2: 0]        i_segment_index,         // 本次访问使用哪一段
    input  logic [ 1: 0]        i_current_privilege_level, // CPL
    input  logic [31: 0]        i_effective_address,     // 段内有效地址
    input  logic                 i_write_enable,          // 1=写，0=读/取指

    // ------------------------------------------------------------------------
    // Segmentation outputs（输出线性地址或 fault）
    // ------------------------------------------------------------------------
    output logic [31: 0]        o_linear_address,         // 送分页单元
    output logic                 o_segment_privilege_error, // 段检查失败聚合

    // ------------------------------------------------------------------------
    // Clock / reset
    // ------------------------------------------------------------------------
    input  logic                 clk,                     // 时钟信号
    input  logic                 rst_n                    // 复位信号
);

logic  [63: 0] segment_descriptor; // 当前段描述符（按 index 选取）

logic [31: 0] base;
logic [19: 0] limit;
logic        date_or_code_present;
logic [ 1: 0] date_or_code_privilege_level;
logic        available_field;
logic        segment_type;
logic        date_or_code_granularity;
logic        date_or_code_default_operation_size;
logic        date_or_code_executable;
logic        data_expansion_direction;
logic        data_writeable;
logic        code_conforming;
logic        code_readable;
logic        date_or_code_accessed;

segment_descriptor_decode u_segment_descriptor_decode (
    .o_base                                (base),
    .o_limit                               (limit),
    .o_date_or_code_present                (date_or_code_present),
    .o_date_or_code_privilege_level        (date_or_code_privilege_level),
    .o_available_field                     (available_field),
    .o_segment_type                        (segment_type),
    .o_date_or_code_granularity            (date_or_code_granularity),
    .o_date_or_code_default_operation_size (date_or_code_default_operation_size),
    .o_date_or_code_executable             (date_or_code_executable),
    .o_data_expansion_direction            (data_expansion_direction),
    .o_data_writeable                      (data_writeable),
    .o_code_conforming                     (code_conforming),
    .o_code_readable                       (code_readable),
    .o_date_or_code_accessed               (date_or_code_accessed),
    .i_descriptor                          (segment_descriptor)
);

logic is_index_CS; // 当前访问是否为 CS

logic is_data_segment; // 数据段

logic is_read;
logic is_write;

logic is_granularity_byte; // G=0：字节粒度 limit
logic is_granularity_page; // G=1：页粒度，limit 左移 12

// 越界检查：字节/页粒度下 offset 与 limit 关系（实现待与手册严格对齐）
logic exception_limit;

// 特权检查：此处用 CPL 与 DPL 比较（与 RPL 组合策略需结合上层装入路径）
logic exception_privilege_level;

logic exception_read;  // 代码段不可读且为读

logic exception_write; // 对 CS 写或数据段不可写

assign segment_descriptor      = i_segment_descriptor[i_segment_index];
assign is_index_CS            = (i_segment_index == 3'b001);
assign is_data_segment        = segment_type & ~date_or_code_executable;
assign is_read                 = ~i_write_enable;
assign is_write                = i_write_enable;
assign is_granularity_byte    = date_or_code_granularity;
assign is_granularity_page    = ~date_or_code_granularity;
logic [31: 0] limit_ext;
logic [31: 0] limit_page_shifted;
assign limit_ext              = {12'h0, limit};
assign limit_page_shifted     = limit_ext << 4;
assign exception_limit        = (is_granularity_byte & (i_effective_address >= limit_ext)) |
                                   (is_granularity_page & (i_effective_address >= limit_page_shifted));
assign exception_privilege_level = i_current_privilege_level >= date_or_code_privilege_level;
assign exception_read         = is_read & ~read_from_fetch & ~code_readable;
assign exception_write        = (is_write & is_index_CS) | (is_write & is_data_segment & ~data_writeable);

assign o_segment_privilege_error =
exception_limit |
exception_privilege_level |
exception_read |
exception_write |
1'b0;

// Linear address = segment base + offset (32-bit flat model)
assign o_linear_address = base + i_effective_address;

endmodule
