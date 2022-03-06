/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_disp_imm
create at: 2022-02-25 04:29:04
description: decode the s-i-b means scale-index-base
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
6.2.3.4 ENCODING OF ADDRESS MODE
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"

module decode_disp_imm (
    input  logic [ 7:0] i_instruction [0:7],
    input  logic        i_displacement_size_1,
    input  logic        i_displacement_size_2,
    input  logic        i_displacement_size_4,
    input  logic        i_immediate_size_1,
    input  logic        i_immediate_size_2,
    input  logic        i_immediate_size_4,
    input  logic        i_immediate_size_f,
    output logic [31:0] o_displacement,
    output logic [31:0] o_immediate,
    output logic [ 3:0] o_consume_bytes,
    output logic        o_error
);

logic [7:0] instruction_for_immediate [0:3];

always_comb begin
    unique case (1'b1)
        i_displacement_size_1: begin instruction_for_immediate <= i_instruction[1:1+3]; o_displacement <= {24'b0, i_instruction[0][7:0]}; end
        i_displacement_size_2: begin instruction_for_immediate <= i_instruction[2:2+3]; o_displacement <= {16'b0, i_instruction[1][7:0], i_instruction[0][7:0]}; end
        i_displacement_size_4: begin instruction_for_immediate <= i_instruction[4:4+3]; o_displacement <= {       i_instruction[3][7:0], i_instruction[2][7:0], i_instruction[1][7:0], i_instruction[0][7:0]}; end
        default              : begin instruction_for_immediate <= i_instruction[0:0+3]; o_displacement <= 32'bzzzz_zzzz_zzzz_zzzz; end
    endcase
end

always_comb begin
    unique case (1'b1)
        i_immediate_size_1: o_immediate <= {24'b0, instruction_for_immediate[0][7:0]};
        i_immediate_size_2: o_immediate <= {16'b0, instruction_for_immediate[1][7:0], instruction_for_immediate[0][7:0]};
        i_immediate_size_4: o_immediate <= {       instruction_for_immediate[3][7:0], instruction_for_immediate[2][7:0], instruction_for_immediate[1][7:0], instruction_for_immediate[0][7:0]};
        i_immediate_size_f: o_immediate <= {       instruction_for_immediate[3][7:0], instruction_for_immediate[2][7:0], instruction_for_immediate[1][7:0], instruction_for_immediate[0][7:0]};
        default:               o_immediate <= 32'bzzzz_zzzz_zzzz_zzzz;
    endcase
end

logic [ 3:0] displacement_bytes;
always_comb begin
    unique case (1'b1)
        i_displacement_size_1: displacement_bytes <= 4'h1;
        i_displacement_size_2: displacement_bytes <= 4'h2;
        i_displacement_size_4: displacement_bytes <= 4'h4;
        // i_displacement_size_full: displacement_bytes <= 4'h4;
        default              : displacement_bytes <= 4'h0;
    endcase
end

logic [ 3:0] immediate_bytes;
always_comb begin
    unique case (1'b1)
        i_immediate_size_1: immediate_bytes <= 4'h1;
        i_immediate_size_2: immediate_bytes <= 4'h2;
        i_immediate_size_4: immediate_bytes <= 4'h4;
        i_immediate_size_f: immediate_bytes <= 4'h4;
        default           : immediate_bytes <= 4'h0;
    endcase
end

assign o_consume_bytes = displacement_bytes + immediate_bytes;

endmodule
