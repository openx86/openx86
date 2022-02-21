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
    output logic[241:0] o_opcode,
    output logic        o_prefix_lock_bus,
    output logic        o_prefix_repeat_not_equal,
    output logic        o_prefix_repeat_equal,
    output logic        o_prefix_bound,
    output logic        o_prefix_hint_branch_not_taken,
    output logic        o_prefix_hint_branch_taken,
    output logic        o_field_gen_reg_is_present,
    output logic [ 2:0] o_field_gen_reg_index,
    output logic [ 2:0] o_segment_reg_index,
    output logic [ 1:0] o_scale_factor,
    output logic        o_base_reg_is_present,
    output logic [ 2:0] o_base_reg_index,
    output logic        o_index_reg_is_present,
    output logic [ 2:0] o_index_reg_index,
    output logic        o_mod_rm_gen_reg_is_present,
    output logic [ 2:0] o_mod_rm_gen_reg_index,
    output logic [ 2:0] o_mod_rm_gen_reg_bit_width,
    output logic        o_displacement_is_present,
    output logic [31:0] o_displacement,
    output logic        o_immediate_is_present,
    output logic [31:0] o_immediate,
    output logic [ 4:0] o_bytes_consumed,
    output logic        o_error
);

logic [ 7:0] stage_prefix_i_instruction [0:3];
logic        stage_prefix_o_group_1_lock_bus;
logic        stage_prefix_o_group_1_repeat_not_equal;
logic        stage_prefix_o_group_1_repeat_equal;
logic        stage_prefix_o_group_1_bound;
logic        stage_prefix_o_group_2_segment_override;
logic        stage_prefix_o_group_2_hint_branch_not_taken;
logic        stage_prefix_o_group_2_hint_branch_taken;
logic        stage_prefix_o_group_3_operand_size;
logic        stage_prefix_o_group_4_address_size;
logic        stage_prefix_o_group_1_is_present;
logic        stage_prefix_o_group_2_is_present;
logic        stage_prefix_o_group_3_is_present;
logic        stage_prefix_o_group_4_is_present;
logic [ 2:0] stage_prefix_o_segment_override_index;
logic        stage_prefix_o_error;
logic [ 2:0] stage_prefix_o_consumed_instruction_bytes;

logic [ 7:0] stage_opcode_i_instruction [0:2];
logic[241:0] stage_opcode_o_opcode;

logic [ 7:0] stage_field_i_instruction [0:2];
logic[241:0] stage_field_i_opcode;
logic        stage_field_o_s_is_present;
logic        stage_field_o_s;
logic        stage_field_o_w_is_present;
logic        stage_field_o_w;
logic        stage_field_o_gen_reg_is_present;
logic [ 2:0] stage_field_o_gen_reg_index;
logic        stage_field_o_seg_reg_is_present;
logic [ 2:0] stage_field_o_seg_reg_index;
logic        stage_field_o_mod_rm_is_present;
logic [ 1:0] stage_field_o_mod;
logic [ 2:0] stage_field_o_rm;
logic        stage_field_o_displacement_is_present;
logic [ 2:0] stage_field_o_displacement_length; // all 0: unknwon, 3: full, 2: 32, 1:
logic        stage_field_o_immediate_is_present;
logic [ 1:0] stage_field_o_immediate_length; // 1: full, 2: 8-bit
logic        stage_field_o_unsigned_full_offset_or_selector_is_present;
logic [ 2:0] stage_field_o_bytes_consumed;
logic        stage_field_o_error;

logic [ 1:0] stage_mod_rm_i_mod;
logic [ 2:0] stage_mod_rm_i_rm;
logic        stage_mod_rm_i_w_is_present;
logic        stage_mod_rm_i_w;
logic        stage_mod_rm_i_default_operand_size;
logic [ 2:0] stage_mod_rm_o_segment_reg_index;
logic        stage_mod_rm_o_base_reg_is_present;
logic [ 2:0] stage_mod_rm_o_base_reg_index;
logic        stage_mod_rm_o_index_reg_is_present;
logic [ 2:0] stage_mod_rm_o_index_reg_index;
logic        stage_mod_rm_o_gen_reg_is_present;
logic [ 2:0] stage_mod_rm_o_gen_reg_index;
logic [ 2:0] stage_mod_rm_o_gen_reg_bit_width;
logic        stage_mod_rm_o_displacement_is_present;
logic [ 3:0] stage_mod_rm_o_displacement_length;
logic        stage_mod_rm_o_sib_is_present;

