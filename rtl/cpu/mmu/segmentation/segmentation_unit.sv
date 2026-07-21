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
//  Description : Segmentation checks with differentiated fault outputs
// ============================================================================

module segmentation_unit #(
    parameter bit read_from_fetch = 1'b0
) (
    // =========================
    // segmentation context inputs (selector + descriptor + offset)
    // =========================
    input  logic          i_protected_mode,
    input  logic [ 5: 0][15: 0] i_segment_selector,
    input  logic [ 5: 0][63: 0] i_segment_descriptor,
    input  logic [ 2: 0]        i_segment_index,
    input  logic [ 1: 0]        i_current_privilege_level,
    input  logic [31: 0]        i_effective_address,
    input  logic                 i_write_enable,

    // =========================
    // segmentation outputs (linear address or fault)
    // =========================
    output logic [31: 0]        o_linear_address,
    output logic                 o_segment_privilege_error,
    output logic                 o_segment_not_present,
    output logic                 o_stack_segment_fault,
    output logic                 o_segment_fault,

    // =========================
    // clock and reset
    // =========================
    input  logic                 clk,
    input  logic                 rst_n
);

    // ============================================================
    // current segment descriptor (selected by index)
    // ============================================================
    logic  [63: 0] segment_descriptor;
    logic  [15: 0] current_selector;
    logic  [ 1: 0] selector_rpl;
    logic  [ 1: 0] effective_privilege;

    // ============================================================
    // decoded descriptor fields
    // ============================================================
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

    // ============================================================
    // segment descriptor decode
    // ============================================================
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

    // ============================================================
    // segment type detection
    // ============================================================
    logic is_index_CS;
    logic is_index_SS;
    logic is_data_segment;
    logic is_read;
    logic is_write;

    // ============================================================
    // granularity detection
    // ============================================================
    logic is_granularity_byte;
    logic is_granularity_page;

    // 越界检查：字节/页粒度下 offset 与 limit 关系
    logic exception_limit;

    // 特权检查：CPL/RPL 与 DPL
    logic exception_rpl_cpl;
    logic exception_ss_privilege;

    logic exception_read;
    logic exception_write;

    logic exception_not_present;
    logic fault_limit_ss;
    logic fault_limit_gp;
    logic fault_access_ss;
    logic fault_access_gp;

    assign segment_descriptor      = i_segment_descriptor[i_segment_index];
    assign current_selector        = i_segment_selector[i_segment_index];
    assign selector_rpl            = current_selector[1: 0];
    assign effective_privilege     = (i_current_privilege_level > selector_rpl) ?
                                     i_current_privilege_level : selector_rpl;
    assign is_index_CS            = (i_segment_index == 3'b001);
    assign is_index_SS            = (i_segment_index == 3'b010);
    assign is_data_segment        = segment_type & ~date_or_code_executable;
    assign is_read                 = ~i_write_enable;
    assign is_write                = i_write_enable;
    assign is_granularity_byte    = ~date_or_code_granularity;
    assign is_granularity_page    = date_or_code_granularity;
    logic [31: 0] limit_ext;
    logic [31: 0] limit_page_scaled;
    assign limit_ext              = {12'h0, limit};
    // G=1: limit is in 4KB units; scale and fill low 12 bits (Intel SDM)
    assign limit_page_scaled      = {limit, 12'hFFF};
    assign exception_limit        = (is_granularity_byte & (i_effective_address > limit_ext)) |
                                    (is_granularity_page & (i_effective_address > limit_page_scaled));
    assign exception_not_present    = i_protected_mode & ~date_or_code_present;
    assign exception_ss_privilege   = i_protected_mode & is_index_SS &
                                      (i_current_privilege_level != date_or_code_privilege_level);
    assign exception_rpl_cpl        = i_protected_mode & ~exception_not_present & (
                                      (date_or_code_executable & ~code_conforming &
                                       (i_current_privilege_level < date_or_code_privilege_level)) |
                                      (is_data_segment &
                                       (effective_privilege > date_or_code_privilege_level))
                                      );
    assign exception_read           = is_read & ~read_from_fetch & ~code_readable;
    assign exception_write          = (is_write & is_index_CS) |
                                      (is_write & is_data_segment & ~data_writeable);

    assign fault_limit_ss           = i_protected_mode & is_index_SS & exception_limit;
    assign fault_limit_gp           = i_protected_mode & ~is_index_SS & exception_limit;
    assign fault_access_ss          = i_protected_mode & is_index_SS &
                                      (exception_ss_privilege | exception_read | exception_write);
    assign fault_access_gp          = i_protected_mode & ~is_index_SS &
                                      (exception_rpl_cpl | exception_read | exception_write);

    assign o_segment_not_present    = exception_not_present;
    assign o_stack_segment_fault    = fault_limit_ss | fault_access_ss;
    assign o_segment_fault          = fault_limit_gp | fault_access_gp;
    assign o_segment_privilege_error = o_segment_not_present |
                                       o_stack_segment_fault |
                                       o_segment_fault;

    // Linear address = segment base + offset.
    // Real mode: base = selector << 4 (hidden descriptor is unused until PE=1).
    // Protected mode: base from descriptor cache/decode.
    logic [31: 0] effective_base;
    assign effective_base   = i_protected_mode ? base : {12'h0, current_selector, 4'h0};
    assign o_linear_address = effective_base + i_effective_address;

endmodule
