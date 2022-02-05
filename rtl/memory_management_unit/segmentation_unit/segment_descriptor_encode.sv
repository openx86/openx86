/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: segment_descriptor_encode
create at: 2022-01-27 13:23:55
description: encode the segment information to segment descriptor
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
P bit, the DPL bit, and the S bit. The Present P bit is
1 if the segment is loaded in physical memory, if
Pe0 then any attempt to access this segment causes a not present exception (exception 11). The Descriptor Privilege Level DPL is a two-bit field which
specifies the protection level 0–3 associated with a
segment
*/

module segment_descriptor_encode (
    // ports
    input  logic [31:0] base,
    input  logic [19:0] limit,
    input  logic        present,
    input  logic [ 1:0] privilege_level,
    input  logic        available_field,
    input  logic        descriptor_type,
    input  logic        date_or_code_granularity,
    input  logic        date_or_code_default_operation_size,
    input  logic        date_or_code_executable,
    input  logic        data_expansion_direction_code_conforming,
    input  logic        data_writeable_code_readable,
    input  logic        date_or_code_accessed,
    output logic [63:0] descriptor
);

assign descriptor = {
    base[15:0],
    limit[15:0],
    base[31:24],
    date_or_code_granularity,
    date_or_code_default_operation_size,
    1'b0,
    available_field,
    limit[19:16],
    present,
    privilege_level,
    descriptor_type,
    date_or_code_executable,
    data_expansion_direction_code_conforming,
    data_writeable_code_readable,
    accessed,
    base[23:16],
};

endmodule
