/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode unit
create at: 2022-01-04 03:27:51
description: decode unit module
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"

module decode (
    interface_opcode.opcode_output opcode,
    output logic        segment_reg_used,
    output logic [ 2:0] segment_reg_index,
    output logic [ 1:0] scale_factor,
    output logic        base_reg_used,
    output logic [ 2:0] base_reg_index,
    output logic        index_reg_used,
    output logic [ 2:0] index_reg_index,
    output logic [ 2:0] base_index_reg_bit_width,
    output logic        gpr_reg_used,
    output logic [ 2:0] gpr_reg_index,
    output logic [ 2:0] gpr_reg_bit_width,
    output logic [31:0] displacement,
    output logic [31:0] immediate,
    // input  logic [`info_bit_width_len-1:0] bit_width,
    // output logic [`info_reg_seg_len-1:0] info_segment_reg,
    // output logic [`info_reg_gpr_len-1:0] info_base_reg,
    // output logic [`info_reg_gpr_len-1:0] info_index_reg,
    // output logic [`info_displacement_len-1:0] info_displacement,
    // output logic        sib_is_present,
    // output logic [ 3:0] instruction_length,
    // input  logic        valid,
    // output logic        ready,
    // input  logic        default_operand_size,
    input  logic [ 7:0] instruction [0:15]
);

logic opcode_length_1;
logic opcode_length_2;
logic opcode_length_3;
logic opcode_length_4;

logic        stage_1_is_prefix_segment;
logic        stage_1_is_prefix;
logic        stage_1_s_is_present;
logic        stage_1_s;
logic        stage_1_w_is_present;
logic        stage_1_w;
logic        stage_1_greg_is_present;
logic [ 2:0] stage_1_greg;
logic        stage_1_sreg_is_present;
logic [ 2:0] stage_1_sreg;
logic        stage_1_mod_rm_is_present;
logic [ 1:0] stage_1_mod;
logic [ 2:0] stage_1_rm;
logic        stage_1_displacement_is_present;
logic [ 3:0] stage_1_displacement_length;
logic        stage_1_immediate_is_present;
logic [ 1:0] stage_1_immediate_length;
logic        stage_1_unsigned_full_offset_or_selector_is_present;
logic [ 2:0] stage_1_next_stage_decode_offset;

