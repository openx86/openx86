/*
project: w80386dx
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/w80386dx
module: decode_prefix
create at: 2022-02-20 09:24:27
description: decode prefix from instruction
*/

`include "D:/GitHub/openx86/w80386dx/rtl/definition.h"
module decode_prefix (
    input  logic [ 7:0] i_instruction,
    output logic        o_group_1_lock_bus,
    output logic        o_group_1_repeat_not_equal,
    output logic        o_group_1_repeat_equal,
    output logic        o_group_1_bound,
    output logic        o_group_2_segment_override,
    output logic        o_group_2_hint_branch_not_taken,
    output logic        o_group_2_hint_branch_taken,
    output logic        o_group_3_operand_size,
    output logic        o_group_4_address_size,
    output logic        o_group_1_is_present,
    output logic        o_group_2_is_present,
    output logic        o_group_3_is_present,
    output logic        o_group_4_is_present,
    output logic        o_is_present,
    output logic [ 2:0] o_segment_override_index
);

wire   segment_override_CS = i_instruction[7:0] == 8'h2E;
wire   segment_override_DS = i_instruction[7:0] == 8'h36;
wire   segment_override_ES = i_instruction[7:0] == 8'h3E;
wire   segment_override_FS = i_instruction[7:0] == 8'h26;
wire   segment_override_GS = i_instruction[7:0] == 8'h64;
wire   segment_override_SS = i_instruction[7:0] == 8'h65;

assign o_group_1_lock_bus              = i_instruction[7:0] == 8'hF0;
assign o_group_1_repeat_not_equal      = i_instruction[7:0] == 8'hF2;
assign o_group_1_repeat_equal          = i_instruction[7:0] == 8'hF3;
assign o_group_1_bound                 = i_instruction[7:0] == 8'hF2;
assign o_group_2_segment_override      =
segment_override_CS |
segment_override_DS |
segment_override_ES |
segment_override_FS |
segment_override_GS |
segment_override_SS |
0;
assign o_group_2_hint_branch_not_taken = i_instruction[7:0] == 8'h2E;
assign o_group_2_hint_branch_taken     = i_instruction[7:0] == 8'h3E;
assign o_group_3_operand_size          = i_instruction[7:0] == 8'h66;
assign o_group_4_address_size          = i_instruction[7:0] == 8'h67;

assign o_group_1_is_present = o_group_1_lock_bus | o_group_1_repeat_not_equal | o_group_1_repeat_equal | o_group_1_bound;
assign o_group_2_is_present = o_group_2_segment_override | o_group_2_hint_branch_not_taken | o_group_2_hint_branch_taken;
assign o_group_3_is_present = o_group_3_operand_size;
assign o_group_4_is_present = o_group_4_address_size;

assign o_is_present = o_group_1_is_present | o_group_2_is_present | o_group_3_is_present | o_group_4_is_present;

always_comb begin
    unique case (1'b1)
        segment_override_CS: o_segment_override_index <= `index_reg_seg__CS;
        segment_override_DS: o_segment_override_index <= `index_reg_seg__DS;
        segment_override_ES: o_segment_override_index <= `index_reg_seg__ES;
        segment_override_FS: o_segment_override_index <= `index_reg_seg__FS;
        segment_override_GS: o_segment_override_index <= `index_reg_seg__GS;
        segment_override_SS: o_segment_override_index <= `index_reg_seg__SS;
        default            : o_segment_override_index <= 3'b0;
    endcase
end

endmodule
