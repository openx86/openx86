/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: segment_descriptor_decode
create at: 2021-10-23 13:43:22
description: decode the segment register
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
4.3.4 Descriptors
4.3.4.1 DESCRIPTOR ATTRIBUTE BITS
The object to which the segment selector points to
is called a descriptor. Descriptors are eight byte
quantities which contain attributes about a given region of linear address space (i.e. a segment). These
attributes include the 32-bit base linear address of
the segment, the 20-bit length and granularity of the
segment, the protection level, read, write or execute
privileges, the default size of the operands (16-bit or
32-bit), and the type of segment. All of the attribute
information about a segment is contained in 12 bits
in the segment descriptor. Figure 4-5 shows the general format of a descriptor. All segments on the Intel386 DX have three attribute fields in common: the
P bit, the DPL bit, and the S bit. The date_or_code_present P bit is
1 if the segment is loaded in physical memory, if
Pe0 then any attempt to access this segment causes a not date_or_code_present exception (exception 11). The Descriptor Privilege Level DPL is a two-bit field which
specifies the protection level 0–3 associated with a
segment
*/

module segment_descriptor_decode #(
    // parameters
) (
    // ports
    output logic [31:0] base,
    output logic [19:0] limit,
    output logic        date_or_code_present,
    output logic [ 1:0] date_or_code_privilege_level,
    output logic        available_field,
    output logic        segment_type,
    output logic        date_or_code_granularity,
    output logic        date_or_code_default_operation_size,
    output logic        date_or_code_executable,
    output logic        data_expansion_direction,
    output logic        data_writeable,
    output logic        code_conforming,
    output logic        code_readable,
    output logic        date_or_code_accessed,
    output logic [ 3:0] system_segment_type,
    input  logic [63:0] descriptor
);

wire [15: 0] base_15__0 = descriptor[63:48];
wire [ 7: 0] base_23_16 = descriptor[ 7: 0];
wire [ 7: 0] base_31_24 = descriptor[31:24];

wire [ 7: 0] limit_15__0 = descriptor[47:32];
wire [ 7: 0] limit_19_16 = descriptor[19:16];

assign base                                = { base_31_24, base_23_16, base_15__0 };
assign limit                               = { limit_19_16, limit_15__0 };
assign date_or_code_present                = descriptor[15];
assign date_or_code_privilege_level        = descriptor[14:13];
assign available_field                     = descriptor[20];
assign segment_type                        = descriptor[12];
assign date_or_code_granularity            = descriptor[23];
assign date_or_code_default_operation_size = descriptor[22];
assign date_or_code_executable             = descriptor[11];
assign data_expansion_direction            = descriptor[10];
assign data_writeable                      = descriptor[9];
assign code_conforming                     = descriptor[10];
assign code_readable                       = descriptor[9];
assign date_or_code_accessed               = descriptor[8];
assign system_segment_type                 = descriptor[11:8];

endmodule
