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
logic[241:0] opcode;
// logic        clock, reset;

// interface_opcode opcode_interface_instance ();

wire default_operand_size = `default_operation_size_16;

decode decode_instance_in_testbench (
    .i_default_operand_size ( default_operand_size ),
    .i_instruction ( instruction ),
    .o_opcode ( opcode )
);

// always #1 clock = ~clock;

initial begin
    instruction[0:15] = {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};

    $monitor("%t: instruction=%p", $time, instruction);

    #2; instruction[0:5] = {8'h89, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("890E0100                mov [1], cx");
    #2; instruction[0:5] = {8'h8B, 8'h1E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("8B1E0100                mov bx, [1]");
    #2; instruction[0:5] = {8'hC7, 8'h06, 8'h01, 8'h00, 8'h01, 8'h00}; $display("C70601000100            mov word [1], 1");
    #2; instruction[0:5] = {8'hBB, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("BB0100                  mov bx, 1");
    #2; instruction[0:5] = {8'hA1, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("A10100                  mov ax, [1]");
    #2; instruction[0:5] = {8'hA3, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("A30100                  mov [1], ax");
    #2; instruction[0:5] = {8'h8E, 8'h1E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("8E1E0100                mov ds, [1]");
    #2; instruction[0:5] = {8'h8C, 8'h1E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("8C1E0100                mov [1], ds");

    // #1; instruction[0:5] = {8'h66, 8'h0F, 8'hBF, 8'hD9, 8'h00, 8'h00}; $display("660FBFD9                prefix movsx ebx, cx");
    // #1; instruction[0:5] = {8'h66, 8'h0F, 8'hB7, 8'hD9, 8'h00, 8'h00}; $display("660FB7D9                prefix movzx ebx, cx");

    #2; instruction[0:5] = {8'h0F, 8'hBF, 8'hD9, 8'h00, 8'h00, 8'h00}; $display("0FBFD9                  movsx ebx, cx");
    #2; instruction[0:5] = {8'h0F, 8'hB7, 8'hD9, 8'h00, 8'h00, 8'h00}; $display("0FB7D9                  movzx ebx, cx");

    #2; instruction[0:5] = {8'hFF, 8'h36, 8'h01, 8'h00, 8'h00, 8'h00}; $display("FF360100                push word [1]");
    #2; instruction[0:5] = {8'h53, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("53                      push bx");
    #2; instruction[0:5] = {8'h1E, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("1E                      push ds");
    #2; instruction[0:5] = {8'h0F, 8'hA8, 8'h01, 8'h00, 8'h00, 8'h00}; $display("0FA8                    push gs");
    #2; instruction[0:5] = {8'h6A, 8'h01, 8'h01, 8'h00, 8'h00, 8'h00}; $display("6A01                    push 1");
    #2; instruction[0:5] = {8'h60, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("60                      pusha");

    #2; instruction[0:5] = {8'h8F, 8'h06, 8'h01, 8'h00, 8'h00, 8'h00}; $display("8F060100                pop word [1]");
    #2; instruction[0:5] = {8'h5B, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("5B                      pop bx");
    #2; instruction[0:5] = {8'h1F, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("1F                      pop ds");
    #2; instruction[0:5] = {8'h0F, 8'hA9, 8'h00, 8'h00, 8'h00, 8'h00}; $display("0FA9                    pop gs");
    #2; instruction[0:5] = {8'h61, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("61                      popa");

    #2; instruction[0:5] = {8'h87, 8'h1E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("871E0100                xchg bx, word [1]");
    #2; instruction[0:5] = {8'h93, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("93                      xchg bx, ax");

    #2; instruction[0:5] = {8'hE4, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("E401                    in al, 1");
    #2; instruction[0:5] = {8'hEC, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("EC                      in al, dx");

    #2; instruction[0:5] = {8'hE6, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("E601                    out 1, al");
    #2; instruction[0:5] = {8'hEE, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("EE                      out dx, al");

    #2; instruction[0:5] = {8'h8D, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("8D160100                LEA DX, [1]");

    #2; instruction[0:5] = {8'hC5, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("C5160100                LDS DX, [1]");
    #2; instruction[0:5] = {8'hC4, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("C4160100                LES DX, [1]");
    #2; instruction[0:5] = {8'h0F, 8'hB4, 8'h16, 8'h01, 8'h00, 8'h00}; $display("0FB4160100              LFS DX, [1]");
    #2; instruction[0:5] = {8'h0F, 8'hB5, 8'h16, 8'h01, 8'h00, 8'h00}; $display("0FB5160100              LGS DX, [1]");
    #2; instruction[0:5] = {8'h0F, 8'hB2, 8'h16, 8'h01, 8'h00, 8'h00}; $display("0FB2160100              LSS DX, [1]");

    #2; instruction[0:5] = {8'hF8, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F8                      CLC");
    #2; instruction[0:5] = {8'hFC, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("FC                      CLD");
    #2; instruction[0:5] = {8'hFA, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("FA                      CLI");
    #2; instruction[0:5] = {8'h0F, 8'h06, 8'h00, 8'h00, 8'h00, 8'h00}; $display("0F06                    CLTS");
    #2; instruction[0:5] = {8'hF5, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F5                      CMC");
    #2; instruction[0:5] = {8'h9F, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("9F                      LAHF");
    #2; instruction[0:5] = {8'h9D, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("9D                      POPF");
    #2; instruction[0:5] = {8'h9C, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("9C                      PUSHF");
    #2; instruction[0:5] = {8'h9E, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("9E                      SAHF");
    #2; instruction[0:5] = {8'hF9, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F9                      STC");
    #2; instruction[0:5] = {8'hFD, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("FD                      STD");
    #2; instruction[0:5] = {8'hFB, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("FB                      STI");

    #2; instruction[0:5] = {8'h01, 8'hCA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("01CA                    ADD DX, CX");
    #2; instruction[0:5] = {8'h01, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("01160100                ADD [1], DX");
    #2; instruction[0:5] = {8'h03, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("03160100                ADD DX, [1]");
    #2; instruction[0:5] = {8'h83, 8'hC2, 8'h01, 8'h00, 8'h00, 8'h00}; $display("83C201                  ADD DX, 1");
    #2; instruction[0:5] = {8'h04, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("0401                    ADD AL, 1");

    #2; instruction[0:5] = {8'h11, 8'hCA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("11CA                    ADC DX, CX");
    #2; instruction[0:5] = {8'h11, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("11160100                ADC [1], DX");
    #2; instruction[0:5] = {8'h13, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("13160100                ADC DX, [1]");
    #2; instruction[0:5] = {8'h83, 8'hD2, 8'h01, 8'h00, 8'h00, 8'h00}; $display("83D201                  ADC DX, 1");
    #2; instruction[0:5] = {8'h14, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("1401                    ADC AL, 1");

    #2; instruction[0:5] = {8'hFF, 8'h06, 8'h01, 8'h00, 8'h00, 8'h00}; $display("FF060100                INC WORD [1]");
    #2; instruction[0:5] = {8'h42, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("42                      INC DX");

    #2; instruction[0:5] = {8'h29, 8'hCA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("29CA                    SUB DX, CX");
    #2; instruction[0:5] = {8'h29, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("29160100                SUB [1], DX");
    #2; instruction[0:5] = {8'h2B, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("2B160100                SUB DX, [1]");
    #2; instruction[0:5] = {8'h83, 8'hEA, 8'h01, 8'h00, 8'h00, 8'h00}; $display("83EA01                  SUB DX, 1");
    #2; instruction[0:5] = {8'h2C, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("2C01                    SUB AL, 1");

    #2; instruction[0:5] = {8'h19, 8'hCA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("19CA                    SBB DX, CX");
    #2; instruction[0:5] = {8'h19, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("19160100                SBB [1], DX");
    #2; instruction[0:5] = {8'h1B, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("1B160100                SBB DX, [1]");
    #2; instruction[0:5] = {8'h83, 8'hDA, 8'h01, 8'h00, 8'h00, 8'h00}; $display("83DA01                  SBB DX, 1");
    #2; instruction[0:5] = {8'h1C, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("1C01                    SBB AL, 1");

    #2; instruction[0:5] = {8'hFF, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("FF0E0100                DEC WORD [1]");
    #2; instruction[0:5] = {8'h4A, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("4A                      DEC DX");

    #2; instruction[0:5] = {8'h39, 8'hCA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("39CA                    CMP DX, CX");
    #2; instruction[0:5] = {8'h39, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("39160100                CMP [1], DX");
    #2; instruction[0:5] = {8'h3B, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("3B160100                CMP DX, [1]");
    #2; instruction[0:5] = {8'h83, 8'hFA, 8'h01, 8'h00, 8'h00, 8'h00}; $display("83FA01                  CMP DX, 1");
    #2; instruction[0:5] = {8'h3C, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("3C01                    CMP AL, 1");

    #2; instruction[0:5] = {8'hF7, 8'hDA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F7DA                    NEG DX");

    #2; instruction[0:5] = {8'h37, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("37                      AAA");
    #2; instruction[0:5] = {8'h3F, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("3F                      AAS");
    #2; instruction[0:5] = {8'h27, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("27                      DAA");
    #2; instruction[0:5] = {8'h2F, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("2F                      DAS");

    #2; instruction[0:5] = {8'hF6, 8'hE0, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F6E0                    MUL AL");
    #2; instruction[0:5] = {8'hF7, 8'hE0, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F7E0                    MUL AX");
    #2; instruction[0:5] = {8'h66, 8'hF7, 8'hE0, 8'h00, 8'h00, 8'h00}; $display("66F7E0                  MUL EAX");

    #2; instruction[0:5] = {8'hF7, 8'hEA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F7EA                    IMUL DX");
    #2; instruction[0:5] = {8'h0F, 8'hAF, 8'hD1, 8'h00, 8'h00, 8'h00}; $display("0FAFD1                  IMUL DX, CX");
    #2; instruction[0:5] = {8'h6B, 8'hD1, 8'h01, 8'h00, 8'h00, 8'h00}; $display("6BD101                  IMUL DX, CX, 1");

    #2; instruction[0:5] = {8'hF7, 8'hF2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F7F2                    DIV DX");
    #2; instruction[0:5] = {8'hF7, 8'hFA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F7FA                    IDIV DX");

    #2; instruction[0:5] = {8'hD5, 8'h0A, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D50A                    AAD");
    #2; instruction[0:5] = {8'hD4, 8'h0A, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D40A                    AAM");
    #2; instruction[0:5] = {8'h98, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("98                      CBW");
    #2; instruction[0:5] = {8'h99, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("99                      CWD");

    #2; instruction[0:5] = {8'hD1, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D1C2                    ROL DX, 1");
    #2; instruction[0:5] = {8'hD3, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D3C2                    ROL DX, CL");
    #2; instruction[0:5] = {8'hC1, 8'hC2, 8'h02, 8'h00, 8'h00, 8'h00}; $display("C1C202                  ROL DX, 2");

    #2; instruction[0:5] = {8'hD1, 8'hCA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D1CA                    ROR DX, 1");
    #2; instruction[0:5] = {8'hD3, 8'hCA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D3CA                    ROR DX, CL");
    #2; instruction[0:5] = {8'hC1, 8'hCA, 8'h02, 8'h00, 8'h00, 8'h00}; $display("C1CA02                  ROR DX, 2");

    #2; instruction[0:5] = {8'hD1, 8'hE2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D1E2                    SAL DX, 1");
    #2; instruction[0:5] = {8'hD3, 8'hE2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D3E2                    SAL DX, CL");
    #2; instruction[0:5] = {8'hC1, 8'hE2, 8'h02, 8'h00, 8'h00, 8'h00}; $display("C1E202                  SAL DX, 2");

    #2; instruction[0:5] = {8'hD1, 8'hFA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D1FA                    SAR DX, 1");
    #2; instruction[0:5] = {8'hD3, 8'hFA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D3FA                    SAR DX, CL");
    #2; instruction[0:5] = {8'hC1, 8'hFA, 8'h02, 8'h00, 8'h00, 8'h00}; $display("C1FA02                  SAR DX, 2");

    #2; instruction[0:5] = {8'hD1, 8'hEA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D1EA                    SHR DX, 1");
    #2; instruction[0:5] = {8'hD3, 8'hEA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D3EA                    SHR DX, CL");
    #2; instruction[0:5] = {8'hC1, 8'hEA, 8'h02, 8'h00, 8'h00, 8'h00}; $display("C1EA02                  SHR DX, 2");

    #2; instruction[0:5] = {8'hD1, 8'hD2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D1D2                    RCL DX, 1");
    #2; instruction[0:5] = {8'hD3, 8'hD2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D3D2                    RCL DX, CL");
    #2; instruction[0:5] = {8'hC1, 8'hD2, 8'h02, 8'h00, 8'h00, 8'h00}; $display("C1D202                  RCL DX, 2");

    #2; instruction[0:5] = {8'hD1, 8'hDA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D1DA                    RCR DX, 1");
    #2; instruction[0:5] = {8'hD3, 8'hDA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D3DA                    RCR DX, CL");
    #2; instruction[0:5] = {8'hC1, 8'hDA, 8'h02, 8'h00, 8'h00, 8'h00}; $display("C1DA02                  RCR DX, 2");

    #2; instruction[0:5] = {8'h0F, 8'hA4, 8'hD0, 8'h01, 8'h00, 8'h00}; $display("0FA4D001                SHLD AX, DX, 1");
    #2; instruction[0:5] = {8'h0F, 8'hA5, 8'hD0, 8'h00, 8'h00, 8'h00}; $display("0FA5D0                  SHLD AX, DX, CL");

    #2; instruction[0:5] = {8'h0F, 8'hAC, 8'hD0, 8'h01, 8'h00, 8'h00}; $display("0FACD001                SHRD AX, DX, 1");
    #2; instruction[0:5] = {8'h0F, 8'hAD, 8'hD0, 8'h00, 8'h00, 8'h00}; $display("0FADD0                  SHRD AX, DX, CL");

    #2; instruction[0:5] = {8'h21, 8'hCA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("21CA                    AND DX, CX");
    #2; instruction[0:5] = {8'h21, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("21160100                AND [1], DX");
    #2; instruction[0:5] = {8'h23, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("23160100                AND DX, [1]");
    #2; instruction[0:5] = {8'h83, 8'hE2, 8'h01, 8'h00, 8'h00, 8'h00}; $display("83E201                  AND DX, 1");
    #2; instruction[0:5] = {8'h24, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("2401                    AND AL, 1");

    #2; instruction[0:5] = {8'h85, 8'hCA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("85CA                    TEST DX, CX");
    #2; instruction[0:5] = {8'hF6, 8'hC2, 8'h01, 8'h00, 8'h00, 8'h00}; $display("F6C201                  TEST DL, 1");
    #2; instruction[0:5] = {8'hA8, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("A801                    TEST AL, 1");

    #2; instruction[0:5] = {8'h09, 8'hCA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("09CA                    OR DX, CX");
    #2; instruction[0:5] = {8'h09, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("09160100                OR [1], DX");
    #2; instruction[0:5] = {8'h0B, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("0B160100                OR DX, [1]");
    #2; instruction[0:5] = {8'h83, 8'hCA, 8'h01, 8'h00, 8'h00, 8'h00}; $display("83CA01                  OR DX, 1");
    #2; instruction[0:5] = {8'h0C, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("0C01                    OR AL, 1");

    #2; instruction[0:5] = {8'h31, 8'hCA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("31CA                    XOR DX, CX");
    #2; instruction[0:5] = {8'h31, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("31160100                XOR [1], DX");
    #2; instruction[0:5] = {8'h33, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("33160100                XOR DX, [1]");
    #2; instruction[0:5] = {8'h83, 8'hF2, 8'h01, 8'h00, 8'h00, 8'h00}; $display("83F201                  XOR DX, 1");
    #2; instruction[0:5] = {8'h34, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("3401                    XOR AL, 1");

    #2; instruction[0:5] = {8'hF7, 8'hD2, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F7D2                    NOT DX");

    #2; instruction[0:5] = {8'hA6, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("A6                      CMPSB");
    #2; instruction[0:5] = {8'h6C, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("6C                      INSB");
    #2; instruction[0:5] = {8'hAC, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("AC                      LODSB");
    #2; instruction[0:5] = {8'hA4, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("A4                      MOVSB");
    #2; instruction[0:5] = {8'h6E, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("6E                      OUTSB");
    #2; instruction[0:5] = {8'hAE, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("AE                      SCASB");
    #2; instruction[0:5] = {8'hAA, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("AA                      STOSB");
    #2; instruction[0:5] = {8'hD7, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("D7                      XLATB");

    #2; instruction[0:5] = {8'hF3, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F3                      REPE");
    #2; instruction[0:5] = {8'hF2, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F2                      REPNE");

    #2; instruction[0:5] = {8'hF3, 8'hA6, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F3A6                    REPE CMPSB");
    #2; instruction[0:5] = {8'hF2, 8'hA6, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F2A6                    REPNE CMPSB");
    #2; instruction[0:5] = {8'hF3, 8'h6C, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F36C                    REP INSB");
    #2; instruction[0:5] = {8'hF3, 8'hAC, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F3AC                    REP LODSB");
    #2; instruction[0:5] = {8'hF3, 8'hA4, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F3A4                    REP MOVSB");
    #2; instruction[0:5] = {8'hF3, 8'h6E, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F36E                    REP OUTSB");
    #2; instruction[0:5] = {8'hF3, 8'hAE, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F3AE                    REPE SCASB");
    #2; instruction[0:5] = {8'hF3, 8'hAA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F3AA                    REP STOSB");

    #2; instruction[0:5] = {8'h0F, 8'hBC, 8'hD1, 8'h00, 8'h00, 8'h00}; $display("0FBCD1                  BSF dx, cx");
    #2; instruction[0:5] = {8'h0F, 8'hBD, 8'hD1, 8'h00, 8'h00, 8'h00}; $display("0FBDD1                  BSR dx, cx");
    #2; instruction[0:5] = {8'h0F, 8'hBA, 8'hE2, 8'h01, 8'h00, 8'h00}; $display("0FBAE201                BT dx, 1");
    #2; instruction[0:5] = {8'h0F, 8'hA3, 8'hCA, 8'h00, 8'h00, 8'h00}; $display("0FA3CA                  BT dx, cx");
    #2; instruction[0:5] = {8'h0F, 8'hBA, 8'hFA, 8'h01, 8'h00, 8'h00}; $display("0FBAFA01                BTC dx, 1");
    #2; instruction[0:5] = {8'h0F, 8'hBB, 8'hCA, 8'h00, 8'h00, 8'h00}; $display("0FBBCA                  BTC dx, cx");
    #2; instruction[0:5] = {8'h0F, 8'hBA, 8'hF2, 8'h01, 8'h00, 8'h00}; $display("0FBAF201                BTR dx, 1");
    #2; instruction[0:5] = {8'h0F, 8'hB3, 8'hCA, 8'h00, 8'h00, 8'h00}; $display("0FB3CA                  BTR dx, cx");
    #2; instruction[0:5] = {8'h0F, 8'hBA, 8'hEA, 8'h01, 8'h00, 8'h00}; $display("0FBAEA01                BTS dx, 1");
    #2; instruction[0:5] = {8'h0F, 8'hAB, 8'hCA, 8'h00, 8'h00, 8'h00}; $display("0FABCA                  BTS dx, cx");

    #2; instruction[0:5] = {8'hE8, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("E8(0100)                CALL 1");
    #2; instruction[0:5] = {8'hFF, 8'h16, 8'hA3, 8'h01, 8'h00, 8'h00}; $display("FF16[A301]              CALL [1+$]");
    #2; instruction[0:5] = {8'h9A, 8'h01, 8'h00, 8'h01, 8'h00, 8'h00}; $display("9A01000100              CALL 1:1");
    #2; instruction[0:5] = {8'hFF, 8'h97, 8'hAB, 8'h01, 8'h00, 8'h00}; $display("FF97[AB01]              CALL [BX+$]");

    #2; instruction[0:5] = {8'hEB, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("EB(01)                  JMP SHORT 1");
    #2; instruction[0:5] = {8'hE9, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("E9(0100)                JMP 1");
    #2; instruction[0:5] = {8'hFF, 8'hE3, 8'h00, 8'h00, 8'h00, 8'h00}; $display("FFE3                    JMP BX");
    #2; instruction[0:5] = {8'hEA, 8'h01, 8'h00, 8'h01, 8'h00, 8'h00}; $display("EA01000100              JMP 1:1");
    #2; instruction[0:5] = {8'hEA, 8'hAC, 8'h01, 8'h01, 8'h00, 8'h00}; $display("EA[AC01]0100            JMP 1:$+1");

    #2; instruction[0:5] = {8'hC3, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("C3                      RET");
    #2; instruction[0:5] = {8'hC2, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("C20100                  RET 1");
    #2; instruction[0:5] = {8'hCB, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CB                      RETF");
    #2; instruction[0:5] = {8'hCA, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CA0100                  RETF 1");

    #2; instruction[0:5] = {8'h70, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("70(01)                  JO SHORT 1");
    #2; instruction[0:5] = {8'h0F, 8'h80, 8'h34, 8'h12, 8'h00, 8'h00}; $display("0F80(3412)              JO 1234H");
    #2; instruction[0:5] = {8'h71, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("71(01)                  JNO SHORT 1");
    #2; instruction[0:5] = {8'h0F, 8'h81, 8'h34, 8'h12, 8'h00, 8'h00}; $display("0F81(3412)              JNO 1234H");
    #2; instruction[0:5] = {8'h72, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("72(01)                  JB SHORT 1");
    #2; instruction[0:5] = {8'h0F, 8'h82, 8'h34, 8'h12, 8'h00, 8'h00}; $display("0F82(3412)              JB 1234H");
    #2; instruction[0:5] = {8'h73, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("73(01)                  JNB SHORT 1");
    #2; instruction[0:5] = {8'h0F, 8'h83, 8'h34, 8'h12, 8'h00, 8'h00}; $display("0F83(3412)              JNB 1234H");
    #2; instruction[0:5] = {8'h74, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("74(01)                  JE SHORT 1");
    #2; instruction[0:5] = {8'h0F, 8'h84, 8'h34, 8'h12, 8'h00, 8'h00}; $display("0F84(3412)              JE 1234H");
    #2; instruction[0:5] = {8'h75, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("75(01)                  JNE SHORT 1");
    #2; instruction[0:5] = {8'h0F, 8'h85, 8'h34, 8'h12, 8'h00, 8'h00}; $display("0F85(3412)              JNE 1234H");
    #2; instruction[0:5] = {8'h76, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("76(01)                  JBE SHORT 1");
    #2; instruction[0:5] = {8'h0F, 8'h86, 8'h34, 8'h12, 8'h00, 8'h00}; $display("0F86(3412)              JBE 1234H");
    #2; instruction[0:5] = {8'h77, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("77(01)                  JNBE SHORT 1");
    #2; instruction[0:5] = {8'h0F, 8'h87, 8'h34, 8'h12, 8'h00, 8'h00}; $display("0F87(3412)              JNBE 1234H");
    #2; instruction[0:5] = {8'h78, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("78(01)                  JS SHORT 1");
    #2; instruction[0:5] = {8'h0F, 8'h88, 8'h34, 8'h12, 8'h00, 8'h00}; $display("0F88(3412)              JS 1234H");
    #2; instruction[0:5] = {8'h79, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("79(01)                  JNS SHORT 1");
    #2; instruction[0:5] = {8'h0F, 8'h89, 8'h34, 8'h12, 8'h00, 8'h00}; $display("0F89(3412)              JNS 1234H");
    #2; instruction[0:5] = {8'h7A, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("7A(01)                  JP SHORT 1");
    #2; instruction[0:5] = {8'h0F, 8'h8A, 8'h34, 8'h12, 8'h00, 8'h00}; $display("0F8A(3412)              JP 1234H");
    #2; instruction[0:5] = {8'h7B, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("7B(01)                  JNP SHORT 1");
    #2; instruction[0:5] = {8'h0F, 8'h8B, 8'h34, 8'h12, 8'h00, 8'h00}; $display("0F8B(3412)              JNP 1234H");
    #2; instruction[0:5] = {8'h7C, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("7C(01)                  JL SHORT 1");
    #2; instruction[0:5] = {8'h0F, 8'h8C, 8'h34, 8'h12, 8'h00, 8'h00}; $display("0F8C(3412)              JL 1234H");
    #2; instruction[0:5] = {8'h7D, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("7D(01)                  JNL SHORT 1");
    #2; instruction[0:5] = {8'h0F, 8'h8D, 8'h34, 8'h12, 8'h00, 8'h00}; $display("0F8D(3412)              JNL 1234H");
    #2; instruction[0:5] = {8'h7E, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("7E(01)                  JLE SHORT 1");
    #2; instruction[0:5] = {8'h0F, 8'h8E, 8'h34, 8'h12, 8'h00, 8'h00}; $display("0F8E(3412)              JLE 1234H");
    #2; instruction[0:5] = {8'h7F, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("7F(01)                  JNLE SHORT 1");
    #2; instruction[0:5] = {8'h0F, 8'h8F, 8'h34, 8'h12, 8'h00, 8'h00}; $display("0F8F(3412)              JNLE 1234H");

    #2; instruction[0:5] = {8'hE3, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("E3(01)                  JCXZ 1H");
    #2; instruction[0:5] = {8'h67, 8'hE3, 8'h34, 8'h00, 8'h00, 8'h00}; $display("67E3(34)                JECXZ 1234H");

    #2; instruction[0:5] = {8'hE2, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("E2(01)                  LOOP 1H");
    #2; instruction[0:5] = {8'hE1, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("E1(01)                  LOOPZ 1H");
    #2; instruction[0:5] = {8'hE0, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("E0(01)                  LOOPNZ 1H");

    #2; instruction[0:5] = {8'h0F, 8'h90, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F90C2                  SETO DL");
    #2; instruction[0:5] = {8'h0F, 8'h91, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F91C2                  SETNO DL");
    #2; instruction[0:5] = {8'h0F, 8'h92, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F92C2                  SETB DL");
    #2; instruction[0:5] = {8'h0F, 8'h93, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F93C2                  SETNB DL");
    #2; instruction[0:5] = {8'h0F, 8'h94, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F94C2                  SETE DL");
    #2; instruction[0:5] = {8'h0F, 8'h95, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F95C2                  SETNE DL");
    #2; instruction[0:5] = {8'h0F, 8'h96, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F96C2                  SETBE DL");
    #2; instruction[0:5] = {8'h0F, 8'h97, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F97C2                  SETNBE DL");
    #2; instruction[0:5] = {8'h0F, 8'h98, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F98C2                  SETS DL");
    #2; instruction[0:5] = {8'h0F, 8'h99, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F99C2                  SETNS DL");
    #2; instruction[0:5] = {8'h0F, 8'h9A, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F9AC2                  SETP DL");
    #2; instruction[0:5] = {8'h0F, 8'h9B, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F9BC2                  SETNP DL");
    #2; instruction[0:5] = {8'h0F, 8'h9C, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F9CC2                  SETL DL");
    #2; instruction[0:5] = {8'h0F, 8'h9D, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F9DC2                  SETNL DL");
    #2; instruction[0:5] = {8'h0F, 8'h9E, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F9EC2                  SETLE DL");
    #2; instruction[0:5] = {8'h0F, 8'h9F, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F9FC2                  SETNLE DL");

    #2; instruction[0:5] = {8'hC8, 8'h01, 8'h00, 8'h02, 8'h00, 8'h00}; $display("C8010002                ENTER 1H, 2H");
    #2; instruction[0:5] = {8'hC9, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("C9                      LEAVE");

    #2; instruction[0:5] = {8'hCC, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CC                      INT3");
    #2; instruction[0:5] = {8'hCD, 8'h1F, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CD1F                    INT 1FH");
    #2; instruction[0:5] = {8'hCE, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CE                      INTO");

    #2; instruction[0:5] = {8'h62, 8'h16, 8'h01, 8'h00, 8'h00, 8'h00}; $display("62160100                BOUND DX, [1]");

    #2; instruction[0:5] = {8'hCF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("CF                      IRET");

    #2; instruction[0:5] = {8'hF4, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("F4                      HLT");

    #2; instruction[0:5] = {8'h0F, 8'h22, 8'hC0, 8'h00, 8'h00, 8'h00}; $display("0F22C0                  MOV CR0, EAX");
    #2; instruction[0:5] = {8'h0F, 8'h20, 8'hC0, 8'h00, 8'h00, 8'h00}; $display("0F20C0                  MOV EAX, CR0");
    #2; instruction[0:5] = {8'h0F, 8'h23, 8'hC0, 8'h00, 8'h00, 8'h00}; $display("0F23C0                  MOV DR0, EAX");
    #2; instruction[0:5] = {8'h0F, 8'h21, 8'hC0, 8'h00, 8'h00, 8'h00}; $display("0F21C0                  MOV EAX, DR0");
    #2; instruction[0:5] = {8'h0F, 8'h26, 8'hF0, 8'h00, 8'h00, 8'h00}; $display("0F26F0                  MOV TR6, EAX");
    #2; instruction[0:5] = {8'h0F, 8'h24, 8'hF0, 8'h00, 8'h00, 8'h00}; $display("0F24F0                  MOV EAX, TR6");

    #2; instruction[0:5] = {8'h90, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("90                      NOP");

    #2; instruction[0:5] = {8'h9B, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("9B                      WAIT");

    #2; instruction[0:5] = {8'hF0, 8'h66, 8'h67, 8'hFF, 8'h01, 8'h00}; $display("F06667FF01              LOCK INC DWORD [ECX]");

    #2; instruction[0:5] = {8'h2E, 8'h8B, 8'h10, 8'h00, 8'h00, 8'h00}; $display("2E8B10                  MOV DX, CS:[BX+SI]");
    #2; instruction[0:5] = {8'h3E, 8'h8B, 8'h10, 8'h00, 8'h00, 8'h00}; $display("3E8B10                  MOV DX, DS:[BX+SI]");
    #2; instruction[0:5] = {8'h26, 8'h8B, 8'h10, 8'h00, 8'h00, 8'h00}; $display("268B10                  MOV DX, ES:[BX+SI]");
    #2; instruction[0:5] = {8'h64, 8'h8B, 8'h10, 8'h00, 8'h00, 8'h00}; $display("648B10                  MOV DX, FS:[BX+SI]");
    #2; instruction[0:5] = {8'h65, 8'h8B, 8'h10, 8'h00, 8'h00, 8'h00}; $display("658B10                  MOV DX, GS:[BX+SI]");
    #2; instruction[0:5] = {8'h36, 8'h8B, 8'h10, 8'h00, 8'h00, 8'h00}; $display("368B10                  MOV DX, SS:[BX+SI]");

    #2; instruction[0:5] = {8'h63, 8'hCA, 8'h00, 8'h00, 8'h00, 8'h00}; $display("63CA                    ARPL dx, cx");
    #2; instruction[0:5] = {8'h0F, 8'h02, 8'hD1, 8'h00, 8'h00, 8'h00}; $display("0F02D1                  LAR dx, cx");
    #2; instruction[0:5] = {8'h0F, 8'h01, 8'h16, 8'h01, 8'h00, 8'h00}; $display("0F01160100              LGDT [1]");
    #2; instruction[0:5] = {8'h0F, 8'h01, 8'h1E, 8'h01, 8'h00, 8'h00}; $display("0F011E0100              LIDT [1]");
    #2; instruction[0:5] = {8'h0F, 8'h00, 8'hD2, 8'h00, 8'h00, 8'h00}; $display("0F00D2                  LLDT dx");
    #2; instruction[0:5] = {8'h0F, 8'h01, 8'hF2, 8'h00, 8'h00, 8'h00}; $display("0F01F2                  LMSW dx");
    #2; instruction[0:5] = {8'h0F, 8'h03, 8'hD1, 8'h00, 8'h00, 8'h00}; $display("0F03D1                  LSL dx, cx");
    #2; instruction[0:5] = {8'h0F, 8'h00, 8'hDA, 8'h00, 8'h00, 8'h00}; $display("0F00DA                  LTR dx");
    #2; instruction[0:5] = {8'h0F, 8'h01, 8'h06, 8'h01, 8'h00, 8'h00}; $display("0F01060100              SGDT [1]");
    #2; instruction[0:5] = {8'h0F, 8'h01, 8'h0E, 8'h01, 8'h00, 8'h00}; $display("0F010E0100              SIDT [1]");
    #2; instruction[0:5] = {8'h0F, 8'h00, 8'hC2, 8'h00, 8'h00, 8'h00}; $display("0F00C2                  SLDT dx");
    #2; instruction[0:5] = {8'h0F, 8'h01, 8'hE2, 8'h00, 8'h00, 8'h00}; $display("0F01E2                  SMSW dx");
    #2; instruction[0:5] = {8'h0F, 8'h00, 8'hCA, 8'h00, 8'h00, 8'h00}; $display("0F00CA                  STR dx");
    #2; instruction[0:5] = {8'h0F, 8'h00, 8'hE2, 8'h00, 8'h00, 8'h00}; $display("0F00E2                  VERR dx");
    #2; instruction[0:5] = {8'h0F, 8'h00, 8'hEA, 8'h00, 8'h00, 8'h00}; $display("0F00EA                  VERW dx");

    #2; instruction[0:15] = {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
    #16;

    $stop();
end

endmodule
