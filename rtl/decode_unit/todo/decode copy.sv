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
    input  logic [ 7:0] i_instruction [0:15],
    input  logic        i_default_operand_size,
    output logic        o_segment_reg_used,
    output logic [ 2:0] o_segment_reg_index,
    output logic [ 1:0] o_scale_factor,
    output logic        o_base_reg_used,
    output logic [ 2:0] o_base_reg_index,
    output logic        o_index_reg_used,
    output logic [ 2:0] o_index_reg_index,
    output logic        o_gpr_reg_used,
    output logic [ 2:0] o_gpr_reg_index,
    output logic [ 2:0] o_gpr_reg_bit_width,
    output logic        o_displacement_is_present,
    output logic [31:0] o_displacement,
    output logic        o_immediate_is_present,
    output logic [31:0] o_immediate,
    output logic [15:0] o_bytes_consumed,
    output logic [241:0] o_opcode,
    // input  logic [`info_bit_width_len-1:0] bit_width,
    // output logic [`info_reg_seg_len-1:0] info_segment_reg,
    // output logic [`info_reg_gpr_len-1:0] info_base_reg,
    // output logic [`info_reg_gpr_len-1:0] info_index_reg,
    // output logic [`info_displacement_len-1:0] info_displacement,
    // output logic        sib_is_present,
    // output logic [ 3:0] instruction_length,
    // input  logic        valid,
    // output logic        ready,
);

wire  [ 7:0] stage_prefix_i_instruction [0:15] = i_instruction [0:15];
wire         stage_prefix_o_group_1_lock_bus;
wire         stage_prefix_o_group_1_repeat_not_equal;
wire         stage_prefix_o_group_1_repeat_equal;
wire         stage_prefix_o_group_1_bound;
wire         stage_prefix_o_group_2_segment_override;
wire         stage_prefix_o_group_2_hint_branch_not_taken;
wire         stage_prefix_o_group_2_hint_branch_taken;
wire         stage_prefix_o_group_3_operand_size;
wire         stage_prefix_o_group_4_address_size;
wire         stage_prefix_o_group_1_is_present;
wire         stage_prefix_o_group_2_is_present;
wire         stage_prefix_o_group_3_is_present;
wire         stage_prefix_o_group_4_is_present;
wire  [ 2:0] stage_prefix_o_segment_override_index;
wire         stage_prefix_o_error;
wire  [ 2:0] stage_prefix_o_consumed_instruction_bytes;

wire  [ 7:0] stage_opcode_i_instruction [0:15] = i_instruction [0:15];
wire [241:0] stage_opcode_o_opcode;

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
logic        stage_1_next_stage_decode_offset_1;
logic        stage_1_next_stage_decode_offset_2;
logic        stage_1_next_stage_decode_offset_3;
logic        stage_1_next_stage_decode_offset_4;

// TODO: connect to segment cache
logic [ 1:0] stage_2_mod;
logic [ 2:0] stage_2_rm;
logic        stage_2_w_is_present;
logic        stage_2_w;
logic        stage_2_segment_reg_used;
logic [ 2:0] stage_2_segment_reg_index;
logic        stage_2_base_reg_used;
logic [ 2:0] stage_2_base_reg_index;
logic        stage_2_index_reg_used;
logic [ 2:0] stage_2_index_reg_index;
logic        stage_2_gpr_reg_used;
logic [ 2:0] stage_2_gpr_reg_index;
logic [ 2:0] stage_2_gpr_reg_bit_width;
logic        stage_2_displacement_is_present;
logic [ 3:0] stage_2_displacement_length;
logic        stage_2_sib_is_present;

logic [ 1:0] stage_3_mod;
logic [ 1:0] stage_3_scale_factor;
logic        stage_3_index_reg_used;
logic [ 2:0] stage_3_index_reg_index;
logic        stage_3_base_reg_used;
logic [ 2:0] stage_3_base_reg_index;
logic        stage_3_displacement_is_present;
logic [ 3:0] stage_3_displacement_length;
logic        stage_3_effecitve_address_undefined;

