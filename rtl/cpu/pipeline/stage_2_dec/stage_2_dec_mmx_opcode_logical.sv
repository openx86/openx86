/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: MMX logical instruction decode
*/

module stage_2_dec_mmx_opcode_logical (
    output logic                o_opcode_mmx_PAND_bitwise_and,
    output logic                o_opcode_mmx_PANDN_bitwise_and_not,
    output logic                o_opcode_mmx_POR_bitwise_or,
    output logic                o_opcode_mmx_PXOR_bitwise_xor,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

// Logical instructions (0F DB-DF)
assign o_opcode_mmx_PAND_bitwise_and   = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1101_1011) & (i_instruction[2][5: 3] == 3'b000);
assign o_opcode_mmx_PANDN_bitwise_and_not = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1101_1011) & (i_instruction[2][5: 3] == 3'b001);
assign o_opcode_mmx_POR_bitwise_or     = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1101_1011) & (i_instruction[2][5: 3] == 3'b010);
assign o_opcode_mmx_PXOR_bitwise_xor   = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1101_1011) & (i_instruction[2][5: 3] == 3'b011);

endmodule
