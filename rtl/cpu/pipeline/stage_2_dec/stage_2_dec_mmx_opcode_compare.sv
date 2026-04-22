// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : stage_2_dec_mmx_opcode_compare.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_2_dec_mmx_opcode_compare module
// ============================================================================

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
assign o_opcode_mmx_PCMPEQB_compare_packed_8_bit_equal  = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0111_0100) & (i_instruction[2][5: 3] == 3'b000);
assign o_opcode_mmx_PCMPEQW_compare_packed_16_bit_equal = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0111_0100) & (i_instruction[2][5: 3] == 3'b001);
assign o_opcode_mmx_PCMPEQD_compare_packed_32_bit_equal = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0111_0100) & (i_instruction[2][5: 3] == 3'b010);

assign o_opcode_mmx_PCMPGTB_compare_packed_8_bit_greater = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0111_0100) & (i_instruction[2][5: 3] == 3'b100);
assign o_opcode_mmx_PCMPGTW_compare_packed_16_bit_greater = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0111_0100) & (i_instruction[2][5: 3] == 3'b101);
assign o_opcode_mmx_PCMPGTD_compare_packed_32_bit_greater = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0111_0100) & (i_instruction[2][5: 3] == 3'b110);

endmodule
