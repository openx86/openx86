/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: segmentation_unit
create at: 2022-01-31 01:31:23
description: segmentation_unit
*/

module segmentation_unit #(
    parameter
    read_from_fetch
) (
    input  logic        protected_mode,
    input  logic        read_write_n,
    input  logic [63:0] segment_descriptor [6],
    input  logic [ 2:0] segment_index,
    input  logic [31:0] offset,
    input  logic [ 1:0] current_privilege_level,
    output logic [31:0] linear_address
);

wire  [63:0] descriptor = segment_descriptor[segment_index];

logic [31:0] base;
logic [19:0] limit;
logic        date_or_code_present;
logic [ 1:0] date_or_code_privilege_level;
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
logic [ 3:0] system_segment_type;

segment_descriptor_decode u_segment_descriptor_decode (
    .base                                ( base ),
    .limit                               ( limit ),
    .date_or_code_present                ( date_or_code_present ),
    .date_or_code_privilege_level        ( date_or_code_privilege_level ),
    .available_field                     ( available_field ),
    .segment_type                        ( segment_type ),
    .date_or_code_granularity            ( date_or_code_granularity ),
    .date_or_code_default_operation_size ( date_or_code_default_operation_size ),
    .date_or_code_executable             ( date_or_code_executable ),
    .data_expansion_direction            ( data_expansion_direction ),
    .data_writeable                      ( data_writeable ),
    .code_conforming                     ( code_conforming ),
    .code_readable                       ( code_readable ),
    .date_or_code_accessed               ( date_or_code_accessed ),
    .system_segment_type                 ( system_segment_type ),
    .descriptor                          ( descriptor ),
);

wire is_index_CS = segment_index == 0;

wire is_code_segment = segment_type & date_or_code_executable;
wire is_data_segment = segment_type & ~date_or_code_executable;

wire is_read  = read_write_n;
wire is_write = ~read_write_n;

wire is_granularity_byte = date_or_code_granularity;
wire is_granularity_page = ~date_or_code_granularity;

// need to confirm the logic is greater equal than(=>) or greater than(>)
wire exception_limit = (is_granularity_byte & offset >= limit) | (is_granularity_page & offset >= (limit << 4));

// check CPL > RPL when execute loading to segment register instruction
// check CPL > DPL immediately
wire exception_privilege_leve = current_privilege_level >= date_or_code_privilege_level;

wire exception_read = is_read & ~read_from_fetch & ~code_readable;

wire exception_write = (is_write & is_index_CS) | (is_write & is_data_segment & ~data_writeable);

endmodule
