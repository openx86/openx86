/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: register_general_propose
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

module general_propose_register (
    // ports
    input  logic        write_enable,
    input  logic [ 2:0] write_index,
    input  logic [31:0] write_data,
    output logic [ 7:0] AL,
    output logic [ 7:0] BL,
    output logic [ 7:0] CL,
    output logic [ 7:0] DL,
    output logic [ 7:0] AH,
    output logic [ 7:0] BH,
    output logic [ 7:0] CH,
    output logic [ 7:0] DH,
    output logic [15:0] AX,
    output logic [15:0] BX,
    output logic [15:0] CX,
    output logic [15:0] DX,
    output logic [15:0] SI,
    output logic [15:0] DI,
    output logic [15:0] BP,
    output logic [15:0] SP,
    output logic [31:0] EAX,
    output logic [31:0] EBX,
    output logic [31:0] ECX,
    output logic [31:0] EDX,
    output logic [31:0] ESI,
    output logic [31:0] EDI,
    output logic [31:0] EBP,
    output logic [31:0] ESP,
    input  logic        clock, reset
);

// GENERAL DATA AND ADDRESS REGISTERS
reg   [31:0] general_register [8];

always_ff @( posedge clock or negedge reset ) begin : ff_basic_register
    if (reset) begin
        general_register[0] <= 32'b0;
        general_register[1] <= 32'b0;
        general_register[2] <= 32'b0;
        general_register[3] <= 32'b0;
        general_register[4] <= 32'b0;
        general_register[5] <= 32'b0;
        general_register[6] <= 32'b0;
        general_register[7] <= 32'b0;
    end else begin
        if (write_enable) begin
            general_register[write_index] <= write_data;
        end else begin
            // pass
        end
    end
end

assign AL   = general_register[0][ 7:0];
assign BL   = general_register[1][ 7:0];
assign CL   = general_register[2][ 7:0];
assign DL   = general_register[3][ 7:0];
assign AH   = general_register[0][15:8];
assign BH   = general_register[1][15:8];
assign CH   = general_register[2][15:8];
assign DH   = general_register[3][15:8];
assign AX   = general_register[0][31:0];
assign BX   = general_register[1][31:0];
assign CX   = general_register[2][31:0];
assign DX   = general_register[3][31:0];
assign SI   = general_register[4][15:0];
assign DI   = general_register[5][15:0];
assign BP   = general_register[6][15:0];
assign SP   = general_register[7][15:0];
assign EAX  = general_register[0][31:0];
assign EBX  = general_register[1][31:0];
assign ECX  = general_register[2][31:0];
assign EDX  = general_register[3][31:0];
assign ESI  = general_register[4][31:0];
assign EDI  = general_register[5][31:0];
assign EBP  = general_register[6][31:0];
assign ESP  = general_register[7][31:0];

endmodule
