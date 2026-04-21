/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: MMX data transfer instruction decode
*/

module stage_2_dec_mmx_opcode_data (
    output logic                o_opcode_mmx_MOVQ_move_64_bit,
    output logic                o_opcode_mmx_MOVD_move_32_bit,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

// Data transfer instructions (0F 6E/7E, 0F 10-15)
assign o_opcode_mmx_MOVD_move_32_bit = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (
    (i_instruction[1][ 7: 0] == 8'b0110_1110) | // MOVD reg/m32, mm
    (i_instruction[1][ 7: 0] == 8'b0111_1110)    // MOVD mm, reg/m32
);
assign o_opcode_mmx_MOVQ_move_64_bit = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (
    (i_instruction[1][ 7: 0] == 8'b0110_1111) | // MOVQ reg/m64, mm
    (i_instruction[1][ 7: 0] == 8'b0111_1111)    // MOVQ mm, reg/m64
);

endmodule
