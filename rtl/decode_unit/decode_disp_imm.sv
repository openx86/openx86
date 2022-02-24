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
    input  logic        i_displacement_size__8,
    input  logic        i_displacement_size_16,
    input  logic        i_displacement_size_32,
    input  logic        i_immediate_size__8,
    input  logic        i_immediate_size_16,
    input  logic        i_immediate_size_32,
    input  logic        i_immediate_size_full,
    output logic [31:0] o_displacement,
    output logic [31:0] o_immediate,
    output logic [ 3:0] o_bytes_consumed,
    output logic        o_error
);

logic [7:0] instruction_for_immediate [0:3];

always_comb begin
    unique case (1'b1)
        i_displacement_size__8: begin instruction_for_immediate <= i_instruction[1:4]; o_displacement <= {24'b0, i_instruction[0][7:0]}; end
        i_displacement_size_16: begin instruction_for_immediate <= i_instruction[2:5]; o_displacement <= {16'b0, i_instruction[1][7:0], i_instruction[0][7:0]}; end
        i_displacement_size_32: begin instruction_for_immediate <= i_instruction[4:7]; o_displacement <= {       i_instruction[3][7:0], i_instruction[2][7:0], i_instruction[1][7:0], i_instruction[0][7:0]}; end
        default               : begin instruction_for_immediate <= i_instruction[0:3]; o_displacement <= 32'bzzzz_zzzz_zzzz_zzzz; end
    endcase
end

always_comb begin
    unique case (1'b1)
        i_immediate_size__8:   o_immediate <= {24'b0, instruction_for_immediate[0][7:0]};
        i_immediate_size_16:   o_immediate <= {16'b0, instruction_for_immediate[1][7:0], instruction_for_immediate[0][7:0]};
        i_immediate_size_32:   o_immediate <= {       instruction_for_immediate[3][7:0], instruction_for_immediate[2][7:0], instruction_for_immediate[1][7:0], instruction_for_immediate[0][7:0]};
        i_immediate_size_full: o_immediate <= {       instruction_for_immediate[3][7:0], instruction_for_immediate[2][7:0], instruction_for_immediate[1][7:0], instruction_for_immediate[0][7:0]};
        default:               o_immediate <= 32'bzzzz_zzzz_zzzz_zzzz;
    endcase
end

logic [ 3:0] displacement_bytes;
always_comb begin
    unique case (1'b1)
        i_displacement_size__8:   displacement_bytes <= 4'h1;
        i_displacement_size_16:   displacement_bytes <= 4'h2;
        i_displacement_size_32:   displacement_bytes <= 4'h4;
        // i_displacement_size_full: displacement_bytes <= 4'h4;
        default:                  displacement_bytes <= 4'h0;
    endcase
end

logic [ 3:0] immediate_bytes;
always_comb begin
    unique case (1'b1)
        i_immediate_size__8:   immediate_bytes <= 4'h1;
        i_immediate_size_16:   immediate_bytes <= 4'h2;
        i_immediate_size_32:   immediate_bytes <= 4'h4;
        i_immediate_size_full: immediate_bytes <= 4'h4;
        default:               immediate_bytes <= 4'h0;
    endcase
end

assign o_bytes_consumed = displacement_bytes + immediate_bytes;

endmodule
