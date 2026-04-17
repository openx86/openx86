/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements stage_5_wrb_general_propose_register.
*/
/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: stage_5_wrb_general_propose_register
create at: 2021-10-22 23:09:45
description: define the general propose register
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
2.3.1 General Purpose Registers
General Purpose Registers: The eight general purpose
registers of 32 bits hold data or address quantities.
The general registers, Figure 2-2, support data
operands of 1, 8, 16, 32 and 64 bits, and bit fields of
1 to 32 bits. They support address operands of 16
and 32 bits. The 32-bit registers are named EAX,
EBX, ECX, EDX, ESI, EDI, EBP, and ESP.
The least significant 16 bits of the registers can be
accessed separately. This is done by using the 16-
bit names of the registers AX, BX, CX, DX, SI, DI,
BP, and SP. When accessed as a 16-bit operand,
the upper 16 bits of the register are neither used nor
changed.
Finally 8-bit operations can individually access the
lowest byte (bits 0±7) and the higher byte (bits 8±
15) of general purpose registers AX, BX, CX and DX.
The lowest bytes are named AL, BL, CL and DL,
respectively. The higher bytes are named AH, BH,
CH and DH, respectively. The individual byte accessibility
offers additional flexibility for data operations,
but is not used for effective address calculation.
*/

module stage_5_wrb_general_propose_register (
    input  logic        write_enable,
    input  logic [ 2:  0]  write_index,
    input  logic [31:  0] write_data,
    output logic [31:  0] read__8 [ 0:  7],
    output logic [31:  0] read_16 [ 0:  7],
    output logic [31:  0] read_32 [ 0:  7],
    input  logic        reset_n,
    input  logic        clock);

// GENERAL DATA AND ADDRESS REGISTERS
logic [31:  0] general_register [ 0:  7];

always_ff @(posedge clock or negedge reset_n) begin : ff_basic_register
    if (~reset_n) begin
        for (int i = 0; i < 8; i++) begin
            general_register[i] <= 32'h0;
        end
    end else begin
        if (write_enable) begin
            general_register[write_index] <= write_data;
        end else begin
            // pass
        end
    end
end

always_comb begin
    for (int i = 0; i < 8; i++) begin
        read_32[i] = general_register[i];
        read_16[i] = {16'h0, general_register[i][15:  0]};
        read__8[i] = {24'h0, general_register[i][ 7:  0]};
    end
end

endmodule