logic [ 7:0] stage_sib_i_sib;
logic [ 1:0] stage_sib_i_mod;
logic [ 1:0] stage_sib_o_scale_factor;
logic        stage_sib_o_index_reg_is_present;
logic [ 2:0] stage_sib_o_index_reg_index;
logic        stage_sib_o_base_reg_is_present;
logic [ 2:0] stage_sib_o_base_reg_index;
logic        stage_sib_o_displacement_is_present;
logic [ 3:0] stage_sib_o_displacement_length;
logic        stage_sib_o_effecitve_address_undefined;

logic [ 7:0] stage_disp_imm_i_instruction [0:7];
logic        stage_disp_imm_i_displacement_is_present;
logic [ 3:0] stage_disp_imm_i_displacement_length;
logic        stage_disp_imm_i_immediate_is_present;
logic [ 3:0] stage_disp_imm_i_immediate_length;
logic [31:0] stage_disp_imm_o_displacement;
logic [31:0] stage_disp_imm_o_immediate;
logic [ 3:0] stage_disp_imm_o_bytes_consumed;

assign stage_prefix_i_instruction = i_instruction [0:3];
always_comb begin
    case (stage_prefix_o_consumed_instruction_bytes)
        1      : stage_opcode_i_instruction <= i_instruction[0+1:2+1];
        2      : stage_opcode_i_instruction <= i_instruction[0+2:2+2];
        3      : stage_opcode_i_instruction <= i_instruction[0+3:2+3];
        4      : stage_opcode_i_instruction <= i_instruction[0+4:2+4];
        default: stage_opcode_i_instruction <= i_instruction[0+0:2+0];
    endcase
end

assign stage_field_i_instruction = stage_opcode_i_instruction;
assign stage_field_i_opcode = stage_opcode_o_opcode;

logic [7:0] mod_rm;
always_comb begin
    case (stage_field_o_bytes_consumed)
        1      : mod_rm <= i_instruction[0+0];
        2      : mod_rm <= i_instruction[0+1];
        3      : mod_rm <= i_instruction[0+2];
        4      : mod_rm <= i_instruction[0+3];
        default: mod_rm <= i_instruction[0+0];
    endcase
end
assign stage_mod_rm_i_mod = mod_rm[7:6];
assign stage_mod_rm_i_rm  = mod_rm[2:0];
assign stage_mod_rm_i_w_is_present = stage_field_o_w_is_present;
assign stage_mod_rm_i_w = stage_field_o_w;
assign stage_mod_rm_i_default_operand_size = i_default_operand_size;

wire  [ 3:0] bytes_offset_mod_rm = stage_prefix_o_consumed_instruction_bytes + stage_field_o_bytes_consumed;
// wire  [ 3:0] bytes_offset_sib    = bytes_offset_mod_rm + 1;
always_comb begin
    unique case (bytes_offset_mod_rm)
        1: begin stage_sib_i_sib <= i_instruction[2]; stage_sib_i_mod <= i_instruction[1][7:6]; end
        2: begin stage_sib_i_sib <= i_instruction[3]; stage_sib_i_mod <= i_instruction[2][7:6]; end
        3: begin stage_sib_i_sib <= i_instruction[4]; stage_sib_i_mod <= i_instruction[3][7:6]; end
        4: begin stage_sib_i_sib <= i_instruction[5]; stage_sib_i_mod <= i_instruction[4][7:6]; end
        default: begin stage_sib_i_sib <= 0; stage_sib_i_mod <= 0; end
    endcase
end

always_comb begin
    case (stage_field_o_bytes_consumed)
        1      : stage_disp_imm_i_instruction <= stage_sib_i_sib ? i_instruction[0+1+1:7+1+1] : i_instruction[0+1:7+1];
        2      : stage_disp_imm_i_instruction <= stage_sib_i_sib ? i_instruction[0+2+1:7+2+1] : i_instruction[0+2:7+2];
        3      : stage_disp_imm_i_instruction <= stage_sib_i_sib ? i_instruction[0+3+1:7+3+1] : i_instruction[0+3:7+3];
        4      : stage_disp_imm_i_instruction <= stage_sib_i_sib ? i_instruction[0+4+1:7+4+1] : i_instruction[0+4:7+4];
        default: stage_disp_imm_i_instruction <= stage_sib_i_sib ? i_instruction[0+0+1:7+0+1] : i_instruction[0+0:7+0];
    endcase
