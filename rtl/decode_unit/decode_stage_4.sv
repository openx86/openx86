/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_stage_4
create at: 2022-02-14 04:39:55
description: decode the displacement and immediate
*/

/* ref:
Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
6.2.3.4 ENCODING OF ADDRESS MODE
*/
`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_stage_4 (
    input  logic [ 7:0] instruction [0:7],
    input  logic        displacement_is_present,
    input  logic [ 3:0] displacement_length,
    input  logic        immediate_is_present,
    input  logic [ 3:0] immediate_length,
    output logic [31:0] displacement,
    output logic [31:0] immediate
);

wire displacement_length__8   = displacement_length[0];
wire displacement_length_16   = displacement_length[1];
wire displacement_length_32   = displacement_length[2];
wire displacement_length_full = displacement_length[3];

wire immediate_length__8   = immediate_length[0];
wire immediate_length_16   = immediate_length[1];
wire immediate_length_32   = immediate_length[2];
wire immediate_length_full = immediate_length[3];

// assign displacement = 32'b0;
// assign immediate = 32'b0;

wire [7:0] instruction_for_immediate [0:3];

always_comb begin
    unique case (1'b1)
        displacement_length__8:   begin instruction_for_immediate <= instruction[1:4]; displacement <= {24'b0, instruction[0][7:0]}; end
        displacement_length_16:   begin instruction_for_immediate <= instruction[2:5]; displacement <= {16'b0, instruction[1][7:0], instruction[0][7:0]}; end
        displacement_length_32:   begin instruction_for_immediate <= instruction[4:7]; displacement <= {       instruction[3][7:0], instruction[2][7:0], instruction[1][7:0], instruction[0][7:0]}; end
        displacement_length_full: begin instruction_for_immediate <= instruction[4:7]; displacement <= {       instruction[3][7:0], instruction[2][7:0], instruction[1][7:0], instruction[0][7:0]}; end
        default:                  begin instruction_for_immediate <= instruction[0:3]; displacement <= 32'b0; end
    endcase
end

always_comb begin
    unique case (1'b1)
        immediate_length__8:   immediate <= {24'b0, instruction_for_immediate[0][7:0]};
        immediate_length_16:   immediate <= {16'b0, instruction_for_immediate[1][7:0], instruction_for_immediate[0][7:0]};
        immediate_length_32:   immediate <= {       instruction_for_immediate[3][7:0], instruction_for_immediate[2][7:0], instruction_for_immediate[1][7:0], instruction_for_immediate[0][7:0]};
        immediate_length_full: immediate <= {       instruction_for_immediate[3][7:0], instruction_for_immediate[2][7:0], instruction_for_immediate[1][7:0], instruction_for_immediate[0][7:0]};
        default:               immediate <= 32'b0;
    endcase
end

endmodule
