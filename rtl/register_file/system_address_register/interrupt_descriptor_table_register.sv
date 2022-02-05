/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: interrupt_descriptor_table_register
create at: 2022-01-30 23:31:01
description: define interrupt_descriptor_table_register
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
4.3.3.4 INTERRUPT DESCRIPTOR TABLE
The third table needed for Intel386 DX systems is
the Interrupt Descriptor Table. (See Figure 4-4.) The
IDT contains the descriptors which point to the location
of up to 256 interrupt service routines. The IDT
may contain only task gates, interrupt gates, and
trap gates. The IDT should be at least 256 bytes in
size in order to hold the descriptors for the 32 Intel
Reserved Interrupts. Every interrupt used by a system
must have an entry in the IDT. The IDT entries
are referenced via INT instructions, external interrupt
vectors, and exceptions. (See 2.9 Interrupts).
*/

module interrupt_descriptor_table_register (
    input  logic        IDTR_write_enable,
    input  logic [15:0] IDTR_write_data_limit,
    input  logic [31:0] IDTR_write_data_base,
    output logic [15:0] IDTR_limit,
    output logic [31:0] IDTR_base,
    input  logic        clock, reset
);

// IDTR (Interrupt Descriptor Table Register)

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        IDTR_limit <= 16'b0;
        IDTR_base <= 32'b0;
    end else begin
        if (IDTR_write_enable) begin
            IDTR_limit <= IDTR_write_data_limit;
            IDTR_base <= IDTR_write_data_base;
        end else begin
            IDTR_limit <= IDTR_limit;
            IDTR_base <= IDTR_base;
        end
    end
end

// IDT cache
// reg [63:0] IDT_cache [8192];=

endmodule