end
always_comb begin
    if (stage_field_o_displacement_is_present) begin
        stage_disp_imm_i_displacement_is_present <= stage_field_o_displacement_is_present;
        stage_disp_imm_i_displacement_length <= stage_field_o_displacement_length;
    end else if (stage_mod_rm_o_displacement_is_present) begin
        stage_disp_imm_i_displacement_is_present <= stage_mod_rm_o_displacement_is_present;
        stage_disp_imm_i_displacement_length <= stage_mod_rm_o_displacement_length;
    end else if (stage_sib_o_displacement_is_present) begin
        stage_disp_imm_i_displacement_is_present <= stage_sib_o_displacement_is_present;
        stage_disp_imm_i_displacement_length <= stage_sib_o_displacement_length;
    end else begin
        stage_disp_imm_i_displacement_is_present <= 0;
        stage_disp_imm_i_displacement_length <= 0;
    end
end

assign stage_disp_imm_i_immediate_is_present = stage_field_o_immediate_is_present;
assign stage_disp_imm_i_immediate_length = stage_field_o_immediate_length;


// port

assign o_opcode = stage_opcode_o_opcode;

assign o_prefix_lock_bus              = stage_prefix_o_group_1_lock_bus;
assign o_prefix_repeat_not_equal      = stage_prefix_o_group_1_repeat_not_equal;
assign o_prefix_repeat_equal          = stage_prefix_o_group_1_repeat_equal;
assign o_prefix_bound                 = stage_prefix_o_group_1_bound;
assign o_prefix_hint_branch_not_taken = stage_prefix_o_group_2_hint_branch_not_taken;
assign o_prefix_hint_branch_taken     = stage_prefix_o_group_2_hint_branch_taken;

assign o_field_gen_reg_is_present = stage_field_o_gen_reg_is_present;
assign o_field_gen_reg_index = stage_field_o_gen_reg_index;

wire segment_reg_from_prefix = stage_prefix_o_group_2_segment_override;
wire segment_reg_from_opcode = stage_field_o_seg_reg_is_present;
wire segment_reg_from_mod_rm = stage_field_o_mod_rm_is_present;
// assign o_segment_reg_used = segment_reg_from_prefix | segment_reg_from_opcode | segment_reg_from_mod_rm;
always_comb begin
    if (segment_reg_from_prefix) begin
        o_segment_reg_index <= stage_prefix_o_segment_override_index;
    end else if (segment_reg_from_opcode) begin
        o_segment_reg_index <= stage_field_o_seg_reg_index;
    end else if (segment_reg_from_mod_rm) begin
        o_segment_reg_index <= stage_mod_rm_o_segment_reg_index;
    end else begin
        o_segment_reg_index <= 3'b111;
    end
end

assign o_scale_factor = stage_sib_o_scale_factor;

assign o_base_reg_is_present = stage_mod_rm_o_sib_is_present ? stage_sib_o_base_reg_is_present : stage_mod_rm_o_base_reg_is_present;
assign o_base_reg_index = stage_mod_rm_o_sib_is_present ? stage_sib_o_base_reg_index : stage_mod_rm_o_base_reg_index;

assign o_index_reg_is_present = stage_mod_rm_o_sib_is_present ? stage_sib_o_index_reg_is_present : stage_mod_rm_o_index_reg_is_present;
assign o_index_reg_index = stage_mod_rm_o_sib_is_present ? stage_sib_o_index_reg_index : stage_mod_rm_o_index_reg_index;

assign o_mod_rm_gen_reg_is_present = stage_mod_rm_o_gen_reg_is_present;
assign o_mod_rm_gen_reg_index = stage_mod_rm_o_gen_reg_index;
assign o_mod_rm_gen_reg_bit_width = stage_mod_rm_o_gen_reg_bit_width;

assign o_displacement_is_present = stage_mod_rm_o_sib_is_present ? stage_sib_o_displacement_is_present : stage_mod_rm_o_displacement_is_present;
assign o_displacement = stage_disp_imm_o_displacement;

assign o_immediate_is_present = stage_field_o_immediate_is_present | stage_disp_imm_i_immediate_is_present;
assign o_immediate = stage_disp_imm_o_immediate;

assign o_bytes_consumed =
stage_prefix_o_consumed_instruction_bytes +
stage_field_o_bytes_consumed +
stage_mod_rm_o_sib_is_present +
stage_disp_imm_o_bytes_consumed +
0;

assign o_error = stage_prefix_o_error | stage_field_o_error;


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

decode_stage_opcode decode_stage_2_opcode_instance_in_decode (
    .i_instruction ( stage_opcode_i_instruction ),
    .o_opcode      ( stage_opcode_o_opcode )
);

