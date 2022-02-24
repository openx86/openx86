/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_stage_3
create at: 2022-02-25 04:59:59
description: decode_stage_3
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"

module decode_stage_3 (
    input  logic [ 7:0] i_instruction [0:15],
    input  logic        i_default_operand_size,
    input  logic        i_group_1_lock_bus,
    input  logic        i_group_1_repeat_not_equal,
    input  logic        i_group_1_repeat_equal,
    input  logic        i_group_1_bound,
    input  logic        i_group_2_segment_override,
    input  logic        i_group_2_hint_branch_not_taken,
    input  logic        i_group_2_hint_branch_taken,
    input  logic        i_group_3_operand_size,
    input  logic        i_group_4_address_size,
    input  logic [ 2:0] i_segment_override_index,
    input  logic        i_consume_bytes_prefix_1,
    input  logic        i_consume_bytes_prefix_2,
    input  logic        i_consume_bytes_prefix_3,
    input  logic        i_consume_bytes_prefix_4,
    input  logic        i_error_stage_1,
    input  logic        i_x86_ADC_reg_1_to_reg_2,
    input  logic        i_x86_ADC_reg_2_to_reg_1,
    input  logic        i_x86_ADC_mem_to_reg,
    input  logic        i_x86_ADC_reg_to_mem,
    input  logic        i_x86_ADC_imm_to_reg,
    input  logic        i_x86_ADC_imm_to_acc,
    input  logic        i_x86_ADC_imm_to_mem,
    input  logic        i_error_stage_2,
    output logic [ 2:0] o_index_reg_gen [0:2],
    output logic        o_index_reg_gen_is_present,
    output logic [ 2:0] o_index_reg_seg,
    output logic        o_index_reg_seg_is_present,
    output logic        o_w_is_present,
    output logic        o_w,
    output logic        o_s_is_present,
    output logic        o_s,
    output logic        o_mod_rm_is_present,
    output logic [ 1:0] o_mod,
    output logic [ 2:0] o_rm,
    output logic        o_immediate_size_full,
    output logic        o_consume_bytes_opcode_1,
    output logic        o_consume_bytes_opcode_2,
    output logic        o_consume_bytes_opcode_3,
    output logic        o_error_stage_3
);

wire [ 7:0] instruction_for_decode_opcode [0:3];

always_comb begin
    unique case (1'b1)
        i_consume_bytes_prefix_1 : instruction_for_decode_opcode <= i_instruction[1:1+3];
        i_consume_bytes_prefix_2 : instruction_for_decode_opcode <= i_instruction[2:2+3];
        i_consume_bytes_prefix_3 : instruction_for_decode_opcode <= i_instruction[3:3+3];
        i_consume_bytes_prefix_4 : instruction_for_decode_opcode <= i_instruction[4:4+3];
        default                  : instruction_for_decode_opcode <= i_instruction[0:0+3];
    endcase
end

decode_field decode_decode_field (
    .i_instruction ( instruction_for_decode_opcode ),
    .i_x86_ADC_reg_1_to_reg_2 ( i_x86_ADC_reg_1_to_reg_2 ),
    .i_x86_ADC_reg_2_to_reg_1 ( i_x86_ADC_reg_2_to_reg_1 ),
    .i_x86_ADC_mem_to_reg ( i_x86_ADC_mem_to_reg ),
    .i_x86_ADC_reg_to_mem ( i_x86_ADC_reg_to_mem ),
    .i_x86_ADC_imm_to_reg ( i_x86_ADC_imm_to_reg ),
    .i_x86_ADC_imm_to_acc ( i_x86_ADC_imm_to_acc ),
    .i_x86_ADC_imm_to_mem ( i_x86_ADC_imm_to_mem ),
    .o_index_reg_gen ( o_index_reg_gen ),
    .o_index_reg_gen_is_present ( o_index_reg_gen_is_present ),
    .o_index_reg_seg ( o_index_reg_seg ),
    .o_index_reg_seg_is_present ( o_index_reg_seg_is_present ),
    .o_w_is_present ( o_w_is_present ),
    .o_w ( o_w ),
    .o_s_is_present ( o_s_is_present ),
    .o_s ( o_s ),
    .o_mod_rm_is_present ( o_mod_rm_is_present ),
    .o_mod ( o_mod ),
    .o_rm ( o_rm ),
    .o_immediate_size_full ( o_immediate_size_full ),
    .o_consume_bytes_opcode_1 ( o_consume_bytes_opcode_1 ),
    .o_consume_bytes_opcode_2 ( o_consume_bytes_opcode_2 ),
    .o_consume_bytes_opcode_3 ( o_consume_bytes_opcode_3 ),
    .o_error ( o_error_stage_3 )
);

endmodule
