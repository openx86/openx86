/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: control_register
create at: 2021-10-23 14:12:03
description: define the control register
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

module control_register (
    // ports
    input  logic         write_enable,
    input  logic [ 2: 0] write_index,
    input  logic [31: 0] write_data,
    output logic [31: 0] CR [0:7],
    output logic         PE,
    output logic         MP,
    output logic         EM,
    output logic         TS,
    output logic         R,
    output logic         PG,
    output logic [19: 0] page_directory_base,
    input  logic         clock, reset
);

reg [31:0] CR [0:7];

always_ff @( posedge clock or posedge reset ) begin : ff_control_register
    if (reset) begin
        CR[0] <= 32'b0;
        CR[1] <= 32'b0;
        CR[2] <= 32'b0;
        CR[3] <= 32'b0;
        CR[4] <= 32'b0;
        CR[5] <= 32'b0;
        CR[6] <= 32'b0;
        CR[7] <= 32'b0;
    end else begin
        if (write_enable) begin
            CR[write_index] <= write_data;
        end
    end
end

assign PE = CR[0][0];
assign MP = CR[0][1];
assign EM = CR[0][2];
assign TS = CR[0][3];
assign R  = CR[0][4];
assign PG = CR[0][31];

assign page_directory_base = CR[3][31:12];

endmodule
