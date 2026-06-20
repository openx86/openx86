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
//  File        : stage_2_dec_mmx_opcode.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_2_dec_mmx_opcode module
// ============================================================================

module stage_2_dec_mmx_opcode (
    // =========================
    // MMX opcode outputs
    // =========================
    output logic                o_opcode_mmx_MOVQ_move_64_bit,
    output logic                o_opcode_mmx_MOVD_move_32_bit,
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
    output logic                o_opcode_mmx_PCMPEQB_compare_packed_8_bit_equal,
    output logic                o_opcode_mmx_PCMPEQW_compare_packed_16_bit_equal,
    output logic                o_opcode_mmx_PCMPEQD_compare_packed_32_bit_equal,
    output logic                o_opcode_mmx_PCMPGTB_compare_packed_8_bit_greater,
    output logic                o_opcode_mmx_PCMPGTW_compare_packed_16_bit_greater,
    output logic                o_opcode_mmx_PCMPGTD_compare_packed_32_bit_greater,
    output logic                o_opcode_mmx_PAND_bitwise_and,
    output logic                o_opcode_mmx_PANDN_bitwise_and_not,
    output logic                o_opcode_mmx_POR_bitwise_or,
    output logic                o_opcode_mmx_PXOR_bitwise_xor,
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
    output logic                o_opcode_mmx_PACKSSWB_pack_signed_saturate_16_to_8,
    output logic                o_opcode_mmx_PACKSSDW_pack_signed_saturate_32_to_16,
    output logic                o_opcode_mmx_PACKUSWB_pack_unsigned_saturate_16_to_8,
    output logic                o_opcode_mmx_PUNPCKHBW_unpack_high_packed_8_to_16,
    output logic                o_opcode_mmx_PUNPCKHWD_unpack_high_packed_16_to_32,
    output logic                o_opcode_mmx_PUNPCKHDQ_unpack_high_packed_32_to_64,
    output logic                o_opcode_mmx_PUNPCKLBW_unpack_low_packed_8_to_16,
    output logic                o_opcode_mmx_PUNPCKLWD_unpack_low_packed_16_to_32,
    output logic                o_opcode_mmx_PUNPCKLDQ_unpack_low_packed_32_to_64,
    output logic                o_opcode_mmx_EMMS_empty_MMX_state,
    output logic                o_opcode_mmx_any,

    // =========================
    // input
    // =========================
    input  logic [ 3: 0][ 7: 0] i_instruction
);

    // ============================================================
    // MMX sub-modules instantiation
    // ============================================================
    stage_2_dec_mmx_opcode_data u_data (
        .i_instruction             (i_instruction),
        .o_opcode_mmx_MOVQ_move_64_bit (o_opcode_mmx_MOVQ_move_64_bit),
        .o_opcode_mmx_MOVD_move_32_bit (o_opcode_mmx_MOVD_move_32_bit)
    );

