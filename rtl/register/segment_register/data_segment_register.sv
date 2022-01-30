/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: data_segment_register
create at: 2022-01-31 01:03:30
description: define data_segment_register
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
*/

module data_segment_register (
    input  logic        selector_write_enable,
    input  logic [15:0] selector_write_data,
    output logic [15:0] selector,
    input  logic        selector_descriptor_write_enable,
    input  logic [63:0] selector_descriptor_write_data,
    output logic [63:0] selector_descriptor,
    output logic [31:0] selector_descriptor_base,
    output logic [19:0] selector_descriptor_limit,
    output logic        selector_descriptor_date_or_code_present,
    output logic [ 1:0] selector_descriptor_date_or_code_privilege_level,
    output logic        selector_descriptor_available_field,
    output logic        selector_descriptor_segment_type,
    output logic        selector_descriptor_date_or_code_granularity,
    output logic        selector_descriptor_date_or_code_default_operation_size,
    output logic        selector_descriptor_date_or_code_executable,
    output logic        selector_descriptor_data_expansion_direction,
    output logic        selector_descriptor_data_writeable,
    output logic        selector_descriptor_code_conforming,
    output logic        selector_descriptor_code_readable,
    output logic        selector_descriptor_date_or_code_accessed,
    output logic [ 3:0] selector_descriptor_system_segment_type,
    input  logic        clock, reset
);

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        selector <= 16'b0;
    end else begin
        if (selector_write_enable) begin
            selector <= selector_write_data;
        end else begin
            selector <= selector;
        end
    end
end

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        selector_descriptor <= 64'b0;
    end else begin
        if (selector_descriptor_write_enable) begin
            selector_descriptor <= selector_descriptor_write_data;
        end else begin
            selector_descriptor <= selector_descriptor;
        end
    end
end

segment_descriptor_decode u_segment_descriptor_decode (
    .base                                ( selector_descriptor_base ),
    .limit                               ( selector_descriptor_limit ),
    .date_or_code_present                ( selector_descriptor_date_or_code_present ),
    .date_or_code_privilege_level        ( selector_descriptor_date_or_code_privilege_level ),
    .available_field                     ( selector_descriptor_available_field ),
    .segment_type                        ( selector_descriptor_segment_type ),
    .date_or_code_granularity            ( selector_descriptor_date_or_code_granularity ),
    .date_or_code_default_operation_size ( selector_descriptor_date_or_code_default_operation_size ),
    .date_or_code_executable             ( selector_descriptor_date_or_code_executable ),
    .data_expansion_direction            ( selector_descriptor_data_expansion_direction ),
    .data_writeable                      ( selector_descriptor_data_writeable ),
    .code_conforming                     ( selector_descriptor_code_conforming ),
    .code_readable                       ( selector_descriptor_code_readable ),
    .date_or_code_accessed               ( selector_descriptor_date_or_code_accessed ),
    .system_segment_type                 ( selector_descriptor_system_segment_type ),
    .descriptor                          ( selector_descriptor )
);

endmodule
