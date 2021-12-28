// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: decode_opcode_tb
// create at: 2021-12-23 01:23:14
// description: test decode_opcode module

`timescale 1ns/1ns
`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_opcode_tb #(
    // parameters
) (
    // ports
);

logic [7:0] instruction [0:9];
logic [0:`info_opcode_len-1] info_opcode;
// logic        clock, reset;

decode_opcode decode_opcode_inst (
    .instruction ( instruction ),
    .info_opcode ( info_opcode )
);

// always #1 clock = ~clock;

initial begin
    instruction[0:9] = {0,0,0,0,0,0,0,0,0,0};

    $monitor("%t: info_opcode=%b, instruction=%p", $time, info_opcode, instruction);

    #1; instruction[0:5] = {8'h89, 8'h0E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("890E0100                mov [1], cx");
    #1; instruction[0:5] = {8'h8B, 8'h1E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("8B1E0100                mov bx, [1]");
    #1; instruction[0:5] = {8'hC7, 8'h06, 8'h01, 8'h00, 8'h01, 8'h00}; $display("C70601000100            mov word [1], 1");
    #1; instruction[0:5] = {8'hBB, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("BB0100                  mov bx, 1");
    #1; instruction[0:5] = {8'hA1, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("A10100                  mov ax, [1]");
    #1; instruction[0:5] = {8'hA3, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("A30100                  mov [1], ax");
    #1; instruction[0:5] = {8'h8E, 8'h1E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("8E1E0100                mov ds, [1]");
    #1; instruction[0:5] = {8'h8C, 8'h1E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("8C1E0100                mov [1], ds");

    // #1; instruction[0:5] = {8'h66, 8'h0F, 8'hBF, 8'hD9, 8'h00, 8'h00}; $display("660FBFD9                prefix movsx ebx, cx");
    // #1; instruction[0:5] = {8'h66, 8'h0F, 8'hB7, 8'hD9, 8'h00, 8'h00}; $display("660FB7D9                prefix movzx ebx, cx");

    #1; instruction[0:5] = {8'h0F, 8'hBF, 8'hD9, 8'h00, 8'h00, 8'h00}; $display("0FBFD9                  movsx ebx, cx");
    #1; instruction[0:5] = {8'h0F, 8'hB7, 8'hD9, 8'h00, 8'h00, 8'h00}; $display("0FB7D9                  movzx ebx, cx");

    #1; instruction[0:5] = {8'hFF, 8'h36, 8'h01, 8'h00, 8'h00, 8'h00}; $display("FF360100                push word [1]");
    #1; instruction[0:5] = {8'h53, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("53                      push bx");
    #1; instruction[0:5] = {8'h1E, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("1E                      push ds");
    #1; instruction[0:5] = {8'h0F, 8'hA8, 8'h01, 8'h00, 8'h00, 8'h00}; $display("0FA8                    push gs");
    #1; instruction[0:5] = {8'h6A, 8'h01, 8'h01, 8'h00, 8'h00, 8'h00}; $display("6A01                    push 1");
    #1; instruction[0:5] = {8'h60, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("60                      pusha");

    #1; instruction[0:5] = {8'h8F, 8'h06, 8'h01, 8'h00, 8'h00, 8'h00}; $display("8F060100                pop word [1]");
    #1; instruction[0:5] = {8'h5B, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("5B                      pop bx");
    #1; instruction[0:5] = {8'h1F, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("1F                      pop ds");
    #1; instruction[0:5] = {8'h0F, 8'hA9, 8'h00, 8'h00, 8'h00, 8'h00}; $display("0FA9                    pop gs");
    #1; instruction[0:5] = {8'h61, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("61                      popa");

    #1; instruction[0:5] = {8'h87, 8'h1E, 8'h01, 8'h00, 8'h00, 8'h00}; $display("871E0100                xchg bx, word [1]");
    #1; instruction[0:5] = {8'h90, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("90                      xchg ax, ax");

    #1; instruction[0:5] = {8'hE4, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("E401                    in al, 1");
    #1; instruction[0:5] = {8'hEC, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("EC                      in al, dx");

    #1; instruction[0:5] = {8'hE6, 8'h01, 8'h00, 8'h00, 8'h00, 8'h00}; $display("E601                    out 1, al");
    #1; instruction[0:5] = {8'hEE, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}; $display("EE                      out dx, al");

    // 660FBFD9
    // 660FB7D9

    // FF37
    // 53
    // 1E
    // 0FA8
    // 6A01
    // 60

    // 8F07
    // 5B
    // 1F
    // 0FA9
    // 61

    // 871F
    // 90

    // E401
    // EC

    // E601
    // EE

    // #1;
    // $display("mov al, bl: 0x88D8");
    // $display("nop: 0x90");
    // $display("nop: 0x90");
    // instruction = 32'h88D8_9090;
    // #1;
    // $display("mov ax, bx: 0x89D8");
    // $display("nop: 0x90");
    // $display("nop: 0x90");
    // instruction = 32'h89D8_9090;
    // #1;
    // $display("mov ax, cx: 0x89C8");
    // $display("nop: 0x90");
    // $display("nop: 0x90");
    // instruction = 32'h89C8_9090;
    // #1;
    // $display("mov ax, dx: 0x89D0");
    // $display("nop: 0x90");
    // $display("nop: 0x90");
    // instruction = 32'h89D0_9090;
    // #1;
    // $display("mov ax, 1 : 0xB801");
    // $display("nop: 0x90");
    // $display("nop: 0x90");
    // instruction = 32'hB801_9090;

    #1; instruction = {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
    #16;

    $stop();
end

endmodule
