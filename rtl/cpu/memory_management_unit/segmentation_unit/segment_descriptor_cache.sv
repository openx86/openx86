/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: segment_descriptor_cache
create at: 2022-01-27 12:56:29
description: segment_descriptor_cache
*/

module segment_descriptor_cache (
    // ports
    input  logic         protect_enable,
    input  logic [15: 0] write_data,
    input  logic         write_enable,
    output logic         read_data,
    output logic [31: 0] base,
    output logic [31: 0] limit,
    output logic [ 1: 0] present,
    output logic         privilege_level,
    output logic         accessed,
    output logic         granularity,
    output logic         expansion_direction,
    output logic         readable,
    output logic         writeable,
    output logic         executable,
    output logic         stack_size,
    output logic         conforming_privilege
);

// Stub implementation - connects internally to segment_descriptor_decode
logic [15:0] segment_value;
assign segment_value = write_data;

logic [63:0] segment_descriptor;
logic [31:0] segment_descriptor_base_address;

segment_descriptor_decode u_segment_descriptor_decode (
    .o_base                                ( base ),
    .o_limit                               ( limit ),
    .o_date_or_code_present                ( present[0] ),
    .o_date_or_code_privilege_level        ( present[1:0] ),
    .o_available_field                     ( accessed ),
    .o_segment_type                        ( readable ),
    .o_date_or_code_granularity            ( granularity ),
    .o_date_or_code_default_operation_size ( stack_size ),
    .o_date_or_code_executable             ( executable ),
    .o_data_expansion_direction            ( expansion_direction ),
    .o_data_writeable                      ( writeable ),
    .o_code_conforming                     ( conforming_privilege ),
    .o_code_readable                       ( privilege_level ),
    .o_date_or_code_accessed               ( read_data ),
    .i_descriptor                          ( segment_descriptor )
);

always_comb begin
    segment_descriptor = '0;
end

endmodule
