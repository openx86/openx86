// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: decode_general_general_register_tb
// create at: 2021-10-22 02:29:28
// description: test decode_general_general_register module

`timescale 1ns/1ns
module decode_general_register_tb #(
    // parameters
) (
    // ports
);

logic [2:0] instruction_reg;
logic       bit_width_16;
logic       bit_width_32;
logic       w_is_present;
logic       w;
logic       AL;
logic       CL;
logic       DL;
logic       BL;
logic       AH;
logic       CH;
logic       DH;
logic       BH;
logic       AX;
logic       CX;
logic       DX;
logic       BX;
logic       SP;
logic       BP;
logic       SI;
logic       DI;
logic       EAX;
logic       ECX;
logic       EDX;
logic       EBX;
logic       ESP;
logic       EBP;
logic       ESI;
logic       EDI;

decode_general_register decode_general_register_inst (
    .instruction_reg ( instruction_reg ),
    .bit_width_16 ( bit_width_16 ),
    .bit_width_32 ( bit_width_32 ),
    .w_is_present ( w_is_present ),
    .w ( w ),
    .AL ( AL ),
    .CL ( CL ),
    .DL ( DL ),
    .BL ( BL ),
    .AH ( AH ),
    .CH ( CH ),
    .DH ( DH ),
    .BH ( BH ),
    .AX ( AX ),
    .CX ( CX ),
    .DX ( DX ),
    .BX ( BX ),
    .SP ( SP ),
    .BP ( BP ),
    .SI ( SI ),
    .DI ( DI ),
    .EAX ( EAX ),
    .ECX ( ECX ),
    .EDX ( EDX ),
    .EBX ( EBX ),
    .ESP ( ESP ),
    .EBP ( EBP ),
    .ESI ( ESI ),
    .EDI ( EDI )
);

reg [3:0] i;

initial begin
    instruction_reg = 0;
    bit_width_16 = 0;
    bit_width_32 = 0;
    w_is_present = 0;
    w = 0;

    $monitor("%t: instruction_reg=%h, bit_width 16_32=%h_%h, w_is_present=%h, w=%h", $time, instruction_reg, bit_width_16, bit_width_32, w_is_present, w);
    $monitor("%t:  AL=%h,  CL=%h,  DL=%h,  BL=%h,  AH=%h,  CH=%h,  DH=%h,  BH=%h", $time, AL, CL, DL, BL, AH, CH, DH, BH);
    $monitor("%t:  AX=%h,  CX=%h,  DX=%h,  BX=%h,  SP=%h,  BP=%h,  SI=%h,  DI=%h", $time, AX, CX, DX, BX, SP, BP, SI, DI);
    $monitor("%t: EAX=%h, ECX=%h, EDX=%h, EBX=%h, ESP=%h, EBP=%h, ESI=%h, EDI=%h", $time, EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI);

    #1;
    w_is_present = 0;
    bit_width_16 = 1;
    bit_width_32 = 0;
    for(i=0;i<8;i=i+1) begin
        instruction_reg = i;
        #1;
    end

    #1;
    w_is_present = 0;
    bit_width_16 = 0;
    bit_width_32 = 1;
    for(i=0;i<8;i=i+1) begin
        instruction_reg = i;
        #1;
    end

    #1;
    w_is_present = 1;
    w = 1;
    bit_width_16 = 1;
    bit_width_32 = 0;
    for(i=0;i<8;i=i+1) begin
        instruction_reg = i;
        #1;
    end

    #1;
    w_is_present = 1;
    w = 1;
    bit_width_16 = 0;
    bit_width_32 = 1;
    for(i=0;i<8;i=i+1) begin
        instruction_reg = i;
        #1;
    end

    #1;
    w_is_present = 1;
    w = 0;
    bit_width_16 = 1;
    bit_width_32 = 0;
    for(i=0;i<8;i=i+1) begin
        instruction_reg = i;
        #1;
    end

    #1;
    w_is_present = 1;
    w = 0;
    bit_width_16 = 0;
    bit_width_32 = 1;
    for(i=0;i<8;i=i+1) begin
        instruction_reg = i;
        #1;
    end

    instruction_reg = 0;
    bit_width_16 = 0;
    bit_width_32 = 0;
    w_is_present = 0;
    w = 0;

    #16;
    $stop();
end

endmodule
