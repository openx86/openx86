/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: segmentation_unit
create at: 2022-01-31 01:31:23
description: segmentation_unit
*/

module segmentation_unit #(
    read_from_fetch = 0
) (
    input  logic        i_protected_mode, // from CR0.PE (CR[0][0])
    input  logic [15:0] i_segment_selector [6], // from segment register file
    input  logic [63:0] o_segment_descriptor [6], // from segment register file
    input  logic [ 2:0] i_segment_index, // from bus_interface_unit module
    input  logic [ 1:0] i_current_privilege_level, // from flags register file
    input  logic [31:0] i_effective_address, // from bus_interface_unit module
    input  logic        i_write_enable, // from bus_interface_unit module
    output logic [31:0] o_linear_address, // to paging unit
    output logic        o_segment_privilege_error, // to execute
    input  logic        clock, reset
);

wire  [63:0] segment_descriptor = i_segment_selector[i_segment_index];

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

segment_descriptor_decode u_segment_descriptor_decode (
    .o_base                                ( base ),
    .o_limit                               ( limit ),
    .o_date_or_code_present                ( date_or_code_present ),
    .o_date_or_code_privilege_level        ( date_or_code_privilege_level ),
    .o_available_field                     ( available_field ),
    .o_segment_type                        ( segment_type ),
    .o_date_or_code_granularity            ( date_or_code_granularity ),
    .o_date_or_code_default_operation_size ( date_or_code_default_operation_size ),
    .o_date_or_code_executable             ( date_or_code_executable ),
    .o_data_expansion_direction            ( data_expansion_direction ),
    .o_data_writeable                      ( data_writeable ),
    .o_code_conforming                     ( code_conforming ),
    .o_code_readable                       ( code_readable ),
    .o_date_or_code_accessed               ( date_or_code_accessed ),
    .i_descriptor                          ( segment_descriptor )
);

wire is_index_CS = i_segment_index == 0;

wire is_code_segment = segment_type & date_or_code_executable;
wire is_data_segment = segment_type & ~date_or_code_executable;

wire is_read  = ~i_write_enable;
wire is_write = i_write_enable;

wire is_granularity_byte = date_or_code_granularity;
wire is_granularity_page = ~date_or_code_granularity;

// need to confirm the logic is greater equal than(=>) or greater than(>)
wire exception_limit = (is_granularity_byte & i_effective_address >= limit) | (is_granularity_page & i_effective_address >= (limit << 4));

// check CPL > RPL when execute loading to segment register instruction
// check CPL > DPL immediately
wire exception_privilege_level = i_current_privilege_level >= date_or_code_privilege_level;

wire exception_read = is_read & ~read_from_fetch & ~code_readable;

wire exception_write = (is_write & is_index_CS) | (is_write & is_data_segment & ~data_writeable);

assign o_segment_privilege_error =
exception_limit |
exception_privilege_level |
exception_read |
exception_write |
0;

wire base_address = date_or_code_granularity ? base : base * $clog2(4096);
assign o_linear_address = base_address + i_effective_address;

endmodule
