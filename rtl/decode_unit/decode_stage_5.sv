/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_stage_5
create at: 2022-02-25 06:33:26
description: decode_stage_5
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"

module decode_stage_5 (
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
    input  logic [ 2:0] i_index_reg_gen [0:2],
    input  logic        i_index_reg_gen_is_present,
    input  logic [ 2:0] i_index_reg_seg,
    input  logic        i_index_reg_seg_is_present,
    input  logic        i_w_is_present,
    input  logic        i_w,
    input  logic        i_s_is_present,
    input  logic        i_s,
    input  logic        i_mod_rm_is_present,
    input  logic [ 1:0] i_mod,
    input  logic [ 2:0] i_rm,
    input  logic        i_immediate_size_f,
    input  logic        i_consume_bytes_opcode_1,
    input  logic        i_consume_bytes_opcode_2,
    input  logic        i_consume_bytes_opcode_3,
    input  logic        i_error_stage_3,
    input  logic [ 2:0] i_segment_reg_index,
    input  logic        i_base_reg_is_present,
    input  logic [ 2:0] i_base_reg_index,
    input  logic        i_index_reg_is_present,
    input  logic [ 2:0] i_index_reg_index,
    input  logic        i_displacement_size_1,
    input  logic        i_displacement_size_2,
    input  logic        i_displacement_size_4,
    input  logic        i_sib_is_present,
    input  logic [ 1:0] i_scale_factor,
    input  logic        i_error_stage_4,
    output logic [31:0] o_displacement,
    output logic [31:0] o_immediate,
    output logic [ 3:0] o_consume_bytes,
    output logic        o_error_stage_5
);

wire [2:0] offset_opcode;
always_comb begin
    unique case (1'b1)
        i_consume_bytes_prefix_1 : offset_opcode <= 1;
        i_consume_bytes_prefix_2 : offset_opcode <= 2;
        i_consume_bytes_prefix_3 : offset_opcode <= 3;
        i_consume_bytes_prefix_4 : offset_opcode <= 4;
        default                  : offset_opcode <= 0;
    endcase
end

wire [ 2:0] offset_displacement;
always_comb begin
    unique case (1'b1)
        i_consume_bytes_opcode_1 : offset_displacement <= i_sib_is_present ? (1 + 1) : 1;
        i_consume_bytes_opcode_2 : offset_displacement <= i_sib_is_present ? (2 + 1) : 2;
        i_consume_bytes_opcode_3 : offset_displacement <= i_sib_is_present ? (3 + 1) : 3;
        default                  : offset_displacement <= i_sib_is_present ? (0 + 1) : 0;
    endcase
end

wire [ 3:0] offset = offset_opcode + offset_displacement;

wire [ 7:0] instruction_for_decode_disp_imm [0:7];
always_comb begin
    unique case (offset)
              1 : instruction_for_decode_disp_imm <= i_instruction[1:1+7];
              2 : instruction_for_decode_disp_imm <= i_instruction[2:2+7];
              3 : instruction_for_decode_disp_imm <= i_instruction[3:3+7];
              4 : instruction_for_decode_disp_imm <= i_instruction[4:4+7];
              5 : instruction_for_decode_disp_imm <= i_instruction[5:5+7];
              6 : instruction_for_decode_disp_imm <= i_instruction[6:6+7];
              7 : instruction_for_decode_disp_imm <= i_instruction[7:7+7];
        default : instruction_for_decode_disp_imm <= i_instruction[0:0+7];
    endcase
end

wire  [ 3:0] disp_imm_o_bytes_consumed;
assign o_consume_bytes = offset + disp_imm_o_bytes_consumed;

decode_disp_imm decode_decode_disp_imm (
    .i_instruction ( instruction_for_decode_disp_imm ),
    .i_displacement_size_1 ( i_displacement_size_1 ),
    .i_displacement_size_2 ( i_displacement_size_2 ),
    .i_displacement_size_4 ( i_displacement_size_4 ),
    // .i_immediate_size_1 ( i_immediate_size_1 ),
    // .i_immediate_size_2 ( i_immediate_size_2 ),
    // .i_immediate_size_4 ( i_immediate_size_4 ),
    .i_immediate_size_f ( i_immediate_size_f ),
    .o_displacement ( o_displacement ),
    .o_immediate ( o_immediate ),
    .o_consume_bytes ( disp_imm_o_bytes_consumed ),
    .o_error ( o_error_stage_5 )
);

endmodule
