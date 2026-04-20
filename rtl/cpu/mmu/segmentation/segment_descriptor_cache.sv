/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements segment_descriptor_cache.
*/
/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: segment_descriptor_cache
create at: 2022-01-27 12:56:29
description: segment_descriptor_cache
*/

`include "openx86_defs.h.sv"

module segment_descriptor_cache (    input  logic         protect_enable,       // 1=保护模式：走描述符译码
    input  logic [15: 0] segment_selector, // 输入信号
    input  logic [63: 0] segment_descriptor, // 输入信号
    input  logic         is_code_segment, // 实模式简化路径：是否代码语义
    input  logic [15: 0] write_data, // 输入信号
    input  logic         write_enable, // 输入信号
    output logic         read_data, // 输出信号
    output logic [31: 0] base, // 输出信号
    output logic [31: 0] limit, // 输出信号
    output logic [ 1: 0] present, // 输出信号
    output logic         privilege_level, // 输出信号
    output logic         accessed, // 输出信号
    output logic         granularity, // 输出信号
    output logic         expansion_direction, // 输出信号
    output logic         readable, // 输出信号
    output logic         writeable, // 输出信号
    output logic         executable, // 输出信号
    output logic         stack_size, // 输出信号
    output logic         conforming_privilege // 输出信号
);

// 子译码器输出（保护模式）
logic [31: 0] dec_base;
logic [19: 0] dec_limit;
logic        dec_present;
logic [ 1: 0] dec_privilege_level;
logic        dec_available_field;
logic        dec_segment_type;
logic        dec_granularity;
logic        dec_default_operation_size;
logic        dec_executable;
logic        dec_data_expansion_direction;
logic        dec_data_writeable;
logic        dec_code_conforming;
logic        dec_code_readable;
logic        dec_accessed;

segment_descriptor_decode u_segment_descriptor_decode (
    .o_base                                     ( dec_base ),
    .o_limit                                    ( dec_limit ),
    .o_date_or_code_present                     ( dec_present ),
    .o_date_or_code_privilege_level             ( dec_privilege_level ),
    .o_available_field                          ( dec_available_field ),
    .o_segment_type                             ( dec_segment_type ),
    .o_date_or_code_granularity                 ( dec_granularity ),
    .o_date_or_code_default_operation_size      ( dec_default_operation_size ),
    .o_date_or_code_executable                  ( dec_executable ),
    .o_data_expansion_direction                 ( dec_data_expansion_direction ),
    .o_data_writeable                           ( dec_data_writeable ),
    .o_code_conforming                          ( dec_code_conforming ),
    .o_code_readable                            ( dec_code_readable ),
    .o_date_or_code_accessed                    ( dec_accessed ),
    .i_descriptor                               ( segment_descriptor )
);

// 保护/实模式两套属性展开：实模式用段寄存器左移拼“基址”，limit 固定 64K
always_comb begin
    if (protect_enable) begin
        base                 = dec_base;
        limit                = { 12'h0, dec_limit };
        present              = { 1'b0, dec_present };
        privilege_level      = dec_privilege_level[0];
        accessed             = dec_accessed;
        granularity          = dec_granularity;
        expansion_direction  = dec_data_expansion_direction;
        readable             = dec_code_readable;
        writeable            = dec_data_writeable;
        executable           = dec_executable;
        stack_size           = dec_default_operation_size;
        conforming_privilege = dec_code_conforming;
    end else begin
        base                 = { 16'b0, segment_selector, 4'b0 };
        limit                = 32'h0000_ffff;
        present              = 2'b01;
        privilege_level      = 1'b0;
        accessed             = 1'b1;
        granularity          = `granularity_byte;
        expansion_direction  = `data_expansion_direction_up;
        readable             = 1'b1;
        writeable            = 1'b1;
        executable           = is_code_segment;
        stack_size           = `default_operation_size_16;
        conforming_privilege = 1'b0;
    end
end

assign read_data = 1'b0;

endmodule
