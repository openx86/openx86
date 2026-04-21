/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: MMX state management instruction decode
*/

module stage_2_dec_mmx_opcode_state (
    output logic                o_opcode_mmx_EMMS_empty_MMX_state,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

// State management instruction (0F 77)
assign o_opcode_mmx_EMMS_empty_MMX_state = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0111_0111);

endmodule