decode_stage_field decode_stage_3_field_instance_in_decode (
    .i_instruction                                 ( stage_field_i_instruction ),
    .i_opcode                                      ( stage_field_i_opcode ),
    .o_s_is_present                                ( stage_field_o_s_is_present ),
    .o_s                                           ( stage_field_o_s ),
    .o_w_is_present                                ( stage_field_o_w_is_present ),
    .o_w                                           ( stage_field_o_w ),
    .o_gen_reg_is_present                          ( stage_field_o_gen_reg_is_present ),
    .o_gen_reg_index                               ( stage_field_o_gen_reg_index ),
    .o_seg_reg_is_present                          ( stage_field_o_seg_reg_is_present ),
    .o_seg_reg_index                               ( stage_field_o_seg_reg_index ),
    .o_mod_rm_is_present                           ( stage_field_o_mod_rm_is_present ),
    .o_mod                                         ( stage_field_o_mod ),
    .o_rm                                          ( stage_field_o_rm ),
    .o_displacement_is_present                     ( stage_field_o_displacement_is_present ),
    .o_displacement_length                         ( stage_field_o_displacement_length ),
    .o_immediate_is_present                        ( stage_field_o_immediate_is_present ),
    .o_immediate_length                            ( stage_field_o_immediate_length ),
    .o_unsigned_full_offset_or_selector_is_present ( stage_field_o_unsigned_full_offset_or_selector_is_present ),
    .o_bytes_consumed                              ( stage_field_o_bytes_consumed ),
    .o_error                                       ( stage_field_o_error )
);

decode_stage_mod_rm decode_stage_4_mod_rm_instance_in_decode (
    .i_mod                     ( stage_mod_rm_i_mod ),
    .i_rm                      ( stage_mod_rm_i_rm ),
    .i_w_is_present            ( stage_mod_rm_i_w_is_present ),
    .i_w                       ( stage_mod_rm_i_w ),
    .i_default_operand_size    ( stage_mod_rm_i_default_operand_size ),
    .o_segment_reg_index       ( stage_mod_rm_o_segment_reg_index ),
    .o_base_reg_is_present     ( stage_mod_rm_o_base_reg_is_present ),
    .o_base_reg_index          ( stage_mod_rm_o_base_reg_index ),
    .o_index_reg_is_present    ( stage_mod_rm_o_index_reg_is_present ),
    .o_index_reg_index         ( stage_mod_rm_o_index_reg_index ),
    .o_gen_reg_is_present      ( stage_mod_rm_o_gen_reg_is_present ),
    .o_gen_reg_index           ( stage_mod_rm_o_gen_reg_index ),
    .o_gen_reg_bit_width       ( stage_mod_rm_o_gen_reg_bit_width ),
    .o_displacement_is_present ( stage_mod_rm_o_displacement_is_present ),
    .o_displacement_length     ( stage_mod_rm_o_displacement_length ),
    .o_sib_is_present          ( stage_mod_rm_o_sib_is_present )
);

decode_stage_sib decode_stage_5_sib_instance_in_decode (
    .i_sib                         ( stage_sib_i_sib ),
    .i_mod                         ( stage_sib_i_mod ),
    .o_scale_factor                ( stage_sib_o_scale_factor ),
    .o_index_reg_is_present        ( stage_sib_o_index_reg_is_present ),
    .o_index_reg_index             ( stage_sib_o_index_reg_index ),
    .o_base_reg_is_present         ( stage_sib_o_base_reg_is_present ),
    .o_base_reg_index              ( stage_sib_o_base_reg_index ),
    .o_displacement_is_present     ( stage_sib_o_displacement_is_present ),
    .o_displacement_length         ( stage_sib_o_displacement_length ),
    .o_effecitve_address_undefined ( stage_sib_o_effecitve_address_undefined )
);

decode_stage_disp_imm decode_stage_6_disp_imm_instance_in_decode (
    .i_instruction             ( stage_disp_imm_i_instruction ),
    .i_displacement_is_present ( stage_disp_imm_i_displacement_is_present ),
    .i_displacement_length     ( stage_disp_imm_i_displacement_length ),
    .i_immediate_is_present    ( stage_disp_imm_i_immediate_is_present ),
    .i_immediate_length        ( stage_disp_imm_i_immediate_length ),
    .o_displacement            ( stage_disp_imm_o_displacement ),
    .o_immediate               ( stage_disp_imm_o_immediate ),
    .o_bytes_consumed          ( stage_disp_imm_o_bytes_consumed )
);

endmodule
