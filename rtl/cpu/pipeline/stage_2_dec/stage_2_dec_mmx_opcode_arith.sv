/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: MMX arithmetic instruction decode
*/

module stage_2_dec_mmx_opcode_arith (
    output logic                o_opcode_mmx_PADDB_add_packed_8_bit,
    output logic                o_opcode_mmx_PADDW_add_packed_16_bit,
    output logic                o_opcode_mmx_PADDD_add_packed_32_bit,
    output logic                o_opcode_mmx_PADDSB_add_packed_8_bit_signed_saturation,
    output logic                o_opcode_mmx_PADDSW_add_packed_16_bit_signed_saturation,
    output logic                o_opcode_mmx_PADDUSB_add_packed_8_bit_unsigned_saturation,
    output logic                o_opcode_mmx_PADDUSW_add_packed_16_bit_unsigned_saturation,
    output logic                o_opcode_mmx_PSUBB_subtract_packed_8_bit,
    output logic                o_opcode_mmx_PSUBW_subtract_packed_16_bit,
    output logic                o_opcode_mmx_PSUBD_subtract_packed_32_bit,
    output logic                o_opcode_mmx_PSUBSB_subtract_packed_8_bit_signed_saturation,
    output logic                o_opcode_mmx_PSUBSW_subtract_packed_16_bit_signed_saturation,
    output logic                o_opcode_mmx_PSUBUSB_subtract_packed_8_bit_unsigned_saturation,
    output logic                o_opcode_mmx_PSUBUSW_subtract_packed_16_bit_unsigned_saturation,
    output logic                o_opcode_mmx_PMULLW_multiply_packed_16_bit_low,
    output logic                o_opcode_mmx_PMULHW_multiply_packed_16_bit_high,
    output logic                o_opcode_mmx_PMADDWD_multiply_and_add_packed_16_bit,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

// Arithmetic instructions (0F FC-FF, 0F D5)
assign o_opcode_mmx_PADDB_add_packed_8_bit                    = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1111_1100) & (i_instruction[2][5: 3] == 3'b000);
assign o_opcode_mmx_PADDW_add_packed_16_bit                   = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1111_1100) & (i_instruction[2][5: 3] == 3'b001);
assign o_opcode_mmx_PADDD_add_packed_32_bit                   = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1111_1100) & (i_instruction[2][5: 3] == 3'b010);
assign o_opcode_mmx_PADDSB_add_packed_8_bit_signed_saturation = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1110_1100) & (i_instruction[2][5: 3] == 3'b000);
assign o_opcode_mmx_PADDSW_add_packed_16_bit_signed_saturation = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1110_1100) & (i_instruction[2][5: 3] == 3'b001);
assign o_opcode_mmx_PADDUSB_add_packed_8_bit_unsigned_saturation = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1100_1100) & (i_instruction[2][5: 3] == 3'b000);
assign o_opcode_mmx_PADDUSW_add_packed_16_bit_unsigned_saturation = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1100_1100) & (i_instruction[2][5: 3] == 3'b001);

assign o_opcode_mmx_PSUBB_subtract_packed_8_bit                    = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1111_1100) & (i_instruction[2][5: 3] == 3'b101);
assign o_opcode_mmx_PSUBW_subtract_packed_16_bit                   = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1111_1100) & (i_instruction[2][5: 3] == 3'b110);
assign o_opcode_mmx_PSUBD_subtract_packed_32_bit                   = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1111_1100) & (i_instruction[2][5: 3] == 3'b111);
assign o_opcode_mmx_PSUBSB_subtract_packed_8_bit_signed_saturation = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1110_1100) & (i_instruction[2][5: 3] == 3'b101);
assign o_opcode_mmx_PSUBSW_subtract_packed_16_bit_signed_saturation = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1110_1100) & (i_instruction[2][5: 3] == 3'b110);
assign o_opcode_mmx_PSUBUSB_subtract_packed_8_bit_unsigned_saturation = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1100_1100) & (i_instruction[2][5: 3] == 3'b101);
assign o_opcode_mmx_PSUBUSW_subtract_packed_16_bit_unsigned_saturation = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1100_1100) & (i_instruction[2][5: 3] == 3'b110);

assign o_opcode_mmx_PMULLW_multiply_packed_16_bit_low  = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1101_0101) & (i_instruction[2][5: 3] == 3'b100);
assign o_opcode_mmx_PMULHW_multiply_packed_16_bit_high = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1101_0101) & (i_instruction[2][5: 3] == 3'b101);
assign o_opcode_mmx_PMADDWD_multiply_and_add_packed_16_bit = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1101_0101) & (i_instruction[2][5: 3] == 3'b111);

endmodule