// TODO: connect to segment cache
wire         default_operand_size = `default_operation_size_16;
logic        stage_2_segment_reg_used;
logic [ 2:0] stage_2_segment_reg_index;
logic        stage_2_base_reg_used;
logic [ 2:0] stage_2_base_reg_index;
logic        stage_2_index_reg_used;
logic [ 2:0] stage_2_index_reg_index;
logic [ 2:0] stage_2_base_index_reg_bit_width;
logic        stage_2_gpr_reg_used;
logic [ 2:0] stage_2_gpr_reg_index;
logic [ 2:0] stage_2_gpr_reg_bit_width;
logic        stage_2_displacement_is_present;
logic [ 3:0] stage_2_displacement_length;
logic        stage_2_sib_is_present;

logic [ 1:0] stage_3_scale_factor;
logic        stage_3_index_reg_used;
logic [ 2:0] stage_3_index_reg_index;
logic        stage_3_base_reg_used;
logic [ 2:0] stage_3_base_reg_index;
logic        stage_3_displacement_is_present;
logic [ 3:0] stage_3_displacement_length;
logic        stage_3_effecitve_address_undefined;

wire  [ 2:0] stage_2_next_stage_decode_offset = stage_2_sib_is_present ? (stage_1_next_stage_decode_offset + 3'h1) : (stage_1_next_stage_decode_offset + 3'h0);
wire  [ 2:0] stage_3_next_stage_decode_offset = stage_2_sib_is_present ? (stage_1_next_stage_decode_offset + 3'h2) : (stage_1_next_stage_decode_offset + 3'h1);

wire  [ 7:0] instruction_for_decode_opcode       [0:2] = instruction[0:2];
wire  [ 7:0] stage_3_instruction            = instruction[stage_2_next_stage_decode_offset];
// wire  [ 7:0] stage_4_instruction      [0:7] = instruction[stage_3_next_stage_decode_offset:stage_3_next_stage_decode_offset+7];
wire  [ 7:0] stage_4_instruction [0:7];
// wire  [ 7:0] instruction_for_decode_mod_rm             = instruction[offset_after_decode_field];
// wire  [ 7:0] instruction_for_decode_sib                = instruction[offset_after_decode_field + 1];
// wire  [ 7:0] instruction_for_decode_displacement       = instruction[offset_after_decode_field + 1];
// wire  [ 7:0] instruction_for_decode_immediate;
always_comb begin
    case (stage_3_next_stage_decode_offset)
        3'h1:    stage_4_instruction <= instruction[1:1+7];
        3'h2:    stage_4_instruction <= instruction[2:2+7];
        3'h3:    stage_4_instruction <= instruction[3:3+7];
        default: stage_4_instruction <= instruction[0:0+7];
    endcase
end

logic        stage_4_displacement_is_present;
logic [ 3:0] stage_4_displacement_length;
logic        stage_4_immediate_is_present;
logic [ 3:0] stage_4_immediate_length;
logic [31:0] stage_4_displacement;
logic [31:0] stage_4_immediate;

assign segment_reg_used = stage_2_segment_reg_used;
assign segment_reg_index = stage_2_segment_reg_index;
assign base_index_reg_bit_width = stage_2_base_index_reg_bit_width;
assign gpr_reg_used = stage_2_gpr_reg_used;
assign gpr_reg_index = stage_2_gpr_reg_index;
assign gpr_reg_bit_width = stage_2_gpr_reg_bit_width;

assign scale_factor = stage_3_scale_factor;

assign base_reg_used   = stage_2_sib_is_present ? stage_3_base_reg_used   : stage_2_base_reg_used;
assign base_reg_index  = stage_2_sib_is_present ? stage_3_base_reg_index  : stage_2_base_reg_index;
assign index_reg_used  = stage_2_sib_is_present ? stage_3_index_reg_used  : stage_2_index_reg_used;
assign index_reg_index = stage_2_sib_is_present ? stage_3_index_reg_index : stage_2_index_reg_index;

wire stop_on_stage_1 = ~stage_1_mod_rm_is_present & ~stage_1_displacement_is_present & ~stage_1_immediate_is_present;
wire stop_on_stage_2 = ~stage_2_sib_is_present;

wire [3:0] displacement_length;
always_comb begin
    unique case (1'b1)
        stop_on_stage_1: displacement_length <= stage_1_displacement_length;
        stop_on_stage_2: displacement_length <= stage_2_displacement_length;
        default        : displacement_length <= stage_3_displacement_length;
    endcase
end

assign displacement = stage_4_displacement;
assign immediate = stage_4_immediate;

decode_stage_0_opcode decode_stage_0_opcode_instance_in_decode (
    .opcode ( opcode ),
    .instruction ( instruction_for_decode_opcode )
);

decode_stage_1 decode_stage_1_instance_in_decode (
    .opcode ( opcode ),
    .instruction ( instruction ),
    .is_prefix_segment ( stage_1_is_prefix_segment ),
    .is_prefix ( stage_1_is_prefix ),
    .s_is_present ( stage_1_s_is_present ),
    .s ( stage_1_s ),
    .w_is_present ( stage_1_w_is_present ),
    .w ( stage_1_w ),
    .greg_is_present ( stage_1_greg_is_present ),
    .greg ( stage_1_greg ),
    .sreg_is_present ( stage_1_sreg_is_present ),
    .sreg ( stage_1_sreg ),
    .mod_rm_is_present ( stage_1_mod_rm_is_present ),
    .mod ( stage_1_mod ),
    .rm ( stage_1_rm ),
    .displacement_is_present ( stage_1_displacement_is_present ),
    .displacement_length ( stage_1_displacement_length ),
    .immediate_is_present ( stage_1_immediate_is_present ),
    .immediate_length ( stage_1_immediate_length ),
    .unsigned_full_offset_or_selector_is_present ( stage_1_unsigned_full_offset_or_selector_is_present ),
    .next_stage_decode_offset ( stage_1_next_stage_decode_offset )
);

decode_stage_2 decode_stage_2_instance_in_decode (
    .mod                             ( stage_1_mod ),
    .rm                              ( stage_1_rm ),
    .w_is_present                    ( stage_1_w_is_present ),
    .w                               ( stage_1_w ),
    // .stage_1_displacement_is_present ( stage_1_displacement_is_present ),
    // .stage_1_displacement_length     ( stage_1_displacement_length ),
    // .stage_1_immediate_is_present    ( stage_1_immediate_is_present ),
    // .stage_1_immediate_length        ( stage_1_immediate_length ),
    .default_operand_size            ( default_operand_size ),
    .segment_reg_used                ( stage_2_segment_reg_used ),
    .segment_reg_index               ( stage_2_segment_reg_index ),
    .base_reg_used                   ( stage_2_base_reg_used ),
    .base_reg_index                  ( stage_2_base_reg_index ),
    .index_reg_used                  ( stage_2_index_reg_used ),
    .index_reg_index                 ( stage_2_index_reg_index ),
    .base_index_reg_bit_width        ( stage_2_base_index_reg_bit_width ),
    .gpr_reg_used                    ( stage_2_gpr_reg_used ),
    .gpr_reg_index                   ( stage_2_gpr_reg_index ),
    .gpr_reg_bit_width               ( stage_2_gpr_reg_bit_width ),
    .displacement_is_present         ( stage_2_displacement_is_present ),
    .displacement_length             ( stage_2_displacement_length ),
    .sib_is_present                  ( stage_2_sib_is_present )
);

decode_stage_3 decode_stage_3_instance_in_decode (
    .instruction                 ( stage_3_instruction ),
    .mod                         ( stage_1_mod ),
    .scale_factor                ( stage_3_scale_factor ),
    .index_reg_used              ( stage_3_index_reg_used ),
    .index_reg_index             ( stage_3_index_reg_index ),
    .base_reg_used               ( stage_3_base_reg_used ),
    .base_reg_index              ( stage_3_base_reg_index ),
    .displacement_is_present     ( stage_3_displacement_is_present ),
    .displacement_length         ( stage_3_displacement_length ),
    .effecitve_address_undefined ( stage_3_effecitve_address_undefined )
);

decode_stage_4 decode_stage_4_instance_in_decode (
    .instruction             ( stage_4_instruction ),
    .displacement_is_present ( stage_3_displacement_is_present ),
    .displacement_length     ( stage_3_displacement_length ),
    .immediate_is_present    ( stage_1_immediate_is_present ),
    .immediate_length        ( stage_1_immediate_length ),
    .displacement            ( stage_4_displacement ),
    .immediate               ( stage_4_immediate )
);

endmodule
