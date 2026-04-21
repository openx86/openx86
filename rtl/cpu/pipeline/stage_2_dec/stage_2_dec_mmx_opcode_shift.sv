/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: MMX shift instruction decode
*/

module stage_2_dec_mmx_opcode_shift (
    output logic                o_opcode_mmx_PSLLW_shift_left_logical_packed_16_bit,
    output logic                o_opcode_mmx_PSLLD_shift_left_logical_packed_32_bit,
    output logic                o_opcode_mmx_PSLLQ_shift_left_logical_packed_64_bit,
    output logic                o_opcode_mmx_PSLLW_shift_left_logical_packed_16_bit_imm,
    output logic                o_opcode_mmx_PSLLD_shift_left_logical_packed_32_bit_imm,
    output logic                o_opcode_mmx_PSLLQ_shift_left_logical_packed_64_bit_imm,
    output logic                o_opcode_mmx_PSRLW_shift_right_logical_packed_16_bit,
    output logic                o_opcode_mmx_PSRLD_shift_right_logical_packed_32_bit,
    output logic                o_opcode_mmx_PSRLQ_shift_right_logical_packed_64_bit,
    output logic                o_opcode_mmx_PSRLW_shift_right_logical_packed_16_bit_imm,
    output logic                o_opcode_mmx_PSRLD_shift_right_logical_packed_32_bit_imm,
    output logic                o_opcode_mmx_PSRLQ_shift_right_logical_packed_64_bit_imm,
    output logic                o_opcode_mmx_PSRAW_shift_right_arithmetic_packed_16_bit,
    output logic                o_opcode_mmx_PSRAD_shift_right_arithmetic_packed_32_bit,
    output logic                o_opcode_mmx_PSRAW_shift_right_arithmetic_packed_16_bit_imm,
    output logic                o_opcode_mmx_PSRAD_shift_right_arithmetic_packed_32_bit_imm,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

// Shift instructions (0F 71-73, D1-D3)
// Shift by MMX register
assign o_opcode_mmx_PSLLW_shift_left_logical_packed_16_bit = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b1111_0001) & (i_instruction[2][ 5: 3] == 3'b110);
assign o_opcode_mmx_PSLLD_shift_left_logical_packed_32_bit = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b1111_0001) & (i_instruction[2][ 5: 3] == 3'b111);
assign o_opcode_mmx_PSLLQ_shift_left_logical_packed_64_bit = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b1111_0001) & (i_instruction[2][ 5: 3] == 3'b100);

assign o_opcode_mmx_PSRLW_shift_right_logical_packed_16_bit = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b1111_0001) & (i_instruction[2][ 5: 3] == 3'b010);
assign o_opcode_mmx_PSRLD_shift_right_logical_packed_32_bit = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b1111_0001) & (i_instruction[2][ 5: 3] == 3'b011);
assign o_opcode_mmx_PSRLQ_shift_right_logical_packed_64_bit = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b1111_0001) & (i_instruction[2][ 5: 3] == 3'b000);

assign o_opcode_mmx_PSRAW_shift_right_arithmetic_packed_16_bit = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b1111_0001) & (i_instruction[2][ 5: 3] == 3'b100);
assign o_opcode_mmx_PSRAD_shift_right_arithmetic_packed_32_bit = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b1111_0001) & (i_instruction[2][ 5: 3] == 3'b110);

// Shift by immediate count (0F 71-73)
assign o_opcode_mmx_PSLLW_shift_left_logical_packed_16_bit_imm = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0111_0001) & (i_instruction[2][ 5: 3] == 3'b110);
assign o_opcode_mmx_PSLLD_shift_left_logical_packed_32_bit_imm = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0111_0001) & (i_instruction[2][ 5: 3] == 3'b111);
assign o_opcode_mmx_PSLLQ_shift_left_logical_packed_64_bit_imm = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0111_0001) & (i_instruction[2][ 5: 3] == 3'b100);

assign o_opcode_mmx_PSRLW_shift_right_logical_packed_16_bit_imm = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0111_0001) & (i_instruction[2][ 5: 3] == 3'b010);
assign o_opcode_mmx_PSRLD_shift_right_logical_packed_32_bit_imm = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0111_0001) & (i_instruction[2][ 5: 3] == 3'b011);
assign o_opcode_mmx_PSRLQ_shift_right_logical_packed_64_bit_imm = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0111_0001) & (i_instruction[2][ 5: 3] == 3'b000);

assign o_opcode_mmx_PSRAW_shift_right_arithmetic_packed_16_bit_imm = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0111_0001) & (i_instruction[2][ 5: 3] == 3'b100);
assign o_opcode_mmx_PSRAD_shift_right_arithmetic_packed_32_bit_imm = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0111_0001) & (i_instruction[2][ 5: 3] == 3'b110);

endmodule
