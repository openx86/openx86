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
//  File        : stage_2_dec_x86_opcode_586.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_2_dec_x86_opcode_586 module
// ============================================================================

module stage_2_dec_x86_opcode_586 (
    output logic                o_opcode_x86_RDTSC_read_time_stamp_counter,
    output logic                o_opcode_x86_RDMSR_read_from_model_specific_reg,
    output logic                o_opcode_x86_WRMSR_write_to_model_specific_register,
    output logic                o_opcode_x86_RSM_resume_from_system_management_mode,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

// Pentium (586) new instructions

assign o_opcode_x86_RDTSC_read_time_stamp_counter    = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0011_0001);

assign o_opcode_x86_RDMSR_read_from_model_specific_reg = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0011_0010);

assign o_opcode_x86_WRMSR_write_to_model_specific_register = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0011_0000);

assign o_opcode_x86_RSM_resume_from_system_management_mode = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1010_1010);

endmodule
