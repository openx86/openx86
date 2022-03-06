// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: decode_tb
// create at: 2021-12-23 01:23:14
// description: test decode module

`timescale 1ns/1ns
`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_tb #(
    // parameters
) (
    // ports
);

logic  [7:0] instruction [0:15];
// logic        clock, reset;

// interface_opcode opcode_interface_instance ();

wire default_operand_size = `default_operation_size_32;

decode decode_instance_in_testbench (
    .i_default_operand_size ( default_operand_size ),
    .i_instruction ( instruction )
);

// always #1 clock = ~clock;

initial begin
    instruction[0:15] = {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};

    $monitor("%t: instruction=%p", $time, instruction);

    #2; instruction[0:6] = {8'h37, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("AAA");
    #2; instruction[0:6] = {8'hD5, 8'h0A, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("AAD");
    #2; instruction[0:6] = {8'hD4, 8'h0A, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("AAM");
    #2; instruction[0:6] = {8'h3F, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("AAS");
    #2; instruction[0:6] = {8'h66, 8'h11, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("ADC [1], ECX");
    #2; instruction[0:6] = {8'h66, 8'h13, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("ADC ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'h83, 8'hD1, 8'h01, 8'h00, 8'h00, 8'h00}; $display("ADC ECX, 1");
    #2; instruction[0:6] = {8'h14, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("ADC AX, 1");
    #2; instruction[0:6] = {8'h66, 8'h01, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("ADD [1], ECX");
    #2; instruction[0:6] = {8'h66, 8'h03, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("ADD ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'h83, 8'hC1, 8'h01, 8'h00, 8'h00, 8'h00}; $display("ADD ECX, 1");
    #2; instruction[0:6] = {8'h04, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("ADD AX, 1");
    #2; instruction[0:6] = {8'h66, 8'h21, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("AND [1], ECX");
    #2; instruction[0:6] = {8'h66, 8'h23, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("AND ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'h83, 8'hE1, 8'h01, 8'h00, 8'h00, 8'h00}; $display("AND ECX, 1");
    #2; instruction[0:6] = {8'h24, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("AND AX, 1");
    #2; instruction[0:6] = {8'h63, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("ARPL [1], CX");
    #2; instruction[0:6] = {8'h66, 8'h62, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("BOUND ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'hBC, 8'h0E, 8'h01, 8'h00, 8'h00}; $display("BSF ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'hBD, 8'h0E, 8'h01, 8'h00, 8'h00}; $display("BSR ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'hC9, 8'h00, 8'h00, 8'h00, 8'h00}; $display("BSWAP ECX");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'hBA, 8'h26, 8'h01, 8'h00, 8'h01}; $display("BT WORD [1], 1");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'hA3, 8'h0E, 8'h01, 8'h00, 8'h00}; $display("BT [1], ECX");
    #2; instruction[0:6] = {8'hE8, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CALL 1");
    #2; instruction[0:6] = {8'hFF, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CALL [1]");
    #2; instruction[0:6] = {8'h9A, 8'h01, 8'h00, 8'h01, 8'h00, 8'h00, 8'h00}; $display("CALL 1:1");
    #2; instruction[0:6] = {8'h67, 8'hFF, 8'h11, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CALL [ECX]");
    #2; instruction[0:6] = {8'h98, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CBW");
    #2; instruction[0:6] = {8'h66, 8'h99, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CDQ");
    #2; instruction[0:6] = {8'hF8, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CLC");
    #2; instruction[0:6] = {8'hFC, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CLD");
    #2; instruction[0:6] = {8'hFA, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CLI");
    #2; instruction[0:6] = {8'h0F, 8'h06, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CLTS");
    #2; instruction[0:6] = {8'hF5, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CMC");
    #2; instruction[0:6] = {8'h66, 8'h39, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("CMP [1], ECX");
    #2; instruction[0:6] = {8'h66, 8'h3B, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("CMP ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'h83, 8'hF9, 8'h01, 8'h00, 8'h00, 8'h00}; $display("CMP ECX, 1");
    #2; instruction[0:6] = {8'h3C, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CMP AX, 1");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'hB1, 8'h0E, 8'h01, 8'h00, 8'h00}; $display("CMPXCHG [1], ECX");
    #2; instruction[0:6] = {8'h0F, 8'hA2, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CPUID");
    #2; instruction[0:6] = {8'h99, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CWD");
    #2; instruction[0:6] = {8'h66, 8'h98, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CWDE");
    #2; instruction[0:6] = {8'h27, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("DAA");
    #2; instruction[0:6] = {8'h2F, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("DAS");
    #2; instruction[0:6] = {8'hFF, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("DEC WORD [1]");
    #2; instruction[0:6] = {8'h66, 8'h49, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("DEC ECX");
    #2; instruction[0:6] = {8'hF7, 8'h36, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("DIV WORD [1]");
    #2; instruction[0:6] = {8'hF4, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("HLT");
    #2; instruction[0:6] = {8'hF7, 8'h3E, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("IDIV WORD [1]");
    #2; instruction[0:6] = {8'h66, 8'hF7, 8'hEA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("IMUL EDX");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'hAF, 8'hD1, 8'h00, 8'h00, 8'h00}; $display("IMUL EDX, ECX");
    #2; instruction[0:6] = {8'h66, 8'h6B, 8'hD1, 8'h01, 8'h00, 8'h00, 8'h00}; $display("IMUL EDX, ECX, 1");
    #2; instruction[0:6] = {8'hE4, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("IN AL, 1");
    #2; instruction[0:6] = {8'hEC, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("IN AL, DX");
    #2; instruction[0:6] = {8'hFF, 8'h06, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("INC WORD [1]");
    #2; instruction[0:6] = {8'h66, 8'h41, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("INC ECX");
    #2; instruction[0:6] = {8'hCD, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("INT 1");
    #2; instruction[0:6] = {8'hCD, 8'h03, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("INT 3");
    #2; instruction[0:6] = {8'hCD, 8'h04, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("INT 4");
    #2; instruction[0:6] = {8'h0F, 8'h08, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("INVD");
    #2; instruction[0:6] = {8'h0F, 8'h01, 8'h3E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("INVLPG [1]");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'h38, 8'h82, 8'h0E, 8'h01, 8'h00}; $display("INVPCID ECX, [1]");
    #2; instruction[0:6] = {8'hCF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("IRET");
    #2; instruction[0:6] = {8'hE3, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("JCXZ 1");
    #2; instruction[0:6] = {8'hEB, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("JMP SHORT 1");
    #2; instruction[0:6] = {8'hE9, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("JMP 1");
    #2; instruction[0:6] = {8'hFF, 8'hE3, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("JMP BX");
    #2; instruction[0:6] = {8'hEA, 8'h01, 8'h00, 8'h01, 8'h00, 8'h00, 8'h00}; $display("JMP 1:1");
    #2; instruction[0:6] = {8'hEA, 8'h00, 8'h04, 8'hD5, 8'h04, 8'h00, 8'h00}; $display("JMP $+1024:1024");
    #2; instruction[0:6] = {8'h9F, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("LAHF");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'h02, 8'h0E, 8'h01, 8'h00, 8'h00}; $display("LAR ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'hC5, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("LDS ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'h8D, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("LEA ECX, [1]");
    #2; instruction[0:6] = {8'hC9, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("LEAVE");
    #2; instruction[0:6] = {8'h66, 8'hC4, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("LES ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'hB4, 8'h0E, 8'h01, 8'h00, 8'h00}; $display("LFS ECX, [1]");
    #2; instruction[0:6] = {8'h0F, 8'h01, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("LGDT [1]");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'hB5, 8'h0E, 8'h01, 8'h00, 8'h00}; $display("LGS ECX, [1]");
    #2; instruction[0:6] = {8'h0F, 8'h01, 8'h1E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("LIDT [1]");
    #2; instruction[0:6] = {8'h0F, 8'h00, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("LLDT [1]");
    #2; instruction[0:6] = {8'h0F, 8'h01, 8'h36, 8'h01, 8'h00, 8'h00, 8'h00}; $display("LMSW [1]");
    #2; instruction[0:6] = {8'hE2, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("LOOP 1");
    #2; instruction[0:6] = {8'hE1, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("LOOPZ 1");
    #2; instruction[0:6] = {8'hE0, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("LOOPNZ 1");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'h03, 8'h0E, 8'h01, 8'h00, 8'h00}; $display("LSL ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'hB2, 8'h0E, 8'h01, 8'h00, 8'h00}; $display("LSS ECX, [1]");
    #2; instruction[0:6] = {8'h0F, 8'h00, 8'h1E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("LTR [1]");
    #2; instruction[0:6] = {8'h2E, 8'h8B, 8'h08, 8'h00, 8'h00, 8'h00, 8'h00}; $display("MOV CX, CS:[BX+SI]");
    #2; instruction[0:6] = {8'h3E, 8'h8B, 8'h08, 8'h00, 8'h00, 8'h00, 8'h00}; $display("MOV CX, DS:[BX+SI]");
    #2; instruction[0:6] = {8'h26, 8'h8B, 8'h08, 8'h00, 8'h00, 8'h00, 8'h00}; $display("MOV CX, ES:[BX+SI]");
    #2; instruction[0:6] = {8'h64, 8'h8B, 8'h08, 8'h00, 8'h00, 8'h00, 8'h00}; $display("MOV CX, FS:[BX+SI]");
    #2; instruction[0:6] = {8'h65, 8'h8B, 8'h08, 8'h00, 8'h00, 8'h00, 8'h00}; $display("MOV CX, GS:[BX+SI]");
    #2; instruction[0:6] = {8'h36, 8'h8B, 8'h08, 8'h00, 8'h00, 8'h00, 8'h00}; $display("MOV CX, SS:[BX+SI]");
    #2; instruction[0:6] = {8'h0F, 8'h22, 8'hC0, 8'h00, 8'h00, 8'h00, 8'h00}; $display("MOV CR0, EAX");
    #2; instruction[0:6] = {8'h0F, 8'h20, 8'hC0, 8'h00, 8'h00, 8'h00, 8'h00}; $display("MOV EAX, CR0");
    #2; instruction[0:6] = {8'h0F, 8'h23, 8'hC0, 8'h00, 8'h00, 8'h00, 8'h00}; $display("MOV DR0, EAX");
    #2; instruction[0:6] = {8'h0F, 8'h21, 8'hC0, 8'h00, 8'h00, 8'h00, 8'h00}; $display("MOV EAX, DR0");
    #2; instruction[0:6] = {8'h0F, 8'h26, 8'hF0, 8'h00, 8'h00, 8'h00, 8'h00}; $display("MOV TR6, EAX");
    #2; instruction[0:6] = {8'h0F, 8'h24, 8'hF0, 8'h00, 8'h00, 8'h00, 8'h00}; $display("MOV EAX, TR6");
    #2; instruction[0:6] = {8'h8E, 8'h1E, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("MOV DS, [1]");
    #2; instruction[0:6] = {8'h8C, 8'h1E, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("MOV [1], DS");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'h38, 8'hF0, 8'h0E, 8'h01, 8'h00}; $display("MOVBE ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'h38, 8'hF1, 8'h0E, 8'h01, 8'h00}; $display("MOVBE [1], ECX");
    #2; instruction[0:6] = {8'h0F, 8'hBE, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("MOVSX WORD CX, [1]");
    #2; instruction[0:6] = {8'h0F, 8'hB6, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("MOVZX WORD CX, [1]");
    #2; instruction[0:6] = {8'hF7, 8'h26, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("MUL WORD [1]");
    #2; instruction[0:6] = {8'hF7, 8'h1E, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("NEG WORD [1]");
    #2; instruction[0:6] = {8'h90, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("NOP");
    #2; instruction[0:6] = {8'h0F, 8'h1F, 8'h06, 8'h01, 8'h00, 8'h00, 8'h00}; $display("NOP WORD [1]");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'h1F, 8'h06, 8'h01, 8'h00, 8'h00}; $display("NOP DWORD [1]");
    #2; instruction[0:6] = {8'hF7, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("NOT WORD [1]");
    #2; instruction[0:6] = {8'h66, 8'h09, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("OR [1], ECX");
    #2; instruction[0:6] = {8'h66, 8'h0B, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("OR ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'h83, 8'hC9, 8'h01, 8'h00, 8'h00, 8'h00}; $display("OR ECX, 1");
    #2; instruction[0:6] = {8'h0C, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("OR AX, 1");
    #2; instruction[0:6] = {8'h8F, 8'h06, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("POP WORD [1]");
    #2; instruction[0:6] = {8'h66, 8'h59, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("POP ECX");
    #2; instruction[0:6] = {8'h1F, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("POP DS");
    #2; instruction[0:6] = {8'h0F, 8'hA9, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("POP GS");
    #2; instruction[0:6] = {8'h61, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("POPA");
    #2; instruction[0:6] = {8'h9D, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("POPF");
    #2; instruction[0:6] = {8'hFF, 8'h36, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("PUSH WORD [1]");
    #2; instruction[0:6] = {8'h66, 8'h51, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("PUSH ECX");
    #2; instruction[0:6] = {8'h1E, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("PUSH DS");
    #2; instruction[0:6] = {8'h0F, 8'hA8, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("PUSH GS");
    #2; instruction[0:6] = {8'h6A, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("PUSH 1");
    #2; instruction[0:6] = {8'h60, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("PUSHA");
    #2; instruction[0:6] = {8'h9C, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("PUSHF");
    #2; instruction[0:6] = {8'h66, 8'hD1, 8'hD1, 8'h00, 8'h00, 8'h00, 8'h00}; $display("RCL ECX, 1");
    #2; instruction[0:6] = {8'h66, 8'hD3, 8'hD1, 8'h00, 8'h00, 8'h00, 8'h00}; $display("RCL ECX, CL");
    #2; instruction[0:6] = {8'h66, 8'hC1, 8'hD1, 8'h02, 8'h00, 8'h00, 8'h00}; $display("RCL ECX, 2");
    #2; instruction[0:6] = {8'h66, 8'hD1, 8'hD9, 8'h00, 8'h00, 8'h00, 8'h00}; $display("RCR ECX, 1");
    #2; instruction[0:6] = {8'h66, 8'hD3, 8'hD9, 8'h00, 8'h00, 8'h00, 8'h00}; $display("RCR ECX, CL");
    #2; instruction[0:6] = {8'h66, 8'hC1, 8'hD9, 8'h02, 8'h00, 8'h00, 8'h00}; $display("RCR ECX, 2");
    #2; instruction[0:6] = {8'h0F, 8'h32, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("RDMSR");
    #2; instruction[0:6] = {8'h0F, 8'h33, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("RDPMC");
    #2; instruction[0:6] = {8'h0F, 8'h31, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("RDTSC");
    #2; instruction[0:6] = {8'h0F, 8'h01, 8'hF9, 8'h00, 8'h00, 8'h00, 8'h00}; $display("RDTSCP");
    #2; instruction[0:6] = {8'hF3, 8'h66, 8'h6D, 8'h00, 8'h00, 8'h00, 8'h00}; $display("REP INSD");
    #2; instruction[0:6] = {8'hF3, 8'h66, 8'hAD, 8'h00, 8'h00, 8'h00, 8'h00}; $display("REP LODSD");
    #2; instruction[0:6] = {8'hF3, 8'h66, 8'hA5, 8'h00, 8'h00, 8'h00, 8'h00}; $display("REP MOVSD");
    #2; instruction[0:6] = {8'hF3, 8'h66, 8'h6F, 8'h00, 8'h00, 8'h00, 8'h00}; $display("REP OUTSD");
    #2; instruction[0:6] = {8'hF3, 8'h66, 8'hAB, 8'h00, 8'h00, 8'h00, 8'h00}; $display("REP STOSD");
    #2; instruction[0:6] = {8'hF3, 8'h66, 8'hA7, 8'h00, 8'h00, 8'h00, 8'h00}; $display("REPE CMPSD");
    #2; instruction[0:6] = {8'hF3, 8'h66, 8'hAF, 8'h00, 8'h00, 8'h00, 8'h00}; $display("REPE SCASD");
    #2; instruction[0:6] = {8'hF2, 8'h66, 8'hA7, 8'h00, 8'h00, 8'h00, 8'h00}; $display("REPNE CMPSD");
    #2; instruction[0:6] = {8'hF2, 8'h66, 8'hAF, 8'h00, 8'h00, 8'h00, 8'h00}; $display("REPNE SCASD");
    #2; instruction[0:6] = {8'hC3, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("RET");
    #2; instruction[0:6] = {8'hC2, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("RET 1");
    #2; instruction[0:6] = {8'hCB, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("RETF");
    #2; instruction[0:6] = {8'hCA, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("RETF 1");
    #2; instruction[0:6] = {8'h66, 8'hD1, 8'hC1, 8'h00, 8'h00, 8'h00, 8'h00}; $display("ROL ECX, 1");
    #2; instruction[0:6] = {8'h66, 8'hD3, 8'hC1, 8'h00, 8'h00, 8'h00, 8'h00}; $display("ROL ECX, CL");
    #2; instruction[0:6] = {8'h66, 8'hC1, 8'hC1, 8'h02, 8'h00, 8'h00, 8'h00}; $display("ROL ECX, 2");
    #2; instruction[0:6] = {8'h66, 8'hD1, 8'hC9, 8'h00, 8'h00, 8'h00, 8'h00}; $display("ROR ECX, 1");
    #2; instruction[0:6] = {8'h66, 8'hD3, 8'hC9, 8'h00, 8'h00, 8'h00, 8'h00}; $display("ROR ECX, CL");
    #2; instruction[0:6] = {8'h66, 8'hC1, 8'hC9, 8'h02, 8'h00, 8'h00, 8'h00}; $display("ROR ECX, 2");
    #2; instruction[0:6] = {8'h0F, 8'hAA, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("RSM");
    #2; instruction[0:6] = {8'h9E, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SAHF");
    #2; instruction[0:6] = {8'h66, 8'hD1, 8'hF9, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SAR ECX, 1");
    #2; instruction[0:6] = {8'h66, 8'hD3, 8'hF9, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SAR ECX, CL");
    #2; instruction[0:6] = {8'h66, 8'hC1, 8'hF9, 8'h02, 8'h00, 8'h00, 8'h00}; $display("SAR ECX, 2");
    #2; instruction[0:6] = {8'h66, 8'h19, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("SBB [1], ECX");
    #2; instruction[0:6] = {8'h66, 8'h1B, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("SBB ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'h83, 8'hD9, 8'h01, 8'h00, 8'h00, 8'h00}; $display("SBB ECX, 1");
    #2; instruction[0:6] = {8'h1C, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SBB AX, 1");
    #2; instruction[0:6] = {8'h0F, 8'h90, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SETO DL");
    #2; instruction[0:6] = {8'h0F, 8'h91, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SETNO DL");
    #2; instruction[0:6] = {8'h0F, 8'h92, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SETB DL");
    #2; instruction[0:6] = {8'h0F, 8'h93, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SETNB DL");
    #2; instruction[0:6] = {8'h0F, 8'h94, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SETE DL");
    #2; instruction[0:6] = {8'h0F, 8'h95, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SETNE DL");
    #2; instruction[0:6] = {8'h0F, 8'h96, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SETBE DL");
    #2; instruction[0:6] = {8'h0F, 8'h97, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SETNBE DL");
    #2; instruction[0:6] = {8'h0F, 8'h98, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SETS DL");
    #2; instruction[0:6] = {8'h0F, 8'h99, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SETNS DL");
    #2; instruction[0:6] = {8'h0F, 8'h9A, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SETP DL");
    #2; instruction[0:6] = {8'h0F, 8'h9B, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SETNP DL");
    #2; instruction[0:6] = {8'h0F, 8'h9C, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SETL DL");
    #2; instruction[0:6] = {8'h0F, 8'h9D, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SETNL DL");
    #2; instruction[0:6] = {8'h0F, 8'h9E, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SETLE DL");
    #2; instruction[0:6] = {8'h0F, 8'h9F, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SETNLE DL");
    #2; instruction[0:6] = {8'h0F, 8'h01, 8'h06, 8'h01, 8'h00, 8'h00, 8'h00}; $display("SGDT [1]");
    #2; instruction[0:6] = {8'h66, 8'hD1, 8'hE9, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SHR ECX, 1");
    #2; instruction[0:6] = {8'h66, 8'hD3, 8'hE9, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SHR ECX, CL");
    #2; instruction[0:6] = {8'h66, 8'hC1, 8'hE9, 8'h02, 8'h00, 8'h00, 8'h00}; $display("SHR ECX, 2");
    #2; instruction[0:6] = {8'h0F, 8'hAC, 8'hD0, 8'h01, 8'h00, 8'h00, 8'h00}; $display("SHRD AX, DX, 1");
    #2; instruction[0:6] = {8'h0F, 8'hAD, 8'hD0, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SHRD AX, DX, CL");
    #2; instruction[0:6] = {8'h0F, 8'h01, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("SIDT [1]");
    #2; instruction[0:6] = {8'h0F, 8'h00, 8'h06, 8'h01, 8'h00, 8'h00, 8'h00}; $display("SLDT [1]");
    #2; instruction[0:6] = {8'h0F, 8'h01, 8'h26, 8'h01, 8'h00, 8'h00, 8'h00}; $display("SMSW [1]");
    #2; instruction[0:6] = {8'hF9, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("STC");
    #2; instruction[0:6] = {8'hFD, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("STD");
    #2; instruction[0:6] = {8'hFB, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("STI");
    #2; instruction[0:6] = {8'h0F, 8'h00, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("STR [1]");
    #2; instruction[0:6] = {8'h66, 8'h29, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("SUB [1], ECX");
    #2; instruction[0:6] = {8'h66, 8'h2B, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("SUB ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'h83, 8'hE9, 8'h01, 8'h00, 8'h00, 8'h00}; $display("SUB ECX, 1");
    #2; instruction[0:6] = {8'h2C, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("SUB AX, 1");
    #2; instruction[0:6] = {8'h66, 8'h85, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("TEST [1], ECX");
    #2; instruction[0:6] = {8'h66, 8'h85, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("TEST ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'hF7, 8'hC1, 8'h01, 8'h00, 8'h00, 8'h00}; $display("TEST ECX, 1");
    #2; instruction[0:6] = {8'hA8, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("TEST AX, 1");
    #2; instruction[0:6] = {8'h0F, 8'h00, 8'hE1, 8'h00, 8'h00, 8'h00, 8'h00}; $display("VERR CX");
    #2; instruction[0:6] = {8'h9B, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("WAIT");
    #2; instruction[0:6] = {8'h0F, 8'h09, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("WBINVD");
    #2; instruction[0:6] = {8'h0F, 8'h30, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("WRMSR");
    #2; instruction[0:6] = {8'h66, 8'h0F, 8'hC1, 8'h0E, 8'h01, 8'h00, 8'h00}; $display("XADD [1], ECX");
    #2; instruction[0:6] = {8'h66, 8'h87, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("XCHG [1], ECX");
    #2; instruction[0:6] = {8'h66, 8'h87, 8'h06, 8'h01, 8'h00, 8'h00, 8'h00}; $display("XCHG [1], EAX");
    #2; instruction[0:6] = {8'hD7, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("XLAT");
    #2; instruction[0:6] = {8'h66, 8'h31, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("XOR [1], ECX");
    #2; instruction[0:6] = {8'h66, 8'h33, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("XOR ECX, [1]");
    #2; instruction[0:6] = {8'h66, 8'h83, 8'hF1, 8'h01, 8'h00, 8'h00, 8'h00}; $display("XOR ECX, 1");
    #2; instruction[0:6] = {8'h34, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("XOR AX, 1");

    #2; instruction[0:15] = {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
    #16;

    $stop();
end

endmodule
