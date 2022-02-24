/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_stage_4
create at: 2022-02-25 05:10:03
description: decode_stage_4
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"

module decode_stage_4 (
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
    output logic [ 2:0] o_segment_reg_index,
    output logic        o_base_reg_is_present,
    output logic [ 2:0] o_base_reg_index,
    output logic        o_index_reg_is_present,
    output logic [ 2:0] o_index_reg_index,
    output logic        o_displacement_size_1,
    output logic        o_displacement_size_2,
    output logic        o_displacement_size_4,
    output logic [ 1:0] o_scale_factor,
    output logic        o_error_stage_4
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

wire [1:0] offset_sib;
always_comb begin
    unique case (1'b1)
        i_consume_bytes_opcode_1 : offset_sib <= 1;
        i_consume_bytes_opcode_2 : offset_sib <= 2;
        i_consume_bytes_opcode_3 : offset_sib <= 3;
        default                  : offset_sib <= 0;
    endcase
end

wire [ 3:0] offset_instruction_byte = offset_opcode + offset_sib;
wire [ 7:0] instruction_for_decode_sib = i_instruction[offset_instruction_byte];

// wire [ 7:0] instruction_for_decode_opcode [0:3] = i_instruction [0:3];

wire o_sib_is_present;

wire mod_rm_o_segment_reg_index;
wire mod_rm_o_base_reg_is_present;
wire mod_rm_o_base_reg_index;
wire mod_rm_o_index_reg_is_present;
wire mod_rm_o_index_reg_index;
wire mod_rm_o_displacement_size_1;
wire mod_rm_o_displacement_size_2;
wire mod_rm_o_displacement_size_4;

wire sib_o_segment_reg_index;
wire sib_o_index_reg_is_present;
wire sib_o_index_reg_index;
wire sib_o_base_reg_is_present;
wire sib_o_base_reg_index;
wire sib_o_displacement_size_1;
wire sib_o_displacement_size_4;
wire sib_o_error_from;

always_comb begin
    if (i_group_2_segment_override) begin
        o_segment_reg_index <= i_segment_override_index;
    end else begin
        if (o_sib_is_present) begin
            o_segment_reg_index <= sib_o_segment_reg_index_from;
        end else begin
            o_segment_reg_index <= mod_rm_o_segment_reg_index;
        end
    end

    if (o_sib_is_present) begin
        o_base_reg_is_present <= sib_o_base_reg_is_present;
        o_base_reg_index <= sib_o_base_reg_index;
        o_index_reg_is_present <= sib_o_index_reg_is_present;
        o_index_reg_index <= sib_o_index_reg_index;
        o_displacement_size_1 <= sib_o_displacement_size_1;
        o_displacement_size_2 <= 0;
        o_displacement_size_4 <= sib_o_displacement_size_4;
    end else begin
        o_base_reg_is_present <= mod_rm_o_base_reg_is_present;
        o_base_reg_index <= mod_rm_o_base_reg_index;
        o_index_reg_is_present <= mod_rm_o_index_reg_is_present;
        o_index_reg_index <= mod_rm_o_index_reg_index;
        o_displacement_size_1 <= mod_rm_o_displacement_size_1;
        o_displacement_size_2 <= mod_rm_o_displacement_size_2;
        o_displacement_size_4 <= mod_rm_o_displacement_size_4;
    end
end

decode_mod_rm decode_decode_mod_rm (
    .i_mod ( i_mod ),
    .i_rm ( i_rm ),
    .i_default_operand_size ( i_default_operand_size ),
    .o_segment_reg_index ( mod_rm_o_segment_reg_index ),
    .o_base_reg_is_present ( mod_rm_o_base_reg_is_present ),
    .o_base_reg_index ( mod_rm_o_base_reg_index ),
    .o_index_reg_is_present ( mod_rm_o_index_reg_is_present ),
    .o_index_reg_index ( mod_rm_o_index_reg_index ),
    .o_displacement_size_1 ( mod_rm_o_displacement_size_1 ),
    .o_displacement_size_2 ( mod_rm_o_displacement_size_2 ),
    .o_displacement_size_4 ( mod_rm_o_displacement_size_4 ),
    .o_sib_is_present ( o_sib_is_present )
);

decode_sib decode_decode_sib (
    .i_sib ( instruction_for_decode_sib ),
    .i_mod ( i_mod ),
    .o_scale_factor ( o_scale_factor ),
    .o_segment_reg_index ( sib_o_segment_reg_index_from ),
    .o_index_reg_is_present ( sib_o_index_reg_is_present_from ),
    .o_index_reg_index ( sib_o_index_reg_index_from ),
    .o_base_reg_is_present ( sib_o_base_reg_is_present_from ),
    .o_base_reg_index ( sib_o_base_reg_index_from ),
    .o_displacement_size_1 ( sib_o_displacement_size_1_from ),
    .o_displacement_size_4 ( sib_o_displacement_size_4_from ),
    .o_effecitve_address_undefined ( sib_o_error_from )
);

endmodule
