/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: segment_descriptor_cache
create at: 2022-01-27 12:56:29
description: segment_descriptor_cache
*/

module segment_descriptor_cache #(
    // parameters
) (
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
    output logic         conforming_privilege,
);

segment_descriptor_encode u_segment_descriptor_encode (
    .base (),
);

always_comb begin
    if (protect_enable) begin
        // protected mode

    end else begin
        // real mode
        base <= segment_value;
        limit <= 32'h0000_ffff;
        present <= 1;
        privilege_level <= 0;
        accessed <= 1;
        granularity <= `GRANULARITY_BYTE;
    end
end

logic [31:0] segment_descriptor_base_address;
segment_descriptor_decode u_segment_descriptor_decode (
    .base ( segment_descriptor_base_address ),
    .descriptor ( segment_descriptor ),
);

assign base_address_in_real_mode = segment_value << 4;
assign base_address_in_protected_mode = segment_descriptor_base_address;

endmodule
