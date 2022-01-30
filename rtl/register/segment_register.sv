/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: segment_register
create at: 2022-01-31 03:54:23
description: define the segment register
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
2.3.6 Control Registers
The Intel386 DX has three control registers of 32
bits, CR0, CR2 and CR3, to hold machine state of a
global nature (not specific to an individual task).
These registers, along with System Address Registers
described in the next section, hold machine
state that affects all tasks in the system. To access
the Control Registers, load and store instructions
are defined.

CR1: reserved
CR1 is reserved for use in future Intel processors.
CR2: Page Fault Linear Address
CR2, shown in Figure 2-6, holds the 32-bit linear address
that caused the last page fault detected. The
error code pushed onto the page fault handler's
stack when it is invoked provides additional status
information on this page fault.
CR3: Page Directory Base Address
CR3, shown in Figure 2-6, contains the physical
base address of the page directory table. The Intel386
DX page directory table is always pagealigned
(4 Kbyte-aligned). Therefore the lowest
twelve bits of CR3 are ignored when written and
they store as undefined.
A task switch through a TSS which changes the
value in CR3, or an explicit load into CR3 with any
value, will invalidate all cached page table entries in
the paging unit cache. Note that if the value in CR3
does not change during the task switch, the cached
page table entries are not flushed.
*/

module segment_register (
    input  logic        write_enable,
    input  logic [ 2:0] write_index,
    input  logic [15:0] write_selector,
    input  logic [63:0] write_descriptor,
    output logic [15:0] segment_reg [0:5],
    output logic [63:0] descriptor_cache [0:5],
    input  logic        clock, reset
);

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        segment_reg[0] <= 16'b0;
        segment_reg[1] <= 16'b0;
        segment_reg[2] <= 16'b0;
        segment_reg[3] <= 16'b0;
        segment_reg[4] <= 16'b0;
        segment_reg[5] <= 16'b0;
    end else begin
        if (write_enable) begin
            segment_reg[write_index] <= write_selector;
        end
    end
end

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        descriptor_cache[0] <= 64'b0;
        descriptor_cache[1] <= 64'b0;
        descriptor_cache[2] <= 64'b0;
        descriptor_cache[3] <= 64'b0;
        descriptor_cache[4] <= 64'b0;
        descriptor_cache[5] <= 64'b0;
    end else begin
        if (write_enable) begin
            descriptor_cache[write_index] <= write_descriptor;
        end
    end
end

endmodule
