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
4.3.4.6 GATE DESCRIPTORS (Se0, TYPEe4–7, C, F)
Gates are used to control access to entry points
within the target code segment. The various types of
gate descriptors are call gates, task gates, interrupt gates, and trap gates. Gates provide a level of
indirection between the source and destination of
the control transfer. This indirection allows the processor to automatically perform protection checks. It
also allows system designers to control entry points
to the operating system. Call gates are used to
change privilege levels (see section 4.4 Protection),
task gates are used to perform a task switch, and
interrupt and trap gates are used to specify interrupt
service routines.
Figure 4-8 shows the format of the four types of gate
descriptors. Call gates are primarily used to transfer
program control to a more privileged level. The call
gate descriptor consists of three fields: the access
byte, a long pointer (selector and offset) which
points to the start of a routine and a word count
which specifies how many parameters are to be copied from the caller’s stack to the stack of the called
routine. The word count field is only used by call
gates when there is a change in the privilege level,
other types of gates ignore the word count field.
Interrupt and trap gates use the destination selector
and destination offset fields of the gate descriptor as
a pointer to the start of the interrupt or trap handler
routines. The difference between interrupt gates and
trap gates is that the interrupt gate disables interrupts (resets the IF bit) while the trap gate does not.
*/

module gate_segment_descriptor_decode (
    // ports
    output logic [15:0] o_selector,
    output logic [31:0] o_offset,
    output logic        o_present,
    output logic [ 1:0] o_privilege_level,
    output logic        o_gate_segment_type,
    output logic [ 4:0] o_word_count,
    input  logic [63:0] i_descriptor
);

typedef enum logic [3:0] {
    // GATE_SEG_TYPE_INVALID_80286 = 4'h0,
    // GATE_SEG_TYPE_AVAILABLE_80286_TSS = 4'h1,
    // GATE_SEG_TYPE_LDT = 4'h2,
    // GATE_SEG_TYPE_BUSY_80286_TSS = 4'h3,
    GATE_SEG_TYPE_80286_CALL_GATE = 4'h4,
    GATE_SEG_TYPE_TASK_GATE = 4'h5,
    GATE_SEG_TYPE_80286_INTERRUPT_GATE = 4'h6,
    GATE_SEG_TYPE_80286_TRAP_GATE = 4'h7,
    // GATE_SEG_TYPE_INVALID_80286 = 4'h8,
    // GATE_SEG_TYPE_AVAILABLE_80386_TSS = 4'h9,
    // GATE_SEG_TYPE_UNDEFINED_0 = 4'hA,
    // GATE_SEG_TYPE_BUSY_80386_TSS = 4'hB,
    GATE_SEG_TYPE_80386_CALL_GATE = 4'hC,
    // GATE_SEG_TYPE_UNDEFINED_1 = 4'hD,
    GATE_SEG_TYPE_80386_INTERRUPT_GATE = 4'hE,
    GATE_SEG_TYPE_80386_TRAP_GATE = 4'hF
} gate_segment_type_t;

assign o_selector          = i_descriptor[63:48];
assign o_offset            = i_descriptor[47:16];
assign o_present           = i_descriptor[   15];
assign o_privilege_level   = i_descriptor[14:13];
assign o_gate_segment_type = i_descriptor[11: 8];

endmodule
