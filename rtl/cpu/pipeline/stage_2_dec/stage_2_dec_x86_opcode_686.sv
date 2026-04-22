/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: P6 (686) and later x86 opcode decode (new instructions)
*/

module stage_2_dec_x86_opcode_686 (
    output logic                o_opcode_x86_RDPMC_read_performance_monitoring_counters,
    output logic                o_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id,
    output logic                o_opcode_x86_NOP_no_operation_multi_byte,
    output logic                o_opcode_x86_UD0_undefined_instruction,
    output logic                o_opcode_x86_UD1_undefined_instruction,
    output logic                o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg,
    output logic                o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem,
    output logic                o_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size,
    input  logic [ 3: 0][ 7: 0] i_instruction
);

// P6 (686) and later new instructions
// Note: Some of these are post-P6 (Atom/Haswell era) but grouped here as the highest generation

assign o_opcode_x86_RDPMC_read_performance_monitoring_counters    = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0011_0011);

assign o_opcode_x86_RDTSC_read_time_stamp_counter_and_processor_id = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0000_0001) & (i_instruction[2][7: 0] == 8'b1111_1001);

assign o_opcode_x86_NOP_no_operation_multi_byte                 = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0001_1111) & (i_instruction[2][5: 3] == 3'b000);

assign o_opcode_x86_UD0_undefined_instruction                     = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1111_1111);

assign o_opcode_x86_UD1_undefined_instruction                     = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b1011_1001);

assign o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_mem_to_reg   = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0011_1000) & (i_instruction[2][7: 0] == 8'b1111_0000);
assign o_opcode_x86_MOVBE_move_data_after_swapping_bytes_reg_to_reg_mem   = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0011_1000) & (i_instruction[2][7: 0] == 8'b1111_0001);

assign o_opcode_x86_INVPCID_invalidate_process_ctx_id_without_pfx_operand_size = (i_instruction[0][7: 0] == 8'b0000_1111) & (i_instruction[1][7: 0] == 8'b0011_1000) & (i_instruction[2][7: 0] == 8'b1000_0010);

endmodule
