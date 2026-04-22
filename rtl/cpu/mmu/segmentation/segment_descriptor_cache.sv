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

module segment_descriptor_cache (
    input  logic         i_protect_enable,       // 1=保护模式：走描述符译码
    input  logic [15: 0] i_segment_selector,    // 输入信号
    input  logic [63: 0] i_segment_descriptor,  // 输入信号
    input  logic         i_is_code_segment,     // 实模式简化路径：是否代码语义
    input  logic [15: 0] i_write_data,          // 输入信号
    input  logic         i_write_enable,         // 输入信号
    output logic         o_read_data,            // 输出信号
    output logic [31: 0] o_base,                 // 输出信号
    output logic [31: 0] o_limit,                // 输出信号
    output logic [ 1: 0] o_present,              // 输出信号
    output logic         o_privilege_level,      // 输出信号
    output logic         o_accessed,             // 输出信号
    output logic         o_granularity,          // 输出信号
    output logic         o_expansion_direction,  // 输出信号
    output logic         o_readable,             // 输出信号
    output logic         o_writeable,            // 输出信号
    output logic         o_executable,           // 输出信号
    output logic         o_stack_size,           // 输出信号
    output logic         o_conforming_privilege   // 输出信号
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
    .o_base                                (dec_base),
    .o_limit                               (dec_limit),
    .o_date_or_code_present                (dec_present),
    .o_date_or_code_privilege_level        (dec_privilege_level),
    .o_available_field                     (dec_available_field),
    .o_segment_type                        (dec_segment_type),
    .o_date_or_code_granularity            (dec_granularity),
    .o_date_or_code_default_operation_size (dec_default_operation_size),
    .o_date_or_code_executable             (dec_executable),
    .o_data_expansion_direction            (dec_data_expansion_direction),
    .o_data_writeable                      (dec_data_writeable),
    .o_code_conforming                     (dec_code_conforming),
    .o_code_readable                       (dec_code_readable),
    .o_date_or_code_accessed               (dec_accessed),
    .i_descriptor                          (i_segment_descriptor)
);

// 保护/实模式两套属性展开：实模式用段寄存器左移拼“基址”，limit 固定 64K
always_comb begin
    if (i_protect_enable) begin
        o_base                 = dec_base;
        o_limit                = {12'h0, dec_limit};
        o_present              = {1'b0, dec_present};
        o_privilege_level      = dec_privilege_level[0];
        o_accessed             = dec_accessed;
        o_granularity          = dec_granularity;
        o_expansion_direction  = dec_data_expansion_direction;
        o_readable             = dec_code_readable;
        o_writeable            = dec_data_writeable;
        o_executable           = dec_executable;
        o_stack_size           = dec_default_operation_size;
        o_conforming_privilege = dec_code_conforming;
    end else begin
        o_base                 = {16'b0, i_segment_selector, 4'b0};
        o_limit                = 32'h0000_ffff;
        o_present              = 2'b01;
        o_privilege_level      = 1'b0;
        o_accessed             = 1'b1;
        o_granularity          = `granularity_byte;
        o_expansion_direction  = `data_expansion_direction_up;
        o_readable             = 1'b1;
        o_writeable            = 1'b1;
        o_executable           = i_is_code_segment;
        o_stack_size           = `default_operation_size_16;
        o_conforming_privilege = 1'b0;
    end
end

assign o_read_data = 1'b0;

endmodule
