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
//  File        : stage_2_dec_mmx_opcode_logical.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_2_dec_mmx_opcode_logical module
// ============================================================================

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
