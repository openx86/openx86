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
    input  logic        write_enable,
    input  logic [ 2:0] write_index,
    input  logic [31:0] write_data,
    output logic [31:0] read__8 [0:7],
    output logic [31:0] read_16 [0:7],
    output logic [31:0] read_32 [0:7],
    input  logic        clock, reset
);

// GENERAL DATA AND ADDRESS REGISTERS
reg   [31:0] general_register [8];

always_ff @( posedge clock or posedge reset ) begin : ff_basic_register
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

// below signal is generated for debug
wire [ 7:0]  AL  = general_register[0][ 7:0];
wire [ 7:0]  BL  = general_register[1][ 7:0];
wire [ 7:0]  CL  = general_register[2][ 7:0];
wire [ 7:0]  DL  = general_register[3][ 7:0];
wire [ 7:0]  AH  = general_register[0][15:8];
wire [ 7:0]  BH  = general_register[1][15:8];
wire [ 7:0]  CH  = general_register[2][15:8];
wire [ 7:0]  DH  = general_register[3][15:8];
wire [31:0]  AX  = general_register[0][31:0];
wire [31:0]  CX  = general_register[1][31:0];
wire [31:0]  DX  = general_register[2][31:0];
wire [31:0]  BX  = general_register[3][31:0];
wire [31:0]  SP  = general_register[4][15:0];
wire [15:0]  BP  = general_register[5][15:0];
wire [15:0]  SI  = general_register[6][15:0];
wire [15:0]  DI  = general_register[7][15:0];
wire [31:0] EAX  = general_register[0][31:0];
wire [31:0] ECX  = general_register[1][31:0];
wire [31:0] EDX  = general_register[2][31:0];
wire [31:0] EBX  = general_register[3][31:0];
wire [31:0] ESP  = general_register[4][31:0];
wire [31:0] EBP  = general_register[5][31:0];
wire [31:0] ESI  = general_register[6][31:0];
wire [31:0] EDI  = general_register[7][31:0];

assign read__8[0] =  AL;
assign read__8[1] =  BL;
assign read__8[2] =  CL;
assign read__8[3] =  DL;
assign read__8[4] =  AH;
assign read__8[5] =  BH;
assign read__8[6] =  CH;
assign read__8[7] =  DH;
assign read_16[0] =  AX;
assign read_16[1] =  CX;
assign read_16[2] =  DX;
assign read_16[3] =  BX;
assign read_16[4] =  SP;
assign read_16[5] =  BP;
assign read_16[6] =  SI;
assign read_16[7] =  DI;
assign read_32[0] = EAX;
assign read_32[1] = ECX;
assign read_32[2] = EDX;
assign read_32[3] = EBX;
assign read_32[4] = ESP;
assign read_32[5] = EBP;
assign read_32[6] = ESI;
assign read_32[7] = EDI;

endmodule
