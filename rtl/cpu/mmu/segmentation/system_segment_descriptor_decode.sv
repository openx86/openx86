/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements system_segment_descriptor_decode.
*/
/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: system_segment_descriptor_decode
create at: 2021-10-23 13:43:22
description: decode the segment register
*/

/* ref:
Intel486(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
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
in the segment descriptor. Figure 4-5 shows the general format of a i_descriptor. All segments on the Intel486 DX have three attribute fields in common: the
P bit, the DPL bit, and the S bit. The o_date_or_code_present P bit is
1 if the segment is loaded in physical memory, if
Pe0 then any attempt to access this segment causes a not o_date_or_code_present exception (exception 11). The Descriptor Privilege Level DPL is a two-bit field which
specifies the protection level 0–3 associated with a
segment
*/

module system_segment_descriptor_decode (    // 系统段描述符（S=0）：基址/limit/粒度/类型等
    output logic [31: 0] o_base,
    output logic [19: 0] o_limit,
    output logic         o_granularity,
    output logic         o_present,
    output logic         o_privilege_level,
    output logic [ 3: 0] o_system_segment_type,
    input  logic [63: 0] i_descriptor
);

// 系统段描述符：基址与 limit 非连续字节拼接
assign o_base                = { i_descriptor[31: 24], i_descriptor[ 7: 0], i_descriptor[63: 48] };
assign o_limit               = { i_descriptor[19: 16], i_descriptor[47: 32] };
assign o_granularity         = i_descriptor[   23];
assign o_present             = i_descriptor[   15];
assign o_privilege_level     = i_descriptor[14: 13];
assign o_system_segment_type = i_descriptor[11: 8];

endmodule