logic [ 7:0] stage_4_instruction [0:7];
logic [ 3:0] stage_4_displacement_length;
logic [ 3:0] stage_4_immediate_length;
logic [31:0] stage_4_displacement;
logic [31:0] stage_4_immediate;

// wire  [ 2:0] stage_2_next_stage_decode_offset = stage_2_sib_is_present ? (stage_1_next_stage_decode_offset + 3'h1) : (stage_1_next_stage_decode_offset + 3'h0);
// wire  [ 2:0] stage_3_next_stage_decode_offset = stage_2_sib_is_present ? (stage_1_next_stage_decode_offset + 3'h2) : (stage_1_next_stage_decode_offset + 3'h1);

wire  [ 7:0] stage_0_instruction [0:2] = i_instruction[0:2];
wire  [ 7:0] stage_1_instruction [0:2] = i_instruction[0:2];
logic [ 7:0] stage_3_instruction;
// wire  [ 7:0] stage_4_instruction      [0:7] = i_instruction[stage_3_next_stage_decode_offset:stage_3_next_stage_decode_offset+7];
// wire  [ 7:0] instruction_for_decode_mod_rm             = i_instruction[offset_after_decode_field];
// wire  [ 7:0] instruction_for_decode_sib                = i_instruction[offset_after_decode_field + 1];
// wire  [ 7:0] instruction_for_decode_displacement       = i_instruction[offset_after_decode_field + 1];
// wire  [ 7:0] instruction_for_decode_immediate;
always_comb begin
    unique case (1'b1)
        stage_1_next_stage_decode_offset_1: begin
            stage_3_instruction <= i_instruction[1];
            stage_4_instruction <= stage_2_sib_is_present ? i_instruction[1+1:1+1+7] : i_instruction[1:1+7];
        end
        stage_1_next_stage_decode_offset_2: begin
            stage_3_instruction <= i_instruction[2];
            stage_4_instruction <= stage_2_sib_is_present ? i_instruction[2+1:2+1+7] : i_instruction[2:2+7];
        end
        stage_1_next_stage_decode_offset_3: begin
            stage_3_instruction <= i_instruction[3];
            stage_4_instruction <= stage_2_sib_is_present ? i_instruction[3+1:3+1+7] : i_instruction[3:3+7];
        end
        stage_1_next_stage_decode_offset_4: begin
            stage_3_instruction <= i_instruction[4];
            stage_4_instruction <= stage_2_sib_is_present ? i_instruction[4+1:4+1+7] : i_instruction[4:4+7];
        end
        default: begin
            stage_3_instruction <= i_instruction[0];
		      stage_4_instruction <= i_instruction[0:0+7];
		  end
    endcase
end

assign segment_reg_used = stage_2_segment_reg_used;
assign segment_reg_index = stage_2_segment_reg_index;
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

// logic [3:0] displacement_length;
// always_comb begin
//     unique case (1'b1)
//         stop_on_stage_1: displacement_length <= stage_1_displacement_length;
//         stop_on_stage_2: displacement_length <= stage_2_displacement_length;
//         default        : displacement_length <= stage_3_displacement_length;
//     endcase
// end

assign displacement_is_present = stage_2_sib_is_present ? stage_3_displacement_is_present : stage_2_displacement_is_present;
assign displacement = stage_4_displacement;
assign immediate_is_present    = stage_1_immediate_is_present;
assign immediate               = stage_4_immediate;


// calculate costed bytes
// wire costed_bytes_01 = stage_1_;
// assign costed_bytes = 0;

decode_stage_prefix decode_stage_1_prefix_in_decode (
    .i_instruction                   ( stage_prefix_i_instruction ),
    .o_group_1_lock_bus              ( stage_prefix_o_group_1_lock_bus ),
    .o_group_1_repeat_not_equal      ( stage_prefix_o_group_1_repeat_not_equal ),
    .o_group_1_repeat_equal          ( stage_prefix_o_group_1_repeat_equal ),
    .o_group_1_bound                 ( stage_prefix_o_group_1_bound ),
    .o_group_2_segment_override      ( stage_prefix_o_group_2_segment_override ),
    .o_group_2_hint_branch_not_taken ( stage_prefix_o_group_2_hint_branch_not_taken ),
    .o_group_2_hint_branch_taken     ( stage_prefix_o_group_2_hint_branch_taken ),
    .o_group_3_operand_size          ( stage_prefix_o_group_3_operand_size ),
    .o_group_4_address_size          ( stage_prefix_o_group_4_address_size ),
    .o_group_1_is_present            ( stage_prefix_o_group_1_is_present ),
    .o_group_2_is_present            ( stage_prefix_o_group_2_is_present ),
    .o_group_3_is_present            ( stage_prefix_o_group_3_is_present ),
    .o_group_4_is_present            ( stage_prefix_o_group_4_is_present ),
    .o_segment_override_index        ( stage_prefix_o_segment_override_index ),
    .o_error                         ( stage_prefix_o_error ),
    .o_consumed_instruction_bytes    ( stage_prefix_o_consumed_instruction_bytes )
);

decode_stage_opcode decode_stage_0_opcode_instance_in_decode (
    .i_instruction ( stage_opcode_i_instruction ),
    .o_opcode      ( stage_opcode_o_opcode ),
);

decode_stage_1 decode_stage_1_instance_in_decode (
    .opcode ( o_opcode ),
    .instruction ( i_instruction ),
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
    .next_stage_decode_offset_1 ( stage_1_next_stage_decode_offset_1 ),
    .next_stage_decode_offset_2 ( stage_1_next_stage_decode_offset_2 ),
    .next_stage_decode_offset_3 ( stage_1_next_stage_decode_offset_3 ),
    .next_stage_decode_offset_4 ( stage_1_next_stage_decode_offset_4 )
);

assign stage_2_mod          = stage_1_mod;
assign stage_2_rm           = stage_1_rm;
assign stage_2_w_is_present = stage_1_w_is_present;
assign stage_2_w            = stage_1_w;
decode_stage_2 decode_stage_2_instance_in_decode (
    .mod                             ( stage_2_mod ),
    .rm                              ( stage_2_rm ),
    .w_is_present                    ( stage_2_w_is_present ),
    .w                               ( stage_2_w ),
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
    .gpr_reg_used                    ( stage_2_gpr_reg_used ),
    .gpr_reg_index                   ( stage_2_gpr_reg_index ),
    .gpr_reg_bit_width               ( stage_2_gpr_reg_bit_width ),
    .displacement_is_present         ( stage_2_displacement_is_present ),
    .displacement_length             ( stage_2_displacement_length ),
    .sib_is_present                  ( stage_2_sib_is_present )
);

assign stage_3_mod = stage_1_mod;
decode_stage_3 decode_stage_3_instance_in_decode (
    .instruction                 ( stage_3_instruction ),
    .mod                         ( stage_3_mod ),
    .scale_factor                ( stage_3_scale_factor ),
    .index_reg_used              ( stage_3_index_reg_used ),
    .index_reg_index             ( stage_3_index_reg_index ),
    .base_reg_used               ( stage_3_base_reg_used ),
    .base_reg_index              ( stage_3_base_reg_index ),
    .displacement_is_present     ( stage_3_displacement_is_present ),
    .displacement_length         ( stage_3_displacement_length ),
    .effecitve_address_undefined ( stage_3_effecitve_address_undefined )
);

assign stage_4_displacement_is_present =  displacement_is_present;
assign stage_4_displacement_length            = stage_2_sib_is_present ? stage_3_displacement_length : stage_2_displacement_length;
assign stage_4_immediate_is_present    =  immediate_is_present;
assign stage_4_immediate_length        = stage_1_immediate_length;
decode_stage_4 decode_stage_4_instance_in_decode (
    .instruction             ( stage_4_instruction ),
    .displacement_is_present ( stage_4_displacement_is_present ),
    .displacement_length     ( stage_4_displacement_length ),
    .immediate_is_present    ( stage_4_immediate_is_present ),
    .immediate_length        ( stage_4_immediate_length ),
    .displacement            ( stage_4_displacement ),
    .immediate               ( stage_4_immediate )
);

endmodule
