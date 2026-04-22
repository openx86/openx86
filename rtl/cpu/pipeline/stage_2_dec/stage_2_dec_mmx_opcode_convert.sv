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
//  File        : stage_2_dec_mmx_opcode_convert.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_2_dec_mmx_opcode_convert module
// ============================================================================

module stage_2_dec_mmx_opcode_convert (
    output logic                o_opcode_mmx_PACKSSWB_pack_signed_saturate_16_to_8,
    output logic                o_opcode_mmx_PACKSSDW_pack_signed_saturate_32_to_16,
    output logic                o_opcode_mmx_PACKUSWB_pack_unsigned_saturate_16_to_8,
    output logic                o_opcode_mmx_PUNPCKHBW_unpack_high_packed_8_to_16,
    output logic                o_opcode_mmx_PUNPCKHWD_unpack_high_packed_16_to_32,
    output logic                o_opcode_mmx_PUNPCKHDQ_unpack_high_packed_32_to_64,
    output logic                o_opcode_mmx_PUNPCKLBW_unpack_low_packed_8_to_16,
    output logic                o_opcode_mmx_PUNPCKLWD_unpack_low_packed_16_to_32,
    output logic                o_opcode_mmx_PUNPCKLDQ_unpack_low_packed_32_to_64,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

// Conversion instructions (0F 60-68)
assign o_opcode_mmx_PACKSSWB_pack_signed_saturate_16_to_8   = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0110_0000) & (i_instruction[2][5: 3] == 3'b000);
assign o_opcode_mmx_PACKSSDW_pack_signed_saturate_32_to_16  = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0110_0000) & (i_instruction[2][5: 3] == 3'b001);
assign o_opcode_mmx_PACKUSWB_pack_unsigned_saturate_16_to_8 = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0110_0000) & (i_instruction[2][5: 3] == 3'b010);

assign o_opcode_mmx_PUNPCKHBW_unpack_high_packed_8_to_16   = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0110_1000) & (i_instruction[2][5: 3] == 3'b000);
assign o_opcode_mmx_PUNPCKHWD_unpack_high_packed_16_to_32  = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0110_1000) & (i_instruction[2][5: 3] == 3'b001);
assign o_opcode_mmx_PUNPCKHDQ_unpack_high_packed_32_to_64  = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0110_1000) & (i_instruction[2][5: 3] == 3'b010);

assign o_opcode_mmx_PUNPCKLBW_unpack_low_packed_8_to_16    = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0110_1000) & (i_instruction[2][5: 3] == 3'b100);
assign o_opcode_mmx_PUNPCKLWD_unpack_low_packed_16_to_32   = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0110_1000) & (i_instruction[2][5: 3] == 3'b101);
assign o_opcode_mmx_PUNPCKLDQ_unpack_low_packed_32_to_64   = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0110_1000) & (i_instruction[2][5: 3] == 3'b110);

endmodule