stage_2_dec_mmx_opcode_arith u_arith (
    .i_instruction                                            (i_instruction),
    .o_opcode_mmx_PADDB_add_packed_8_bit                      (o_opcode_mmx_PADDB_add_packed_8_bit),
    .o_opcode_mmx_PADDW_add_packed_16_bit                     (o_opcode_mmx_PADDW_add_packed_16_bit),
    .o_opcode_mmx_PADDD_add_packed_32_bit                     (o_opcode_mmx_PADDD_add_packed_32_bit),
    .o_opcode_mmx_PADDSB_add_packed_8_bit_signed_saturation   (o_opcode_mmx_PADDSB_add_packed_8_bit_signed_saturation),
    .o_opcode_mmx_PADDSW_add_packed_16_bit_signed_saturation (o_opcode_mmx_PADDSW_add_packed_16_bit_signed_saturation),
    .o_opcode_mmx_PADDUSB_add_packed_8_bit_unsigned_saturation(o_opcode_mmx_PADDUSB_add_packed_8_bit_unsigned_saturation),
    .o_opcode_mmx_PADDUSW_add_packed_16_bit_unsigned_saturation(o_opcode_mmx_PADDUSW_add_packed_16_bit_unsigned_saturation),
    .o_opcode_mmx_PSUBB_subtract_packed_8_bit                 (o_opcode_mmx_PSUBB_subtract_packed_8_bit),
    .o_opcode_mmx_PSUBW_subtract_packed_16_bit                (o_opcode_mmx_PSUBW_subtract_packed_16_bit),
    .o_opcode_mmx_PSUBD_subtract_packed_32_bit                (o_opcode_mmx_PSUBD_subtract_packed_32_bit),
    .o_opcode_mmx_PSUBSB_subtract_packed_8_bit_signed_saturation (o_opcode_mmx_PSUBSB_subtract_packed_8_bit_signed_saturation),
    .o_opcode_mmx_PSUBSW_subtract_packed_16_bit_signed_saturation(o_opcode_mmx_PSUBSW_subtract_packed_16_bit_signed_saturation),
    .o_opcode_mmx_PSUBUSB_subtract_packed_8_bit_unsigned_saturation(o_opcode_mmx_PSUBUSB_subtract_packed_8_bit_unsigned_saturation),
    .o_opcode_mmx_PSUBUSW_subtract_packed_16_bit_unsigned_saturation(o_opcode_mmx_PSUBUSW_subtract_packed_16_bit_unsigned_saturation),
    .o_opcode_mmx_PMULLW_multiply_packed_16_bit_low           (o_opcode_mmx_PMULLW_multiply_packed_16_bit_low),
    .o_opcode_mmx_PMULHW_multiply_packed_16_bit_high          (o_opcode_mmx_PMULHW_multiply_packed_16_bit_high),
    .o_opcode_mmx_PMADDWD_multiply_and_add_packed_16_bit      (o_opcode_mmx_PMADDWD_multiply_and_add_packed_16_bit)
);

stage_2_dec_mmx_opcode_compare u_compare (
    .i_instruction                                         (i_instruction),
    .o_opcode_mmx_PCMPEQB_compare_packed_8_bit_equal      (o_opcode_mmx_PCMPEQB_compare_packed_8_bit_equal),
    .o_opcode_mmx_PCMPEQW_compare_packed_16_bit_equal     (o_opcode_mmx_PCMPEQW_compare_packed_16_bit_equal),
    .o_opcode_mmx_PCMPEQD_compare_packed_32_bit_equal     (o_opcode_mmx_PCMPEQD_compare_packed_32_bit_equal),
    .o_opcode_mmx_PCMPGTB_compare_packed_8_bit_greater    (o_opcode_mmx_PCMPGTB_compare_packed_8_bit_greater),
    .o_opcode_mmx_PCMPGTW_compare_packed_16_bit_greater   (o_opcode_mmx_PCMPGTW_compare_packed_16_bit_greater),
    .o_opcode_mmx_PCMPGTD_compare_packed_32_bit_greater   (o_opcode_mmx_PCMPGTD_compare_packed_32_bit_greater)
);

stage_2_dec_mmx_opcode_logical u_logical (
    .i_instruction               (i_instruction),
    .o_opcode_mmx_PAND_bitwise_and    (o_opcode_mmx_PAND_bitwise_and),
    .o_opcode_mmx_PANDN_bitwise_and_not(o_opcode_mmx_PANDN_bitwise_and_not),
    .o_opcode_mmx_POR_bitwise_or      (o_opcode_mmx_POR_bitwise_or),
    .o_opcode_mmx_PXOR_bitwise_xor    (o_opcode_mmx_PXOR_bitwise_xor)
);

