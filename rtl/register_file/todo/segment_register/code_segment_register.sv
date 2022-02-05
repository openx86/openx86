/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: code_segment_register
create at: 2022-01-30 23:42:46
description: define code_segment_register
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
*/

module code_segment_register (
    input  logic        CS_write_enable,
    input  logic [15:0] CS_write_data,
    output logic [15:0] CS,
    input  logic        CS_descriptor_write_enable,
    input  logic [63:0] CS_descriptor_write_data,
    output logic [63:0] CS_descriptor,
    output logic [31:0] CS_descriptor_base
    output logic [19:0] CS_descriptor_limit
    output logic        CS_descriptor_present
    output logic [ 1:0] CS_descriptor_privilege_level
    output logic        CS_descriptor_available_field
    output logic        CS_descriptor_segment_type
    output logic        CS_descriptor_granularity
    output logic        CS_descriptor_default_operation_size
    output logic        CS_descriptor_segment_executable
    output logic        CS_descriptor_accessed
    output logic        CS_descriptor_system_segment_type
    output logic        CS_descriptor_accesse,
    input  logic        clock, reset
);

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        CS <= 16'b0;
    end else begin
        if (CS_write_enable) begin
            CS <= CS_write_data;
        end else begin
            CS <= CS;
        end
    end
end

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        CS_descriptor <= 64'b0;
    end else begin
        if (CS_descriptor_write_enable) begin
            CS_descriptor <= CS_descriptor_write_data;
        end else begin
            CS_descriptor <= CS_descriptor;
        end
    end
end

segment_descriptor_decode u_segment_descriptor_decode (
    .base                                ( CS_descriptor_base ),
    .limit                               ( CS_descriptor_limit ),
    .date_or_code_present                ( CS_descriptor_present ),
    .date_or_code_privilege_level        ( CS_descriptor_privilege_level ),
    .available_field                     ( CS_descriptor_available_field ),
    .segment_type                        ( CS_descriptor_segment_type ),
    .date_or_code_granularity            ( CS_descriptor_granularity ),
    .date_or_code_default_operation_size ( CS_descriptor_default_operation_size ),
    .date_or_code_segment_executable     ( CS_descriptor_segment_executable ),
    // .data_segment_expansion_direction    ( CS_descriptor_segment_conforming ),
    // .data_segment_writeable              ( CS_descriptor_segment_readable ),
    .code_segment_conforming             ( CS_descriptor_accessed ),
    .code_segment_readable               ( CS_descriptor_system_segment_type ),
    .date_or_code_accessed               ( CS_descriptor_accessed ),
    // .system_segment_type                 ( CS_descriptor_accessed ),
    .descriptor                          ( CS_descriptor )
);

endmodule
