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
//  File        : ld_execute_load_segment.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : ld_execute_load_segment module
// ============================================================================

`include "openx86_defs.h.sv"

module ld_execute_load_segment (
    // =========================
    // execution inputs
    // =========================
    input  logic          protected_mode_enable,
    input  logic [15: 0] index_segment_register,
    input  logic [15: 0] index_general_register,
    input  logic [ 7: 0]   greg__8,
    input  logic [15: 0]  greg_16,
    input  logic [31: 0]  greg_32,

    // =========================
    // writeback outputs
    // =========================
    output logic [15: 0] write_enable,
    output logic [15: 0] write_index,
    output logic [15: 0] write_selector,
    output logic [63: 0] write_descriptor,

    // =========================
    // handshake
    // =========================
    input  logic          valid,
    output logic         ready
);

    // ============================================================
    // check if current load targets CS
    // ============================================================
    logic is_code_segment_index;

    assign is_code_segment_index = index_segment_register == 16'(`sreg_index_CS);

    // ============================================================
    // segment descriptor encode fields
    // ============================================================
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

    // ============================================================
    // segment descriptor encode function
    // ============================================================
    function automatic logic [63: 0] f_encode_segment_descriptor (
    input logic [31: 0] i_base,
    input logic [19: 0] i_limit,
    input logic        i_present,
    input logic [ 1: 0] i_privilege_level,
    input logic        i_available_field,
    input logic        i_descriptor_type,
    input logic        i_granularity,
    input logic        i_default_operation_size,
    input logic        i_executable,
    input logic        i_expansion_or_conforming,
    input logic        i_writeable_or_readable,
    input logic        i_accessed
);
    begin
        f_encode_segment_descriptor = {
            i_base[15: 0],
            i_limit[15: 0],
            i_base[31: 24],
            i_granularity,
            i_default_operation_size,
            1'b0,
            i_available_field,
            i_limit[19: 16],
            i_present,
            i_privilege_level,
            i_descriptor_type,
            i_executable,
            i_expansion_or_conforming,
            i_writeable_or_readable,
            i_accessed,
            i_base[23: 16]
        };
    end
endfunction

    // ============================================================
    // combinational logic: derive outputs
    // ============================================================
    always_comb begin : comb_encode
    write_enable   = 16'b0;
    write_index    = index_segment_register;
    write_selector = greg_16;
    // 实模式：选择子左移 4 位作基址，界限固定 0xFFFFF
    if (~protected_mode_enable) begin
        encode_base                                     = { 12'b0, greg_16, 4'b0 };
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
        write_descriptor                                = f_encode_segment_descriptor(
            encode_base,
            encode_limit,
            encode_present,
            encode_privilege_level,
            encode_available_field,
            encode_descriptor_type,
            encode_date_or_code_granularity,
            encode_date_or_code_default_operation_size,
            encode_date_or_code_executable,
            encode_data_expansion_direction_code_conforming,
            encode_data_writeable_code_readable,
            encode_date_or_code_accessed
        );
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
