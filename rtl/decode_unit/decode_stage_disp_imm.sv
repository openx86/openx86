/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_stage_disp_imm
create at: 2022-02-14 04:39:55
description: decode the o_displacement and o_immediate
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
6.2.3.4 ENCODING OF ADDRESS MODE
*/
`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_stage_disp_imm (
    input  logic [ 7:0] i_instruction [0:7],
    input  logic        i_displacement_is_present,
    input  logic [ 3:0] i_displacement_length,
    input  logic        i_immediate_is_present,
    input  logic [ 3:0] i_immediate_length,
    output logic [31:0] o_displacement,
    output logic [31:0] o_immediate,
    output logic [ 3:0] o_bytes_consumed
);

wire displacement_length__8   = i_displacement_length[0];
wire displacement_length_16   = i_displacement_length[1];
wire displacement_length_32   = i_displacement_length[2];
wire displacement_length_full = i_displacement_length[3];

wire immediate_length__8   = i_immediate_length[0];
wire immediate_length_16   = i_immediate_length[1];
wire immediate_length_32   = i_immediate_length[2];
wire immediate_length_full = i_immediate_length[3];

// assign o_displacement = 32'b0;
// assign o_immediate = 32'b0;

logic [7:0] instruction_for_immediate [0:3];

always_comb begin
    if (i_displacement_is_present) begin
        unique case (1'b1)
            displacement_length__8:   begin instruction_for_immediate <= i_instruction[1:4]; o_displacement <= {24'b0, i_instruction[0][7:0]}; end
            displacement_length_16:   begin instruction_for_immediate <= i_instruction[2:5]; o_displacement <= {16'b0, i_instruction[1][7:0], i_instruction[0][7:0]}; end
            displacement_length_32:   begin instruction_for_immediate <= i_instruction[4:7]; o_displacement <= {       i_instruction[3][7:0], i_instruction[2][7:0], i_instruction[1][7:0], i_instruction[0][7:0]}; end
            displacement_length_full: begin instruction_for_immediate <= i_instruction[4:7]; o_displacement <= {       i_instruction[3][7:0], i_instruction[2][7:0], i_instruction[1][7:0], i_instruction[0][7:0]}; end
            default:                  begin instruction_for_immediate <= i_instruction[0:3]; o_displacement <= 32'b0; end
        endcase
    end else begin
        instruction_for_immediate <= i_instruction[0:3];
		  o_displacement <= 32'b0;
    end
end

always_comb begin
    if (i_immediate_is_present) begin
        unique case (1'b1)
            immediate_length__8:   o_immediate <= {24'b0, instruction_for_immediate[0][7:0]};
            immediate_length_16:   o_immediate <= {16'b0, instruction_for_immediate[1][7:0], instruction_for_immediate[0][7:0]};
            immediate_length_32:   o_immediate <= {       instruction_for_immediate[3][7:0], instruction_for_immediate[2][7:0], instruction_for_immediate[1][7:0], instruction_for_immediate[0][7:0]};
            immediate_length_full: o_immediate <= {       instruction_for_immediate[3][7:0], instruction_for_immediate[2][7:0], instruction_for_immediate[1][7:0], instruction_for_immediate[0][7:0]};
            default:               o_immediate <= 32'b0;
        endcase
    end else begin
        o_immediate <= 32'b0;
    end
end

logic displacement_bytes;
always_comb begin
    if (i_displacement_is_present) begin
        unique case (1'b1)
            displacement_length__8:   displacement_bytes <= 1;
            displacement_length_16:   displacement_bytes <= 2;
            displacement_length_32:   displacement_bytes <= 4;
            displacement_length_full: displacement_bytes <= 4;
            default:                  displacement_bytes <= 0;
        endcase
    end else begin
        displacement_bytes <= 0;
    end
end

logic immediate_bytes;
always_comb begin
    if (i_immediate_is_present) begin
        unique case (1'b1)
            immediate_length__8:   immediate_bytes <= 1;
            immediate_length_16:   immediate_bytes <= 2;
            immediate_length_32:   immediate_bytes <= 4;
            immediate_length_full: immediate_bytes <= 4;
            default:               immediate_bytes <= 0;
        endcase
    end else begin
        immediate_bytes <= 0;
    end
end

assign o_bytes_consumed = displacement_bytes + immediate_bytes;

endmodule
