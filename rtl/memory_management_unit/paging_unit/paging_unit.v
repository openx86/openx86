/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: paging_unit
create at: 2022-01-31 02:35:30
description: paging_unit

4.5.2 Paging Organization
4.5.2.1 PAGE MECHANISM
The Intel386 DX uses two levels of tables to translate
the linear address (from the segmentation unit)
into a physical address. There are three components
to the paging mechanism of the Intel386 DX:
the page directory, the page tables, and the page
itself (page frame). All memory-resident elements of
the Intel386 DX paging mechanism are the same
size, namely, 4K bytes. A uniform size for all of the
elements simplifies memory allocation and reallocation
schemes, since there is no problem with memory
fragmentation. Figure 4-19 shows how the paging
mechanism works.
4.5.2.2 PAGE DESCRIPTOR BASE REGISTER
CR2 is the Page Fault Linear Address register. It
holds the 32-bit linear address which caused the last
page fault detected.
CR3 is the Page Directory Physical Base Address
Register. It contains the physical starting address of
the Page Directory. The lower 12 bits of CR3 are
always zero to ensure that the Page Directory is always
page aligned. Loading it via a MOV CR3, reg
instruction causes the Page Table Entry cache to be
flushed, as will a task switch through a TSS which
changes the value of CR0. (See 4.5.4 Translation
Lookaside Buffer).
*/

module paging_unit #(
    parameter
    read_from_fetch
) (
    input  logic         paging_enable,
    input  logic [31: 0] linear_address,
    output logic [31: 0] physical_address
);

// TODO: refer to 4.5.2 Paging Organization
assign physical_address = linear_address;

endmodule