stage_2_dec_mmx_opcode_shift u_shift (
    .i_instruction                                         (i_instruction),
    .o_opcode_mmx_PSLLW_shift_left_logical_packed_16_bit      (o_opcode_mmx_PSLLW_shift_left_logical_packed_16_bit),
    .o_opcode_mmx_PSLLD_shift_left_logical_packed_32_bit      (o_opcode_mmx_PSLLD_shift_left_logical_packed_32_bit),
    .o_opcode_mmx_PSLLQ_shift_left_logical_packed_64_bit      (o_opcode_mmx_PSLLQ_shift_left_logical_packed_64_bit),
    .o_opcode_mmx_PSLLW_shift_left_logical_packed_16_bit_imm (o_opcode_mmx_PSLLW_shift_left_logical_packed_16_bit_imm),
    .o_opcode_mmx_PSLLD_shift_left_logical_packed_32_bit_imm (o_opcode_mmx_PSLLD_shift_left_logical_packed_32_bit_imm),
    .o_opcode_mmx_PSLLQ_shift_left_logical_packed_64_bit_imm (o_opcode_mmx_PSLLQ_shift_left_logical_packed_64_bit_imm),
    .o_opcode_mmx_PSRLW_shift_right_logical_packed_16_bit     (o_opcode_mmx_PSRLW_shift_right_logical_packed_16_bit),
    .o_opcode_mmx_PSRLD_shift_right_logical_packed_32_bit     (o_opcode_mmx_PSRLD_shift_right_logical_packed_32_bit),
    .o_opcode_mmx_PSRLQ_shift_right_logical_packed_64_bit     (o_opcode_mmx_PSRLQ_shift_right_logical_packed_64_bit),
    .o_opcode_mmx_PSRLW_shift_right_logical_packed_16_bit_imm(o_opcode_mmx_PSRLW_shift_right_logical_packed_16_bit_imm),
    .o_opcode_mmx_PSRLD_shift_right_logical_packed_32_bit_imm(o_opcode_mmx_PSRLD_shift_right_logical_packed_32_bit_imm),
    .o_opcode_mmx_PSRLQ_shift_right_logical_packed_64_bit_imm(o_opcode_mmx_PSRLQ_shift_right_logical_packed_64_bit_imm),
    .o_opcode_mmx_PSRAW_shift_right_arithmetic_packed_16_bit    (o_opcode_mmx_PSRAW_shift_right_arithmetic_packed_16_bit),
    .o_opcode_mmx_PSRAD_shift_right_arithmetic_packed_32_bit    (o_opcode_mmx_PSRAD_shift_right_arithmetic_packed_32_bit),
    .o_opcode_mmx_PSRAW_shift_right_arithmetic_packed_16_bit_imm(o_opcode_mmx_PSRAW_shift_right_arithmetic_packed_16_bit_imm),
    .o_opcode_mmx_PSRAD_shift_right_arithmetic_packed_32_bit_imm(o_opcode_mmx_PSRAD_shift_right_arithmetic_packed_32_bit_imm)
);

stage_2_dec_mmx_opcode_convert u_convert (
    .i_instruction                                         (i_instruction),
    .o_opcode_mmx_PACKSSWB_pack_signed_saturate_16_to_8      (o_opcode_mmx_PACKSSWB_pack_signed_saturate_16_to_8),
    .o_opcode_mmx_PACKSSDW_pack_signed_saturate_32_to_16    (o_opcode_mmx_PACKSSDW_pack_signed_saturate_32_to_16),
    .o_opcode_mmx_PACKUSWB_pack_unsigned_saturate_16_to_8   (o_opcode_mmx_PACKUSWB_pack_unsigned_saturate_16_to_8),
    .o_opcode_mmx_PUNPCKHBW_unpack_high_packed_8_to_16      (o_opcode_mmx_PUNPCKHBW_unpack_high_packed_8_to_16),
    .o_opcode_mmx_PUNPCKHWD_unpack_high_packed_16_to_32     (o_opcode_mmx_PUNPCKHWD_unpack_high_packed_16_to_32),
    .o_opcode_mmx_PUNPCKHDQ_unpack_high_packed_32_to_64     (o_opcode_mmx_PUNPCKHDQ_unpack_high_packed_32_to_64),
    .o_opcode_mmx_PUNPCKLBW_unpack_low_packed_8_to_16       (o_opcode_mmx_PUNPCKLBW_unpack_low_packed_8_to_16),
    .o_opcode_mmx_PUNPCKLWD_unpack_low_packed_16_to_32      (o_opcode_mmx_PUNPCKLWD_unpack_low_packed_16_to_32),
    .o_opcode_mmx_PUNPCKLDQ_unpack_low_packed_32_to_64      (o_opcode_mmx_PUNPCKLDQ_unpack_low_packed_32_to_64)
);

stage_2_dec_mmx_opcode_state u_state (
    .i_instruction                (i_instruction),
    .o_opcode_mmx_EMMS_empty_MMX_state (o_opcode_mmx_EMMS_empty_MMX_state)
);

assign o_opcode_mmx_any =
    o_opcode_mmx_MOVQ_move_64_bit |
    o_opcode_mmx_MOVD_move_32_bit |
    o_opcode_mmx_PADDB_add_packed_8_bit |
    o_opcode_mmx_EMMS_empty_MMX_state;

endmodule
