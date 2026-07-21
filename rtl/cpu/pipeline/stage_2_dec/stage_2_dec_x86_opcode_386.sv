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
//  File        : stage_2_dec_x86_opcode_386.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_2_dec_x86_opcode_386 module
// ============================================================================

module stage_2_dec_x86_opcode_386 (
    output logic                o_opcode_x86_BSF_bit_scan_forward,
    output logic                o_opcode_x86_BSR_bit_scan_reverse,
    output logic                o_opcode_x86_BT_reg_mem_with_imm,
    output logic                o_opcode_x86_BT_reg_mem_with_reg,
    output logic                o_opcode_x86_BTC_reg_mem_with_imm,
    output logic                o_opcode_x86_BTC_reg_mem_with_reg,
    output logic                o_opcode_x86_BTR_reg_mem_with_imm,
    output logic                o_opcode_x86_BTR_reg_mem_with_reg,
    output logic                o_opcode_x86_BTS_reg_mem_with_imm,
    output logic                o_opcode_x86_BTS_reg_mem_with_reg,
    output logic                o_opcode_x86_CDQ_convert_double_word_to_quad_word,
    output logic                o_opcode_x86_CWDE_convert_word_to_double,
    output logic                o_opcode_x86_Jcc_jump_if_cond_is_met_full_disp,
    output logic                o_opcode_x86_LFS_load_pointer_to_FS,
    output logic                o_opcode_x86_LGS_load_pointer_to_GS,
    output logic                o_opcode_x86_LSS_load_pointer_to_SS,
    output logic                o_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg,
    output logic                o_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg,
    output logic                o_opcode_x86_MOV_CR_from_reg,
    output logic                o_opcode_x86_MOV_reg_from_CR,
    output logic                o_opcode_x86_MOV_DR_from_reg,
    output logic                o_opcode_x86_MOV_reg_from_DR,
    output logic                o_opcode_x86_MOV_TR_from_reg,
    output logic                o_opcode_x86_MOV_reg_from_TR,
    output logic                o_opcode_x86_POP_sreg_3,
    output logic                o_opcode_x86_PUSH_sreg_3,
    output logic                o_opcode_x86_SETcc_byte_set_on_condition,
    output logic                o_opcode_x86_SHLD_reg_mem_by_imm,
    output logic                o_opcode_x86_SHLD_reg_mem_by_CL,
    output logic                o_opcode_x86_SHRD_reg_mem_by_imm,
    output logic                o_opcode_x86_SHRD_reg_mem_by_CL,
    output logic                o_opcode_x86_IMUL_reg_with_reg_mem,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

// 80386 new instructions

assign o_opcode_x86_BSF_bit_scan_forward              = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1011_1100);
assign o_opcode_x86_BSR_bit_scan_reverse              = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1011_1101);

assign o_opcode_x86_BT_reg_mem_with_imm               = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1011_1010) & (i_instruction[2][5: 3] == 3'b100);
assign o_opcode_x86_BT_reg_mem_with_reg               = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1010_0011);

assign o_opcode_x86_BTC_reg_mem_with_imm              = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1011_1010) & (i_instruction[2][5: 3] == 3'b111);
assign o_opcode_x86_BTC_reg_mem_with_reg              = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1011_1011);

assign o_opcode_x86_BTR_reg_mem_with_imm              = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1011_1010) & (i_instruction[2][5: 3] == 3'b110);
assign o_opcode_x86_BTR_reg_mem_with_reg              = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1011_0011);

assign o_opcode_x86_BTS_reg_mem_with_imm              = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1011_1010) & (i_instruction[2][5: 3] == 3'b101);
assign o_opcode_x86_BTS_reg_mem_with_reg              = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1010_1011);

assign o_opcode_x86_CDQ_convert_double_word_to_quad_word = (i_instruction[0][7: 0] == 8'b1001_1001);
assign o_opcode_x86_CWDE_convert_word_to_double         = (i_instruction[0][7: 0] == 8'b1001_1000);

assign o_opcode_x86_Jcc_jump_if_cond_is_met_full_disp   = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 4] == 4'b1000);

assign o_opcode_x86_LFS_load_pointer_to_FS             = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1011_0100);
assign o_opcode_x86_LGS_load_pointer_to_GS             = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1011_0101);
assign o_opcode_x86_LSS_load_pointer_to_SS             = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1011_0010);

assign o_opcode_x86_MOVSX_move_with_sign_extend_mem_reg_to_reg = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 1] == 7'b1011_111);
assign o_opcode_x86_MOVZX_move_with_zero_extend_mem_reg_to_reg = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 1] == 7'b1011_011);
// Distinguish 0F B6 (byte→r32) vs 0F B7 (word→r32) via instruction[1][0] for EXU.

assign o_opcode_x86_MOV_CR_from_reg    = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0010_0010);
assign o_opcode_x86_MOV_reg_from_CR    = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0010_0000);
assign o_opcode_x86_MOV_DR_from_reg    = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0010_0011);
assign o_opcode_x86_MOV_reg_from_DR    = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0010_0001);
assign o_opcode_x86_MOV_TR_from_reg    = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0010_0110);
assign o_opcode_x86_MOV_reg_from_TR    = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0010_0100);

assign o_opcode_x86_POP_sreg_3         = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 6] == 2'b10) & (i_instruction[1][5: 4] == 2'b10) & (i_instruction[1][2: 0] == 3'b001);
assign o_opcode_x86_PUSH_sreg_3        = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 6] == 2'b10) & (i_instruction[1][5: 4] == 2'b10) & (i_instruction[1][2: 0] == 3'b000);

assign o_opcode_x86_SETcc_byte_set_on_condition = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 4] == 4'b1001) & (i_instruction[2][5: 3] == 3'b000);

assign o_opcode_x86_SHLD_reg_mem_by_imm = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1010_0100);
assign o_opcode_x86_SHLD_reg_mem_by_CL  = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1010_0101);

assign o_opcode_x86_SHRD_reg_mem_by_imm = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1010_1100);
assign o_opcode_x86_SHRD_reg_mem_by_CL  = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1010_1101);

assign o_opcode_x86_IMUL_reg_with_reg_mem = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1010_1111);

endmodule
