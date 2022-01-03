/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: system_address_register
create at: 2021-10-22 22:23:28
description: define system_address register
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
2.3.7 System Address Registers
Four special registers are defined to reference the
tables or segments supported by the 80286 CPU
and Intel386 DX protection model. These tables or
segments are:
GDT (Global Descriptor Table),
IDT (Interrupt Descriptor Table),
LDT (Local Descriptor Table),
TSS (Task State Segment).
The addresses of these tables and segments are
stored in special registers, the System Address and
System Segment Registers illustrated in Figure 2-7.
These registers are named GDTR, IDTR, LDTR and
TR, respectively. Section 4 Protected Mode Architecture
describes the use of these registers.
*/

module system_address_register #(
    // parameters
) (
    // ports
    input  logic        write_enable,
    input  logic [ 4:0] write_index,
    input  logic        write_data,
    output logic [31:0] GDT,
    output logic [31:0] IDT,
    output logic [31:0] LDT,
    output logic [31:0] TSS,
    input  logic        clock, reset
);

// GDT (Global Descriptor Table),
// IDT (Interrupt Descriptor Table),
// LDT (Local Descriptor Table),
// TSS (Task State Segment)

endmodule
