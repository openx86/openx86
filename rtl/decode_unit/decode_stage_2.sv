/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_stage_2
create at: 2022-02-25 05:00:08
description: decode_stage_2
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"

module decode_stage_2 (
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
    output logic        o_x86_ADC_reg_1_to_reg_2,
    output logic        o_x86_ADC_reg_2_to_reg_1,
    output logic        o_x86_ADC_mem_to_reg,
    output logic        o_x86_ADC_reg_to_mem,
    output logic        o_x86_ADC_imm_to_reg,
    output logic        o_x86_ADC_imm_to_acc,
    output logic        o_x86_ADC_imm_to_mem,
    output logic        o_error_stage_2
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

decode_opcode decode_decode_opcode (
    .i_instruction ( instruction_for_decode_opcode ),
    .o_x86_ADC_reg_1_to_reg_2 ( o_x86_ADC_reg_1_to_reg_2 ),
    .o_x86_ADC_reg_2_to_reg_1 ( o_x86_ADC_reg_2_to_reg_1 ),
    .o_x86_ADC_mem_to_reg ( o_x86_ADC_mem_to_reg ),
    .o_x86_ADC_reg_to_mem ( o_x86_ADC_reg_to_mem ),
    .o_x86_ADC_imm_to_reg ( o_x86_ADC_imm_to_reg ),
    .o_x86_ADC_imm_to_acc ( o_x86_ADC_imm_to_acc ),
    .o_x86_ADC_imm_to_mem ( o_x86_ADC_imm_to_mem ),
    .o_error ( o_error_stage_2 )
);

endmodule
