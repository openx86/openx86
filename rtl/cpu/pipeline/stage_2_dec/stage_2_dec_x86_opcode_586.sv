/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: Pentium (586) x86 opcode decode (new instructions)
*/

module stage_2_dec_x86_opcode_586 (
    output logic                o_opcode_x86_RDTSC_read_time_stamp_counter,
    output logic                o_opcode_x86_RDMSR_read_from_model_specific_reg,
    output logic                o_opcode_x86_WRMSR_write_to_model_specific_register,
    output logic                o_opcode_x86_RSM_resume_from_system_management_mode,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

// Pentium (586) new instructions

assign o_opcode_x86_RDTSC_read_time_stamp_counter                               = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0011_0001);

assign o_opcode_x86_RDMSR_read_from_model_specific_reg                          = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0011_0010);

assign o_opcode_x86_WRMSR_write_to_model_specific_register                      = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b0011_0000);

assign o_opcode_x86_RSM_resume_from_system_management_mode                      = (i_instruction[0][ 7: 0] == 8'b0000_1111) & (i_instruction[1][ 7: 0] == 8'b1010_1010);

endmodule
