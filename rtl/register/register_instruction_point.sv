/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: register_instruction_point
create at: 2021-10-22 23:27:32
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

module register_instruction_point #(
    // parameters
) (
    // ports
    input  logic        write_enable,
    input  logic [31:0] write_data,
    output logic [15:0] IP,
    output logic [31:0] EIP,
    input  logic        clock, reset
);

reg   [31:0] IP_r;

always_ff @( posedge clock or negedge reset ) begin : ff_instruction_point_register
    if (reset) begin
        IP_r <= 32'b0;
    end else begin
        if (write_enable) begin
            IP_r <= write_data;
        end
    end
end

assign IP   = IP_r[15:0];
assign EIP  = IP_r[31:0];

endmodule
