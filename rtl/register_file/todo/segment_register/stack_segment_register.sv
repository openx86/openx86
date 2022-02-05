/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: stack_segment_register
create at: 2022-01-31 00:48:55
description: define stack_segment_register
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
*/

module stack_segment_register (
    input  logic        SS_write_enable,
    input  logic [15:0] SS_write_data,
    output logic [15:0] SS,
    input  logic        SS_descriptor_write_enable,
    input  logic [63:0] SS_descriptor_write_data,
    output logic [63:0] SS_descriptor,
    output logic [31:0] SS_descriptor_base
    output logic [19:0] SS_descriptor_limit
    output logic        SS_descriptor_present
    output logic [ 1:0] SS_descriptor_privilege_level
    output logic        SS_descriptor_available_field
    output logic        SS_descriptor_segment_type
    output logic        SS_descriptor_granularity
    output logic        SS_descriptor_default_operation_size
    output logic        SS_descriptor_segment_executable
    output logic        SS_descriptor_accessed
    output logic        SS_descriptor_system_segment_type
    output logic        SS_descriptor_accesse,
    input  logic        clock, reset
);

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        SS <= 16'b0;
    end else begin
        if (SS_write_enable) begin
            SS <= SS_write_data;
        end else begin
            SS <= SS;
        end
    end
end

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        SS_descriptor <= 64'b0;
    end else begin
        if (SS_descriptor_write_enable) begin
            SS_descriptor <= SS_descriptor_write_data;
        end else begin
            SS_descriptor <= SS_descriptor;
        end
    end
end

segment_descriptor_decode u_segment_descriptor_decode (
    .base                                ( SS_descriptor_base ),
    .limit                               ( SS_descriptor_limit ),
    .date_or_code_present                ( SS_descriptor_present ),
    .date_or_code_privilege_level        ( SS_descriptor_privilege_level ),
    .available_field                     ( SS_descriptor_available_field ),
    .segment_type                        ( SS_descriptor_segment_type ),
    .date_or_code_granularity            ( SS_descriptor_granularity ),
    .date_or_code_default_operation_size ( SS_descriptor_default_operation_size ),
    .date_or_code_segment_executable     ( SS_descriptor_segment_executable ),
    .data_segment_expansion_direction    ( SS_descriptor_segment_expansion_direction ),
    .data_segment_writeable              ( SS_descriptor_segment_writeable ),
    // .code_segment_conforming             ( SS_descriptor_accessed ),
    // .code_segment_readable               ( SS_descriptor_system_segment_type ),
    .date_or_code_accessed               ( SS_descriptor_accessed ),
    // .system_segment_type                 ( SS_descriptor_accessed ),
    .descriptor                          ( SS_descriptor )
);

endmodule
