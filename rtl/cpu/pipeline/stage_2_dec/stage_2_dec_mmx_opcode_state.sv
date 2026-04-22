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
//  File        : stage_2_dec_mmx_opcode_state.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_2_dec_mmx_opcode_state module
// ============================================================================

module stage_2_dec_mmx_opcode_state (
    output logic                o_opcode_mmx_EMMS_empty_MMX_state,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

// State management instruction (0F 77)
assign o_opcode_mmx_EMMS_empty_MMX_state = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0111_0111);

endmodule
