/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: register_general
create at: 2021-10-22 23:09:45
description: define the basic register
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
2.2 REGISTER OVERVIEW
*/

module register_basic #(
    // parameters
) (
    // ports
    // input  logic        write_enable,
    // input  logic [ 4:0] write_index,
    // input  logic        write_data,
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
    output logic [15:0] IP,
    output logic [31:0] EIP,
    output logic [15:0] CS,
    output logic [15:0] SS,
    output logic [15:0] DS,
    output logic [15:0] ES,
    output logic [15:0] FS,
    output logic [15:0] GS,
    input  logic        clock, reset
);

// GENERAL DATA AND ADDRESS REGISTERS
reg   [31:0] AX_r;
reg   [31:0] BX_r;
reg   [31:0] CX_r;
reg   [31:0] DX_r;
reg   [31:0] SI_r;
reg   [31:0] DI_r;
reg   [31:0] BP_r;
reg   [31:0] SP_r;
// INSTRUCTION POINTER
reg   [31:0] IP_r;
// SEGMENT SELECTOR REGISTERS
reg   [15:0] CS_r;
reg   [15:0] SS_r;
reg   [15:0] DS_r;
reg   [15:0] ES_r;
reg   [15:0] FS_r;
reg   [15:0] GS_r;

always_ff @( posedge clock or negedge reset ) begin : ff_basic_register
    if (reset) begin
        AX_r <= 32'b0;
        BX_r <= 32'b0;
        CX_r <= 32'b0;
        DX_r <= 32'b0;
        SI_r <= 32'b0;
        DI_r <= 32'b0;
        BP_r <= 32'b0;
        SP_r <= 32'b0;
        IP_r <= 32'b0;
        CS_r <= 15'b0;
        SS_r <= 15'b0;
        DS_r <= 15'b0;
        ES_r <= 15'b0;
        FS_r <= 15'b0;
        GS_r <= 15'b0;
    end else begin
        // pass
    end
end

assign AL   = AX_r[ 7:0];
assign BL   = BX_r[ 7:0];
assign CL   = CX_r[ 7:0];
assign DL   = DX_r[ 7:0];
assign AH   = AX_r[15:8];
assign BH   = BX_r[15:8];
assign CH   = CX_r[15:8];
assign DH   = DX_r[15:8];
assign AX   = AX_r[31:0];
assign BX   = BX_r[31:0];
assign CX   = CX_r[31:0];
assign DX   = DX_r[31:0];
assign SI   = SI_r[15:0];
assign DI   = DI_r[15:0];
assign BP   = BP_r[15:0];
assign SP   = SP_r[15:0];
assign EAX  = AX_r[31:0];
assign EBX  = BX_r[31:0];
assign ECX  = CX_r[31:0];
assign EDX  = DX_r[31:0];
assign ESI  = SI_r[31:0];
assign EDI  = DI_r[31:0];
assign EBP  = BP_r[31:0];
assign ESP  = SP_r[31:0];
assign IP   = IP_r[15:0];
assign EIP  = IP_r[31:0];
assign CS   = CS_r;
assign SS   = SS_r;
assign DS   = DS_r;
assign ES   = ES_r;
assign FS   = FS_r;
assign GS   = GS_r;

endmodule
