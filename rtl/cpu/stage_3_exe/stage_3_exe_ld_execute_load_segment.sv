/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_3_exe_ld_execute_load_segment.
*/
// ============================================================================
// execute_load_segment
// ----------------------------------------------------------------------------
// 处理将段选择子/描述符装载到段寄存器的执行路径（如 MOV Sreg, r/m16 等）。
//
// 端口提示（按当前实现命名）：
// - 输入提供：模式位 `protected_mode_enable`、目的段寄存器索引、源通用寄存器索引、
//   以及 8/16/32 位通用寄存器读数（由上层根据操作数宽度选择）。
// - 输出给寄存器文件：`write_enable/write_index/write_selector/write_descriptor`
// - `valid/ready`：本子模块与上层执行控制之间的握手
//
// 备注：段装载在保护模式下需要做权限检查与描述符解析；若当前实现为 bring-up，
// 可能只覆盖最小可运行路径，未实现全部异常语义。
// ============================================================================

module stage_3_exe_ld_execute_load_segment (
    input  logic          protected_mode_enable,  // 1=保护模式
    input  logic [15: 0] index_segment_register,  // 目标段寄存器索引
    input  logic [15: 0] index_general_register,  // 源通用寄存器索引
    input  logic [ 7: 0]   greg__8,  // 8 位源操作数
    input  logic [15: 0]  greg_16,  // 16 位源操作数（选择子）
    input  logic [31: 0]  greg_32,  // 32 位源操作数
    output logic [15: 0] write_enable,  // 段寄存器写使能掩码
    output logic [15: 0] write_index,  // 写回段寄存器索引
    output logic [15: 0] write_selector,  // 写回选择子
    output logic [63: 0] write_descriptor,  // 写回 64 位描述符缓存
    input  logic          valid,  // 上游握手：有效
    output logic         ready  // 本子模块就绪（恒 1）
);

// 当前装载是否针对 CS
logic is_code_segment_index;

// 组合逻辑：连续赋值
assign is_code_segment_index = index_segment_register == `sreg_index_CS;

logic [31: 0] encode_base;
logic [19: 0] encode_limit;
logic        encode_present;
logic [ 1: 0] encode_privilege_level;
logic        encode_available_field;
logic        encode_descriptor_type;
logic        encode_date_or_code_granularity;
logic        encode_date_or_code_default_operation_size;
logic        encode_date_or_code_executable;
logic        encode_data_expansion_direction_code_conforming;
logic        encode_data_writeable_code_readable;
logic        encode_date_or_code_accessed;

logic [63: 0] encode_descriptor;

logic [31: 0] decode_base;
logic [19: 0] decode_limit;
logic        decode_present;
logic [ 1: 0] decode_privilege_level;
logic        decode_available_field;
logic        decode_descriptor_type;
logic        decode_date_or_code_granularity;
logic        decode_date_or_code_default_operation_size;
logic        decode_date_or_code_executable;
logic        decode_data_expansion_direction;
logic        decode_data_writeable;
logic        decode_code_conforming;
logic        decode_code_readable;
logic        decode_date_or_code_accessed;

stage_1_isc_mmu_seg_segment_descriptor_encode u_segment_descriptor_encode (
    .base                                     ( encode_base ),
    .limit                                    ( encode_limit ),
    .present                                  ( encode_present ),
    .privilege_level                          ( encode_privilege_level ),
    .available_field                          ( encode_available_field ),
    .descriptor_type                          ( encode_descriptor_type ),
    .date_or_code_granularity                 ( encode_date_or_code_granularity ),
    .date_or_code_default_operation_size      ( encode_date_or_code_default_operation_size ),
    .date_or_code_executable                  ( encode_date_or_code_executable ),
    .data_expansion_direction_code_conforming ( encode_data_expansion_direction_code_conforming ),
    .data_writeable_code_readable             ( encode_data_writeable_code_readable ),
    .date_or_code_accessed                    ( encode_date_or_code_accessed ),
    .descriptor                               ( encode_descriptor )
);

stage_1_isc_mmu_seg_segment_descriptor_decode u_segment_descriptor_decode (
    .o_base                                     ( decode_base ),
    .o_limit                                    ( decode_limit ),
    .o_date_or_code_present                     ( decode_present ),
    .o_date_or_code_privilege_level             ( decode_privilege_level ),
    .o_available_field                          ( decode_available_field ),
    .o_segment_type                             ( decode_descriptor_type ),
    .o_date_or_code_granularity                 ( decode_date_or_code_granularity ),
    .o_date_or_code_default_operation_size      ( decode_date_or_code_default_operation_size ),
    .o_date_or_code_executable                  ( decode_date_or_code_executable ),
    .o_data_expansion_direction                 ( decode_data_expansion_direction ),
    .o_data_writeable                           ( decode_data_writeable ),
    .o_code_conforming                          ( decode_code_conforming ),
    .o_code_readable                            ( decode_code_readable ),
    .o_date_or_code_accessed                    ( decode_date_or_code_accessed ),
    .i_descriptor                               ( encode_descriptor )
);

// 组合逻辑：推导输出
always_comb begin
    write_enable   = 16'b0;
    write_index    = index_segment_register;
    write_selector = greg_16;
    // 实模式：选择子左移 4 位作基址，界限固定 0xFFFFF
    if (~protected_mode_enable) begin
        encode_base                                     = { 16'b0, greg_16, 4'b0 };
        encode_limit                                    = 20'h0_FFFF;
        encode_present                                  = 1'b1;
        encode_privilege_level                          = 2'b0;
        encode_available_field                          = 1'b0;
        encode_descriptor_type                          = 1'b1;
        encode_date_or_code_granularity                 = `granularity_byte;
        encode_date_or_code_default_operation_size      = `default_operation_size_16;
        encode_date_or_code_executable                  = is_code_segment_index;
        encode_data_expansion_direction_code_conforming = `data_expansion_direction_up;
        encode_data_writeable_code_readable             = 1'b1;
        encode_date_or_code_accessed                    = 1'b1;
        write_descriptor                                = encode_descriptor;
    end else begin
        // 保护模式 bring-up：描述符清零占位
        encode_base                                     = '0;
        encode_limit                                    = '0;
        encode_present                                  = 1'b0;
        encode_privilege_level                          = '0;
        encode_available_field                          = 1'b0;
        encode_descriptor_type                          = 1'b0;
        encode_date_or_code_granularity                 = `granularity_byte;
        encode_date_or_code_default_operation_size      = `default_operation_size_16;
        encode_date_or_code_executable                  = 1'b0;
        encode_data_expansion_direction_code_conforming = `data_expansion_direction_up;
        encode_data_writeable_code_readable             = 1'b0;
        encode_date_or_code_accessed                    = 1'b0;
        write_descriptor                                = '0;
    end
end

// 组合逻辑：连续赋值
assign ready = 1'b1;

endmodule
