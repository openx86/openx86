/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: MMX compare instruction decode
*/

module stage_2_dec_mmx_opcode_compare (
    output logic                o_opcode_mmx_PCMPEQB_compare_packed_8_bit_equal,
    output logic                o_opcode_mmx_PCMPEQW_compare_packed_16_bit_equal,
    output logic                o_opcode_mmx_PCMPEQD_compare_packed_32_bit_equal,
    output logic                o_opcode_mmx_PCMPGTB_compare_packed_8_bit_greater,
    output logic                o_opcode_mmx_PCMPGTW_compare_packed_16_bit_greater,
    output logic                o_opcode_mmx_PCMPGTD_compare_packed_32_bit_greater,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

// Compare instructions (0F 74-76)
assign o_opcode_mmx_PCMPEQB_compare_packed_8_bit_equal = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0111_0100) & (i_instruction[2][ 5: 3] == 3'b000);
assign o_opcode_mmx_PCMPEQW_compare_packed_16_bit_equal = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0111_0100) & (i_instruction[2][ 5: 3] == 3'b001);
assign o_opcode_mmx_PCMPEQD_compare_packed_32_bit_equal = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0111_0100) & (i_instruction[2][ 5: 3] == 3'b010);

assign o_opcode_mmx_PCMPGTB_compare_packed_8_bit_greater = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0111_0100) & (i_instruction[2][ 5: 3] == 3'b100);
assign o_opcode_mmx_PCMPGTW_compare_packed_16_bit_greater = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0111_0100) & (i_instruction[2][ 5: 3] == 3'b101);
assign o_opcode_mmx_PCMPGTD_compare_packed_32_bit_greater = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0111_0100) & (i_instruction[2][ 5: 3] == 3'b110);

endmodule
