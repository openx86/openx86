/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: instruction_point_register
create at: 2022-01-31 01:19:14
description: define the instruction point register
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
2.3.2 Instruction Pointer
The instruction pointer, Figure 2-2, is a 32-bit register
named EIP. EIP holds the offset of the next instruction
to be executed. The offset is always relative
to the base of the code segment (CS). The lower
16 bits (bits 0±15) of EIP contain the 16-bit instruction
pointer named IP, which is used by 16-bit
addressing.
*/

module instruction_point_register (
    // ports
    input  logic        write_enable,
    input  logic [31:0] write_data,
    output logic [15:0] IP,
    output logic [31:0] EIP,
    input  logic        clock, reset
);

reg   [31:0] instruction_point;

always_ff @( posedge clock or posedge reset ) begin
    if (reset) begin
        instruction_point <= 32'h0000_FFF0;
    end else begin
        if (write_enable) begin
            instruction_point <= write_data;
        end
    end
end

assign IP   = instruction_point[15:0];
assign EIP  = instruction_point[31:0];

endmodule
