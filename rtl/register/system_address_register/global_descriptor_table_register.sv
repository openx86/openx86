/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: global_descriptor_table_register
create at: 2022-01-30 23:07:44
description: define global_descriptor_table_register
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
4.3.3.2 GLOBAL DESCRIPTOR TABLE
The Global Descriptor Table (GDT) contains descriptors
which are possibly available to all of the
tasks in a system. The GDT can contain any type of
segment descriptor except for descriptors which are
used for servicing interrupts (i.e. interrupt and trap
descriptors). Every Intel386 DX system contains a
32-bit), and the type of segment. All of the attribute
information about a segment is contained in 12 bits
in the segment descriptor. Figure 4-5 shows the general
format of a descriptor. All segments on the Intel386
DX have three attribute fields in common: the
P bit, the DPL bit, and the S bit. The Present P bit is
1 if the segment is loaded in physical memory, if
Pe0 then any attempt to access this segment causes
a not present exception (exception 11). The Descriptor
Privilege Level DPL is a two-bit field which
specifies the protection level 0±3 associated with a
segment.
The Intel386 DX has two main categories of segments
system segments and non-system segments
(for code and data). The segment S bit in the segment
descriptor determines if a given segment is a
system segment or a code or data segment. If the S
bit is 1 then the segment is either a code or data
segment, if it is 0 then the segment is a system segment.
*/

module global_descriptor_table_register (
    input  logic        GDTR_write_enable,
    input  logic [15:0] GDTR_write_data_limit,
    input  logic [31:0] GDTR_write_data_base,
    output logic [15:0] GDTR_limit,
    output logic [31:0] GDTR_base,
    input  logic        clock, reset
);

// GDTR (Global Descriptor Table Register)

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        GDTR_limit <= 16'b0;
        GDTR_base <= 32'b0;
    end else begin
        if (GDTR_write_enable) begin
            GDTR_limit <= GDTR_write_data_limit;
            GDTR_base <= GDTR_write_data_base;
        end else begin
            GDTR_limit <= GDTR_limit;
            GDTR_base <= GDTR_base;
        end
    end
end

// GDT cache
// reg [63:0] GDT_cache [8192];
// write GDT cache to SRAM on board like DE2-xx serials board ...
// for example, DE-35 has a 512-KB SRAM and model id is IS61LV25616
// A0-A17, D0-D15

endmodule
