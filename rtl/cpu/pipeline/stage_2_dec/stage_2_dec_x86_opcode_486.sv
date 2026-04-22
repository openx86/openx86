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
//  File        : stage_2_dec_x86_opcode_486.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_2_dec_x86_opcode_486 module
// ============================================================================

module stage_2_dec_x86_opcode_486 (
    output logic                o_opcode_x86_BSWAP_byte_swap,
    output logic                o_opcode_x86_CMPXCHG_compare_and_exchange,
    output logic                o_opcode_x86_CPUID_CPU_identification,
    output logic                o_opcode_x86_INVD_invalidate_cache,
    output logic                o_opcode_x86_INVLPG_invalidate_TLB_entry,
    output logic                o_opcode_x86_WBINVD_writeback_and_invalidate_data_cache,
    output logic                o_opcode_x86_XADD_exchange_and_add,
    output logic                o_opcode_x86_UD2_undefined_instruction,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

// 80486 new instructions

assign o_opcode_x86_BSWAP_byte_swap                                 = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 3] == 5'b1100_1);

assign o_opcode_x86_CMPXCHG_compare_and_exchange                = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 1] == 7'b1011_000);

assign o_opcode_x86_CPUID_CPU_identification                     = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1010_0010);

assign o_opcode_x86_INVD_invalidate_cache                        = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_1000);

assign o_opcode_x86_INVLPG_invalidate_TLB_entry                  = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0001) & (i_instruction[2][7: 6] != 2'b11) & (i_instruction[2][5: 3] == 3'b111);

assign o_opcode_x86_WBINVD_writeback_and_invalidate_data_cache    = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_1001);

assign o_opcode_x86_XADD_exchange_and_add                         = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 1] == 7'b1100_000);

assign o_opcode_x86_UD2_undefined_instruction                     = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_1011);

endmodule
