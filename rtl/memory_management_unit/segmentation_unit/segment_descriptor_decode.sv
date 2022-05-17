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
attributes include the 32-bit o_base linear address of
the segment, the 20-bit length and granularity of the
segment, the protection level, read, write or execute
privileges, the default size of the operands (16-bit or
32-bit), and the type of segment. All of the attribute
information about a segment is contained in 12 bits
in the segment descriptor. Figure 4-5 shows the general format of a i_descriptor. All segments on the Intel386 DX have three attribute fields in common: the
P bit, the DPL bit, and the S bit. The o_date_or_code_present P bit is
1 if the segment is loaded in physical memory, if
Pe0 then any attempt to access this segment causes a not o_date_or_code_present exception (exception 11). The Descriptor Privilege Level DPL is a two-bit field which
specifies the protection level 0–3 associated with a
segment
*/

module segment_descriptor_decode (
    // ports
    output logic [31:0] o_base,
    output logic [19:0] o_limit,
    output logic        o_date_or_code_present,
    output logic [ 1:0] o_date_or_code_privilege_level,
    output logic        o_available_field,
    output logic        o_segment_type,
    output logic        o_date_or_code_granularity,
    output logic        o_date_or_code_default_operation_size,
    output logic        o_date_or_code_executable,
    output logic        o_data_expansion_direction,
    output logic        o_data_writeable,
    output logic        o_code_conforming,
    output logic        o_code_readable,
    output logic        o_date_or_code_accessed,
    input  logic [63:0] i_descriptor
);

typedef enum logic [3:0] {
    SYS_SEG_TYPE_INVALID_80286 = 4'h0,
    SYS_SEG_TYPE_AVAILABLE_80286_TSS = 4'h1,
    SYS_SEG_TYPE_LDT = 4'h2,
    SYS_SEG_TYPE_BUSY_80286_TSS = 4'h3,
    SYS_SEG_TYPE_80286_CALL_GATE = 4'h4,
    SYS_SEG_TYPE_TASK_GATE = 4'h5,
    SYS_SEG_TYPE_80286_INTERRUPT_GATE = 4'h6,
    SYS_SEG_TYPE_80286_TRAP_GATE = 4'h7,
    SYS_SEG_TYPE_INVALID_80386 = 4'h8,
    SYS_SEG_TYPE_AVAILABLE_80386_TSS = 4'h9,
    SYS_SEG_TYPE_UNDEFINED_0 = 4'hA,
    SYS_SEG_TYPE_BUSY_80386_TSS = 4'hB,
    SYS_SEG_TYPE_80386_CALL_GATE = 4'hC,
    SYS_SEG_TYPE_UNDEFINED_1 = 4'hD,
    SYS_SEG_TYPE_80386_INTERRUPT_GATE = 4'hE,
    SYS_SEG_TYPE_80386_TRAP_GATE = 4'hF
} system_segment_type_t;

wire [15: 0] o_base_15__0 = i_descriptor[63:48];
wire [ 7: 0] o_base_23_16 = i_descriptor[ 7: 0];
wire [ 7: 0] o_base_31_24 = i_descriptor[31:24];

wire [ 7: 0] o_limit_15__0 = i_descriptor[47:32];
wire [ 7: 0] o_limit_19_16 = i_descriptor[19:16];

assign o_base                                = { o_base_31_24, o_base_23_16, o_base_15__0 };
assign o_limit                               = { o_limit_19_16, o_limit_15__0 };
assign o_date_or_code_present                = i_descriptor[15];
assign o_date_or_code_privilege_level        = i_descriptor[14:13];
assign o_available_field                     = i_descriptor[20];
assign o_segment_type                        = i_descriptor[12];
assign o_date_or_code_granularity            = i_descriptor[23];
assign o_date_or_code_default_operation_size = i_descriptor[22];
assign o_date_or_code_executable             = i_descriptor[11];
assign o_data_expansion_direction            = i_descriptor[10];
assign o_data_writeable                      = i_descriptor[9];
assign o_code_conforming                     = i_descriptor[10];
assign o_code_readable                       = i_descriptor[9];
assign o_date_or_code_accessed               = i_descriptor[8];

endmodule
