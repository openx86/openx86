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
//  File        : stage_2_dec_x86_opcode_286.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : stage_2_dec_x86_opcode_286 module
// ============================================================================

module stage_2_dec_x86_opcode_286 (
    output logic                o_opcode_x86_ARPL_adjust_RPL_field_of_selector,
    output logic                o_opcode_x86_CLTS_clear_task_switched_flag,
    output logic                o_opcode_x86_LGDT_load_global_desciptor_table_reg,
    output logic                o_opcode_x86_SGDT_store_global_descriptor_table_register,
    output logic                o_opcode_x86_LIDT_load_interrupt_desciptor_table_reg,
    output logic                o_opcode_x86_SIDT_store_interrupt_desciptor_table_register,
    output logic                o_opcode_x86_LLDT_load_local_desciptor_table_reg,
    output logic                o_opcode_x86_SLDT_store_local_desciptor_table_register,
    output logic                o_opcode_x86_LMSW_load_status_word,
    output logic                o_opcode_x86_SMSW_store_machine_status_word,
    output logic                o_opcode_x86_LTR_load_task_register,
    output logic                o_opcode_x86_STR_store_task_register,
    output logic                o_opcode_x86_LAR_load_access_rights_byte,
    output logic                o_opcode_x86_LSL_load_segment_limit,
    output logic                o_opcode_x86_VERR_verify_a_segment_for_reading,
    output logic                o_opcode_x86_VERW_verify_a_segment_for_writing,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

// 80286 new instructions

assign o_opcode_x86_ARPL_adjust_RPL_field_of_selector  = (i_instruction[0][7: 0] == 8'b0110_0011);

assign o_opcode_x86_CLTS_clear_task_switched_flag      = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0110);

assign o_opcode_x86_LGDT_load_global_desciptor_table_reg   = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0001) & (i_instruction[2][5: 3] == 3'b010);
assign o_opcode_x86_SGDT_store_global_descriptor_table_register = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0001) & (i_instruction[2][5: 3] == 3'b000);

assign o_opcode_x86_LIDT_load_interrupt_desciptor_table_reg   = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0001) & (i_instruction[2][5: 3] == 3'b011);
assign o_opcode_x86_SIDT_store_interrupt_desciptor_table_register = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0001) & (i_instruction[2][5: 3] == 3'b001);

assign o_opcode_x86_LLDT_load_local_desciptor_table_reg   = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0000) & (i_instruction[2][5: 3] == 3'b010);
assign o_opcode_x86_SLDT_store_local_desciptor_table_register = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0000) & (i_instruction[2][5: 3] == 3'b000);

assign o_opcode_x86_LMSW_load_status_word          = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0001) & (i_instruction[2][5: 3] == 3'b110);
assign o_opcode_x86_SMSW_store_machine_status_word = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0001) & (i_instruction[2][5: 3] == 3'b100);

assign o_opcode_x86_LTR_load_task_register  = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0000) & (i_instruction[2][5: 3] == 3'b011);
assign o_opcode_x86_STR_store_task_register = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0000) & (i_instruction[2][5: 3] == 3'b001);

assign o_opcode_x86_LAR_load_access_rights_byte = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0010);

assign o_opcode_x86_LSL_load_segment_limit = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0011);

assign o_opcode_x86_VERR_verify_a_segment_for_reading = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0000) & (i_instruction[2][5: 3] == 3'b100);
assign o_opcode_x86_VERW_verify_a_segment_for_writing = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0000) & (i_instruction[2][5: 3] == 3'b101);

endmodule
